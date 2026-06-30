# Linux Check

A small, good-looking terminal UI (TUI) for inspecting your Linux system.
Pure Bash, no dependencies, full color.

## Features

- Storage, memory, CPU, kernel and uptime info
- One-key health check (storage / memory / failed services / internet + DNS)
- Full system summary on one screen
- System update (Arch / pacman)
- Colored TUI with a boxed menu and screens

## Requirements

- Bash
- A terminal with 24-bit ("truecolor") support (most modern terminals)
- `pacman` (only for the update option)

Colors turn off automatically when output is piped to a file, or if you set
`NO_COLOR=1`.

## Installation

```bash
git clone https://github.com/NikoHolm/linux-check.git
cd linux-check
chmod +x linux-check.sh
./linux-check.sh
```

## How it works

The whole program lives in one file, `linux-check.sh`, split into six clearly
labeled sections (the comments in the file mark each one):

1. **THEME** - every color in one place. Change a value here and the whole app
   re-skins. Colors are auto-disabled when not in a terminal.
2. **UI LIBRARY** - the reusable drawing helpers. You almost never edit these;
   you just call them. The important ones:
   - `screen_header` - clears the screen and draws the logo
   - `ui_top "TITLE"` / `ui_bottom` - open and close a panel
   - `ui_kv "Label" "value"` - a "label  value" row
   - `ui_status "Label" ok|warn|fail "detail"` - a row with a colored badge
   - `ui_menu N "Label" "description"` - a menu entry
3. **DATA** - `get*` functions that only collect raw values. No printing.
4. **HEALTH** - `check*` functions that judge a value as OK / WARN / FAIL.
5. **SCREENS** - `show*` / `run*` functions that draw a full screen using the
   UI helpers.
6. **MENU LOOP** - the main menu and the `case` that runs your choice.

The golden rule: **data functions never print, screen functions never compute.**
Keeping those separate is what makes the app easy to grow.

## Adding a new check (step by step)

Say you want to add **Battery** info. You touch three places.

**1. Add a data function** (section DATA) - just return the raw value:

```bash
getBattery() {
  cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
}
```

**2. Add a screen function** (section SCREENS) - draw it with the helpers:

```bash
showBattery() {
  screen_header
  ui_top "BATTERY"
  ui_kv "Charge" "$(getBattery)%"
  ui_bottom
}
```

**3. Wire it into the menu** (section MENU LOOP) - one line in `mainMenu`:

```bash
ui_menu 9 "Battery" "charge level"
```

and one line in the `case`:

```bash
9) showBattery ; pause ;;
```

That's it. Run the script and option 9 is live, matching the rest of the UI.

### Tip: a health-check row instead of an info row

If you want a green/red status instead of a plain value, write a `check*`
function and use `ui_status`:

```bash
checkBattery() {
  local pct; pct=$(getBattery)
  if (( pct >= 20 )); then
    ui_status "Battery" ok "${pct}%"
  else
    ui_status "Battery" warn "low (${pct}%)"
  fi
}
```

Then call `checkBattery` from inside `runHealthCheck`.

## Roadmap

- [x] CPU information
- [x] Better UI
- [x] Color support
- [ ] Battery information
- [ ] Network information
- [ ] macOS support
- [ ] Windows version
