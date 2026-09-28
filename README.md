# StayAwake

A small macOS menu bar app that stops your Mac going to sleep.

## Usage

- **Left click** the cup icon in the menu bar to toggle keep-awake on or off (indefinitely).
- **Right click** (or Control/Option + click) the icon to open the menu:
  - Keep awake for 30 minutes, 1 hour, 2 hours, 3 hours, 4 hours or indefinitely
  - See how long is left and when it will switch off
  - Turn off
  - Quit

The icon is filled while the Mac is being kept awake. Timed sessions switch off automatically when they run out.

It works by holding an IOKit `PreventUserIdleDisplaySleep` power assertion, which stops both the display and the system from idle sleeping. Closing the lid will still sleep the Mac.

## Requirements

- macOS 11 (Big Sur) or later
- Apple silicon or Intel

## Building

On a Mac with Xcode or the Command Line Tools installed (`xcode-select --install`):

```sh
./build.sh
```

This produces `build/Stay Awake.app` (universal binary, ad-hoc signed) and `build/Stay_Awake.app.zip`. Copy the app into `/Applications`.

Every push also builds the app on GitHub Actions; download it from the **Stay_Awake.app** artifact on the workflow run.

As the app is not notarised, the first time you open it macOS may block it. Right click the app in Finder and choose **Open**, or allow it under **System Settings > Privacy & Security**.

## Launch at login

Add the app under **System Settings > General > Login Items**.
