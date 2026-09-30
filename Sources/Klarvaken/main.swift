import AppKit
import IOKit.pwr_mgt

/// A keep-awake duration offered in the menu. `nil` seconds means indefinite.
struct AwakeDuration {
    let title: String
    let seconds: TimeInterval?

    static let all: [AwakeDuration] = [
        AwakeDuration(title: "30 Minutes", seconds: 30 * 60),
        AwakeDuration(title: "1 Hour", seconds: 60 * 60),
        AwakeDuration(title: "2 Hours", seconds: 2 * 60 * 60),
        AwakeDuration(title: "3 Hours", seconds: 3 * 60 * 60),
        AwakeDuration(title: "4 Hours", seconds: 4 * 60 * 60),
        AwakeDuration(title: "Indefinitely", seconds: nil),
    ]
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var assertionID: IOPMAssertionID = 0
    private var isActive = false

    /// When the current session ends. `nil` while inactive or running indefinitely.
    private var endDate: Date?
    /// Index into `AwakeDuration.all` of the running session, used for the checkmark.
    private var activeDurationIndex: Int?
    private var expiryTimer: Timer?
    private var refreshTimer: Timer?

    private let menu = NSMenu()
    private let statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        buildMenu()
        updateUI()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stop()
    }

    // MARK: - Click handling

    /// Left click toggles indefinite keep-awake. Right click, or Control/Option + click, opens the menu.
    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        let showsMenu = event.type == .rightMouseUp
            || event.modifierFlags.contains(.control)
            || event.modifierFlags.contains(.option)

        if showsMenu {
            showMenu()
        } else {
            toggle()
        }
    }

    private func toggle() {
        if isActive {
            stop()
        } else {
            start(durationIndex: AwakeDuration.all.count - 1)
        }
    }

    private func showMenu() {
        updateMenu()
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        // Detach so the next left click goes back to toggling.
        statusItem.menu = nil
    }

    // MARK: - Menu

    private func buildMenu() {
        menu.delegate = self
        menu.autoenablesItems = false

        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())

        let header = NSMenuItem(title: "Keep Awake For", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        for (index, duration) in AwakeDuration.all.enumerated() {
            let item = NSMenuItem(title: duration.title, action: #selector(selectDuration(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            item.indentationLevel = 1
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let offItem = NSMenuItem(title: "Turn Off", action: #selector(turnOff(_:)), keyEquivalent: "")
        offItem.target = self
        offItem.tag = -1
        menu.addItem(offItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Klarvaken", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
    }

    private func updateMenu() {
        statusMenuItem.title = statusText()
        for item in menu.items {
            if item.action == #selector(selectDuration(_:)) {
                item.state = (isActive && item.tag == activeDurationIndex) ? .on : .off
            } else if item.tag == -1 {
                item.isEnabled = isActive
            }
        }
    }

    @objc private func selectDuration(_ sender: NSMenuItem) {
        start(durationIndex: sender.tag)
    }

    @objc private func turnOff(_ sender: NSMenuItem) {
        stop()
    }

    // MARK: - Power assertion

    private func start(durationIndex: Int) {
        let duration = AwakeDuration.all[durationIndex]

        if !isActive {
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "Keeping Mac awake" as CFString,
                &assertionID
            )
            guard result == kIOReturnSuccess else {
                NSLog("Klarvaken: failed to create power assertion (%d)", result)
                return
            }
            isActive = true
        }

        activeDurationIndex = durationIndex
        expiryTimer?.invalidate()
        expiryTimer = nil

        if let seconds = duration.seconds {
            endDate = Date().addingTimeInterval(seconds)
            let timer = Timer(timeInterval: seconds, repeats: false) { [weak self] _ in
                self?.stop()
            }
            RunLoop.main.add(timer, forMode: .common)
            expiryTimer = timer
            startRefreshTimer()
        } else {
            endDate = nil
            stopRefreshTimer()
        }

        updateUI()
    }

    private func stop() {
        expiryTimer?.invalidate()
        expiryTimer = nil
        stopRefreshTimer()

        if isActive {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
            isActive = false
        }
        endDate = nil
        activeDurationIndex = nil
        updateUI()
    }

    /// Keeps the tooltip and open menu showing an up-to-date remaining time.
    private func startRefreshTimer() {
        stopRefreshTimer()
        let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Catches an expiry missed while the Mac was asleep (e.g. lid closed).
            if let endDate = self.endDate, endDate <= Date() {
                self.stop()
            } else {
                self.updateUI()
            }
        }
        timer.tolerance = 5
        RunLoop.main.add(timer, forMode: .common)
        refreshTimer = timer
    }

    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - UI

    private func updateUI() {
        guard let button = statusItem?.button else { return }
        let symbol = isActive ? "eye.fill" : "eye"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: isActive ? "Klarvaken is on" : "Klarvaken is off")
        image?.isTemplate = true
        button.image = image

        if isActive {
            button.toolTip = "\(statusText()). Click to allow sleep, right-click for options."
        } else {
            button.toolTip = "Klarvaken is off. Click to keep the Mac awake, right-click for options."
        }
        updateMenu()
    }

    private func statusText() -> String {
        guard isActive else { return "Klarvaken is off" }
        guard let endDate = endDate else { return "Klarvaken is on indefinitely" }

        let remaining = max(0, endDate.timeIntervalSinceNow)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "On until \(formatter.string(from: endDate)) (\(formatRemaining(remaining)) left)"
    }

    private func formatRemaining(_ interval: TimeInterval) -> String {
        let totalMinutes = Int((interval / 60).rounded(.up))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
