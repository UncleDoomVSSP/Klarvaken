# Klarvaken

Klarvaken is Swedish for wide awake.

Klarvaken is a small macOS menu bar app that stops your Mac from going to sleep. It sits in the menu bar at the top right of the screen as a coffee cup icon. It has no Dock icon and no window.

- One click on the icon keeps the Mac awake until you click it again.
- A right click opens a menu where you can keep the Mac awake for 30 minutes, 1 hour, 2 hours, 3 hours, 4 hours or indefinitely.

## Contents

1. [Requirements](#requirements)
2. [Install option A: download the built app from GitHub](#install-option-a-download-the-built-app-from-github)
3. [Install option B: build the app yourself on your Mac](#install-option-b-build-the-app-yourself-on-your-mac)
4. [Opening the app for the first time](#opening-the-app-for-the-first-time)
5. [Using Klarvaken](#using-klarvaken)
6. [Starting Klarvaken automatically at login](#starting-klarvaken-automatically-at-login)
7. [Checking that it is working](#checking-that-it-is-working)
8. [Updating to a new version](#updating-to-a-new-version)
9. [Uninstalling](#uninstalling)
10. [Troubleshooting](#troubleshooting)
11. [How it works](#how-it-works)
12. [Project layout](#project-layout)

## Requirements

- macOS 11 (Big Sur) or later.
- Any Mac, Apple silicon (M1 and later) or Intel. The app is built as a universal binary that runs natively on both.
- For install option B only: Xcode or the Xcode Command Line Tools.

## Install option A: download the built app from GitHub

Every push to this repository builds the app automatically with GitHub Actions. You can download the result without installing any developer tools.

1. Sign in to GitHub. Downloads from GitHub Actions are only available to signed-in users.
2. Open this repository on GitHub and click the **Actions** tab at the top of the page.
3. In the left-hand list, click the **Build** workflow.
4. Click the most recent run with a green tick. If you want a particular branch, check the branch name shown under the run title.
5. Scroll down to the **Artifacts** section at the bottom of the run page.
6. Click **Klarvaken.app** to download it. Your browser saves a file called `Klarvaken.app.zip` to your **Downloads** folder.
7. Open **Finder** and go to **Downloads**.
8. Double-click `Klarvaken.app.zip` to unzip it. GitHub wraps the build in its own zip, so you may get a second file called `Klarvaken.app.zip` inside a folder. If so, double-click that one as well. Keep going until you see **Klarvaken** with an app icon (`Klarvaken.app`).
   - Safari may unzip the first layer for you automatically. That is fine; just unzip whatever zip is left.
9. Drag **Klarvaken** into the **Applications** folder in the Finder sidebar.
10. Continue with [Opening the app for the first time](#opening-the-app-for-the-first-time). Because this copy came from the internet, macOS will ask you to confirm it the first time.

Note: GitHub deletes Actions downloads after 90 days. If the **Artifacts** section is empty or expired, click **Re-run all jobs** on the run page (you need write access to the repository), or use install option B.

## Install option B: build the app yourself on your Mac

### Step 1: install the build tools

If you already have Xcode installed, skip to step 2.

1. Open **Terminal** (press **Cmd + Space**, type `Terminal`, press **Return**).
2. Run:

   ```sh
   xcode-select --install
   ```

3. A window appears asking to install the command line developer tools. Click **Install**, then **Agree**, and wait for it to finish (this can take several minutes).
4. Check it worked by running:

   ```sh
   swift --version
   ```

   You should see a line starting with `swift-driver version` or `Apple Swift version`.

### Step 2: get the source code

Either clone the repository with git:

```sh
cd ~/Downloads
git clone https://github.com/UncleDoomVSSP/klarvaken.git
cd klarvaken
```

Or download it as a zip:

1. On the repository page on GitHub, click the green **Code** button and choose **Download ZIP**.
2. In Finder, double-click the downloaded zip in **Downloads** to unzip it.
3. In Terminal, go into the unzipped folder, for example:

   ```sh
   cd ~/Downloads/klarvaken-main
   ```

### Step 3: build the app

From inside the `klarvaken` folder, run:

```sh
./build.sh
```

If you get `permission denied`, run `chmod +x build.sh` once and try again.

When it finishes you will see:

```
Built build/Klarvaken.app
Zipped build/Klarvaken.app.zip
```

The script:

1. Compiles the app twice, once for Apple silicon (`arm64`) and once for Intel (`x86_64`).
2. Joins the two into a single universal binary.
3. Assembles `build/Klarvaken.app` with its `Info.plist`.
4. Signs it with an ad-hoc signature so macOS will run it.
5. Creates `build/Klarvaken.app.zip`, a zipped copy you can share or keep as a backup.

### Step 4: install it

Copy the app into **Applications**:

```sh
cp -R "build/Klarvaken.app" /Applications/
```

Or, in Finder, open the `build` folder inside `klarvaken` and drag **Klarvaken** into **Applications**.

Then open it:

```sh
open "/Applications/Klarvaken.app"
```

An app you build yourself is not marked as downloaded, so macOS normally opens it without any security prompt.

## Opening the app for the first time

Klarvaken is not notarised by Apple, so macOS blocks it the first time you open a copy downloaded from the internet. You only need to do this once.

### macOS 15 (Sequoia) and later

1. Double-click **Klarvaken** in **Applications**. A message says Apple could not verify it. Click **Done** (do not click **Move to Bin**).
2. Open **System Settings** and click **Privacy & Security** in the sidebar.
3. Scroll down to the **Security** section. You will see a message saying "Klarvaken" was blocked.
4. Click **Open Anyway**.
5. Enter your Mac password or use Touch ID when asked.
6. In the next message, click **Open Anyway** again.

### macOS 11 to 14

1. In Finder, open **Applications**.
2. Hold **Control** and click **Klarvaken** (or right-click it), then choose **Open**.
3. In the message that appears, click **Open**.

If that does not show an **Open** button, use the **System Settings > Privacy & Security > Open Anyway** steps above (on macOS 11 and 12 this is **System Preferences > Security & Privacy > General**).

### Alternative: using Terminal

This removes the "downloaded from the internet" flag so macOS stops asking:

```sh
xattr -dr com.apple.quarantine "/Applications/Klarvaken.app"
```

Once the app is running, a coffee cup outline appears in the menu bar at the top right of the screen.

## Using Klarvaken

### The icon

| Icon | Meaning |
| --- | --- |
| Coffee cup outline | Off. The Mac sleeps as normal. |
| Filled coffee cup | On. The Mac is being kept awake. |

Hover over the icon to see a tooltip with the current state and, for a timed session, when it ends.

### Quick click (left click)

- **Click the icon once** to turn keep-awake on with no time limit.
- **Click it again** to turn it off.

If a timed session is running, a left click turns it off.

### The menu (right click)

Right-click the icon to open the menu. You can also hold **Control** or **Option** and click it, which is useful with a trackpad.

The menu contains:

| Item | What it does |
| --- | --- |
| Status line (greyed out) | Shows whether Klarvaken is off, on indefinitely, or on until a set time, for example `On until 16:45 (1h 30m left)`. |
| **30 Minutes** | Keeps the Mac awake for 30 minutes, then switches off. |
| **1 Hour** | Keeps the Mac awake for 1 hour, then switches off. |
| **2 Hours** | Keeps the Mac awake for 2 hours, then switches off. |
| **3 Hours** | Keeps the Mac awake for 3 hours, then switches off. |
| **4 Hours** | Keeps the Mac awake for 4 hours, then switches off. |
| **Indefinitely** | Keeps the Mac awake until you turn it off. Same as a left click. |
| **Turn Off** | Stops keeping the Mac awake. Only available while it is on. |
| **Quit Klarvaken** | Turns keep-awake off and closes the app. Shortcut **Cmd + Q** while the menu is open. |

A tick shows which option is running.

### Changing or extending a timer

Choosing a duration while one is already running replaces it and starts the new timer from now. For example, if 10 minutes are left on a 1 hour session and you choose **1 Hour** again, the Mac now stays awake for a full hour from that moment.

### When a timer runs out

The icon returns to the outline and the Mac goes back to its normal sleep settings. If the Mac went to sleep anyway (for example you closed the lid) and the timer ran out while it was asleep, Klarvaken switches off within about 30 seconds of waking.

### What Klarvaken does not do

- It does not stop the Mac sleeping when you close the lid of a MacBook.
- It does not stop sleep when you choose **Apple menu > Sleep**.
- It does not change your saved Energy or Battery settings. Once it is off or quit, everything behaves exactly as before.
- It does not remember its state between launches. It always starts switched off.

## Starting Klarvaken automatically at login

### macOS 13 (Ventura) and later

1. Open **System Settings**.
2. Click **General** in the sidebar, then **Login Items** (called **Login Items & Extensions** on newer versions).
3. Under **Open at Login**, click the **+** button.
4. Select **Klarvaken** in **Applications** and click **Open**.

### macOS 11 and 12

1. Open **System Preferences** and click **Users & Groups**.
2. Select your user and click the **Login Items** tab.
3. Click the padlock and enter your password if needed.
4. Click **+**, select **Klarvaken** in **Applications** and click **Add**.

To stop it starting at login, select it in the same list and click **-**.

## Checking that it is working

1. Turn Klarvaken on.
2. Open **Terminal** and run:

   ```sh
   pmset -g assertions | grep "Keeping Mac awake"
   ```

3. You should see a line containing `PreventUserIdleDisplaySleep` and `named: "Keeping Mac awake"`.
4. Turn Klarvaken off and run the command again. The line should be gone.

You can also open **Activity Monitor**, choose the **Energy** tab and look at the **Preventing Sleep** column for **Klarvaken** (right-click the column headers to add it if it is not shown).

## Updating to a new version

1. Right-click the menu bar icon and choose **Quit Klarvaken**.
2. Get the new version using install option A or B.
3. Drag the new **Klarvaken** into **Applications** and choose **Replace** when asked.
4. Open it again. If you downloaded it, you may need to repeat [Opening the app for the first time](#opening-the-app-for-the-first-time).

## Uninstalling

1. Right-click the menu bar icon and choose **Quit Klarvaken**.
2. Remove it from your login items if you added it (see [Starting Klarvaken automatically at login](#starting-klarvaken-automatically-at-login)).
3. In Finder, open **Applications** and drag **Klarvaken** to the Bin.

The app stores no settings or other files, so nothing else needs removing.

## Troubleshooting

**I cannot see the icon in the menu bar.**
- Check the app is running: open **Activity Monitor** and search for `Klarvaken`.
- On a MacBook with a notch, the icon may be hidden behind the notch if the menu bar is full. Quit some other menu bar apps, or hold **Cmd** and drag other icons out of the menu bar to make room.
- On macOS 26 (Tahoe) and later, check **System Settings > Menu Bar** and make sure Klarvaken is allowed in the menu bar.

**"Klarvaken is damaged and can't be opened."**
This usually means the quarantine flag is set on a copy downloaded from the internet. Run:

```sh
xattr -dr com.apple.quarantine "/Applications/Klarvaken.app"
```

**My Mac still goes to sleep.**
- Make sure the icon is filled (on).
- Closing a MacBook lid always sleeps it, unless an external display, keyboard and power are connected.
- Run the check in [Checking that it is working](#checking-that-it-is-working).

**`./build.sh` fails with `xcrun: error: invalid active developer path`.**
The Command Line Tools are not installed. Run `xcode-select --install` and try again.

**`./build.sh` fails with `permission denied`.**
Run `chmod +x build.sh` and try again.

**Right click does nothing.**
Hold **Control** or **Option** and left-click the icon instead.

## How it works

While on, Klarvaken holds an IOKit power assertion of type `PreventUserIdleDisplaySleep`, named "Keeping Mac awake". This is the same mechanism apps such as video players use. It stops the display from dimming and turning off and stops the Mac from idle sleeping. When you turn it off, quit the app, or a timer runs out, the assertion is released and macOS returns to your normal sleep settings. If the app crashes, macOS releases the assertion automatically.

## Project layout

| Path | Purpose |
| --- | --- |
| `Sources/Klarvaken/main.swift` | The whole app: menu bar icon, menu, timers and power assertion. |
| `Resources/Info.plist` | App metadata: name, bundle identifier (`space.vintersol.klarvaken`), version, minimum macOS version, and `LSUIElement` which hides the Dock icon. |
| `build.sh` | Builds, signs and zips `Klarvaken.app` into the `build` folder. |
| `.github/workflows/build.yml` | GitHub Actions workflow that runs `build.sh` on a Mac for every push and uploads the app as a download. |
