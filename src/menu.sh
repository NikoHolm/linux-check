#!/bin/bash

# ----------------------------------------------------------------------------
# MENU LOOP
# ----------------------------------------------------------------------------

mainMenu() {
  screen_header
  ui_top "MAIN MENU"
  ui_menu 1 "Storage"      "disk space on /"
  ui_menu 2 "Memory"       "RAM usage"
  ui_menu 3 "CPU"          "processor details"
  ui_menu 4 "Kernel"       "running kernel version"
  ui_menu 5 "Uptime"       "how long since boot"
  ui_menu 6 "Update"       "upgrade all packages"
  ui_menu 7 "Health check" "quick system status"
  ui_menu 8 "System info"  "everything at a glance"
  ui_blank
  ui_menu 0 "Quit"         "exit linux check"
  ui_bottom
  ui_hint "type a number and press Enter"
}

init_theme

while true; do
  mainMenu
  printf '\n'
  read -rp "  ${ACCENT}${BOLD}>${RESET} " input

  case "$input" in
    1) showStorage    ; pause ;;
    2) showRam        ; pause ;;
    3) showCpu        ; pause ;;
    4) showKernel     ; pause ;;
    5) showUptime     ; pause ;;
    6) showUpdate     ; pause ;;
    7) runHealthCheck ; pause ;;
    8) showSystemInfo ; pause ;;
    0) clear; exit 0 ;;
    *)
      printf '\n  %sNot a valid choice. Pick a number from 0 to 8.%s\n' "$RED" "$RESET"
      pause
      ;;
  esac
done
