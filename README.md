# 🎯 ASTD:X Macro Recorder

A powerful and easy-to-use macro recorder for **All Star Tower Defense: X (ASTD:X)** on Roblox.  
This tool allows you to **record**, **save**, and **replay** in-game actions like **Summon**, **Upgrade**, and **Sell** with precise positioning and timing. Built with a modern user interface and hotkey support.

---

## ✨ Features

- 🔴 **Record Macros**: Captures unit actions with timestamp and position.
- 💾 **Save to File**: Stores actions in JSON files inside the `workspace/` folder.
- ▶️ **Replay**: Executes recorded actions step-by-step in-game.
- 🧹 **Clear Steps**: Reset your macro for a new session.
- 🖥️ **Beautiful Drag-Drop GUI**: Intuitive and compact design.
- ⌨️ **Hotkey Support**:
  - `F1`: Start/Stop recording
  - `F2`: Quick save
  - `F3`: Quick replay

---

## 📦 How It Works

The script does the following:

1. **Initializes Services**  
   Loads core Roblox services such as `Players`, `HttpService`, `UserInputService`, `TweenService`, etc.

2. **Hooks Remote Events**
   - Intercepts calls to:
     - `SetEvent:FireServer(...)` for **Summon**
     - `GetFunction:InvokeServer(...)` for **Upgrade** and **Sell**
   - Records the unit's name, position (`CFrame`), timestamp, and action type.

3. **User Interface (UI)**
   - Creates a custom GUI with:
     - Title bar and close button
     - Filename input
     - Recording status and step count
     - Buttons for Record, Save, Replay, and Clear

4. **Macro Save & Load**
   - Macros are saved in JSON format to the `workspace/` directory.
   - Replay reads the macro and re-triggers actions with appropriate delays.

---

## 🧠 Step-by-Step Guide

### ✅ Step 1: Inject the Script
- Use a Roblox executor that supports:
  - `getgenv`, `writefile`, `readfile`, `getrawmetatable`, `HttpService`, `CoreGui` access
- Paste and execute the script in the game (ASTD:X)

### ✅ Step 2: Open the GUI
- The macro GUI will appear at the center of your screen.
- You can drag the window using the title bar.

### ✅ Step 3: Record Actions
- Press the 🔴 `Start Recording` button or `F1` to begin.
- Perform actions in-game like:
  - Summon a unit
  - Upgrade a unit
  - Sell a unit
- Each action will be recorded and timestamped.

### ✅ Step 4: Stop and Save
- Press `Start Recording` again to stop.
- Click 💾 `Save Macro` or press `F2` to save the macro.
- Enter a filename in the textbox (e.g., `wave1_farm`) — file will save as:


### ✅ Step 5: Replay the Macro
- Click ▶️ `Replay Macro` or press `F3`
- The script will load your saved macro and repeat each action in sequence.

### ✅ Step 6: Clear If Needed
- Press 🗑️ `Clear Steps` to reset your recording buffer.

---

## 🗂️ Default Hotkeys

| Hotkey | Action              |
|--------|---------------------|
| F1     | Start/Stop Recording|
| F2     | Quick Save          |
| F3     | Quick Replay        |

---

## 📂 File Location

All macros are stored in:
