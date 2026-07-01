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

The app is split into small Bash modules inside `src/`:

```text
linux-check/
├── linux-check.sh     # Entry point
└── src/
    ├── theme.sh       # Colors and theme setup
    ├── ui.sh          # Reusable TUI drawing helpers
    ├── data.sh        # Raw system information
    ├── health.sh      # OK / WARN / FAIL checks
    ├── screens.sh     # Full application screens
    └── menu.sh        # Main menu loop
```

The golden rule: **data functions never print, screen functions never compute.**
Keeping those separate is what makes the app easy to grow.

## Adding a new check (step by step)

Say you want to add **Battery** info. You touch three places.

**1. Add a data function** (`src/data.sh`) - just return the raw value:

```bash
getBattery() {
  cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
}
```

**2. Add a screen function** (`src/screens.sh`) - draw it with the helpers:

```bash
showBattery() {
  screen_header
  ui_top "BATTERY"
  ui_kv "Charge" "$(getBattery)%"
  ui_bottom
}
```

**3. Add it to the menu** (`src/menu.sh`):

Add a menu entry:

```bash
ui_menu 9 "Battery" "charge level"
```

and handle the new option in the `case` statement:

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
- [ ] Windows support
