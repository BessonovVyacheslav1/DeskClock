# Desktop Clock

A lightweight Windows widget that displays the current time using desktop folder icons.

---

## How It Works

The application uses a VBScript that runs every minute via the Windows Task Scheduler. This script updates the icons of five dedicated folders on your desktop (`HH`, `H`, `o`, `MM`, `M`) to represent the digits of the current time.

---

## Features

* **Minimalist Display:** A unique and clean way to see the time directly on your desktop.
* **Automated Setup:** A single `.exe` installer handles everything from file placement to task creation.
* **Lightweight:** A simple script runs once per minute with negligible impact on system performance.
* **Customizable Layout:** After disabling "Auto-arrange icons", you can place the folders anywhere on your desktop.

---

## Installation

1.  Run the `DesktopClockInstaller.exe`.
2.  An information window will appear. Click **OK** to proceed or **Cancel** to abort.
3.  The installer will automatically:
    * Create the required folders on your desktop.
    * Copy necessary files to `%LOCALAPPDATA%\DesktopClock`.
    * Create a scheduled task named "Update Desktop Clock".

---

## Requirements

* Windows OS
* Administrator rights are required during installation to set up the scheduled task.
