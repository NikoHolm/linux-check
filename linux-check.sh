#!/bin/bash
# ============================================================================
#  Linux Check  -  a small TUI for inspecting your system
# ============================================================================
#  Structure of this file (read top to bottom):
#
#    1. THEME      - colors, all in one place so you can re-skin the whole app
#    2. UI LIBRARY - reusable drawing helpers (boxes, rows, badges, banner)
#    3. DATA       - get*  functions that only collect raw values
#    4. HEALTH     - check* functions that judge a value as OK / WARN / FAIL
#    5. SCREENS    - show* / run* functions that draw a full screen
#    6. MENU LOOP  - the main menu and the case that routes your choice
#
#  To add a new feature you usually touch 3 places: a get* function (data),
#  a show* function (screen), and one line in the menu + case. See README.md.
#
#  Note: we intentionally do NOT use `set -e` here. This is an interactive
#  loop and many commands (ping, systemctl) return non-zero on purpose; we
#  want to handle that ourselves, not exit the whole program.
# ============================================================================


# ----------------------------------------------------------------------------
# 1. THEME  (Tokyo Night palette, 24-bit color)
# ----------------------------------------------------------------------------
# Change a value here and it changes everywhere. Colors are disabled
# automatically when output is not a terminal, or when NO_COLOR is set.

init_theme() {
  RESET=$'\e[0m';  BOLD=$'\e[1m';  DIM=$'\e[2m'
  FG=$'\e[38;2;192;202;245m'      # main text
  MUTED=$'\e[38;2;86;95;137m'     # labels, hints
  ACCENT=$'\e[38;2;122;162;247m'  # blue   - primary accent
  CYAN=$'\e[38;2;125;207;255m'    # cyan
  GREEN=$'\e[38;2;158;206;106m'   # ok
  YELLOW=$'\e[38;2;224;175;104m'  # warn
  RED=$'\e[38;2;247;118;142m'     # fail
  PURPLE=$'\e[38;2;187;154;247m'  # purple
  BORDER=$'\e[38;2;122;162;247m'  # box frame

  # No colors when piped to a file, or when the user asks for NO_COLOR.
  if [[ ! -t 1 || -n "${NO_COLOR:-}" ]]; then
    RESET='' BOLD='' DIM='' FG='' MUTED='' ACCENT='' CYAN='' \
    GREEN='' YELLOW='' RED='' PURPLE='' BORDER=''
  fi
}

# Inner width of every panel (characters between the side borders, minus the
# one space of padding on each side). Bump this if you want wider boxes.
UI_W=54


# ----------------------------------------------------------------------------
# 2. UI LIBRARY  (the drawing helpers every screen is built from)
# ----------------------------------------------------------------------------

# Visible length of a string, ignoring color escape codes (so padding lines up).
ui_vislen() {
  local clean
  clean=$(printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*m//g')
  printf '%s' "${#clean}"
}

# A horizontal run of $1 line characters, used by the box borders.
ui_hline() {
  local n=$1 line=''
  for ((i = 0; i < n; i++)); do line+='─'; done
  printf '%s' "$line"
}

# One content line inside a box. Pass already-colored text; padding is fixed up.
ui_row() {
  local text="$1" vis pad
  vis=$(ui_vislen "$text")
  pad=$((UI_W - vis)); ((pad < 0)) && pad=0
  printf '  %s│%s %s%*s %s│%s\n' "$BORDER" "$RESET" "$text" "$pad" '' "$BORDER" "$RESET"
}

ui_blank() { ui_row ''; }

# Box pieces. ui_top draws the frame top + a title row + a divider.
ui_top() {
  printf '  %s╭%s╮%s\n' "$BORDER" "$(ui_hline $((UI_W + 2)))" "$RESET"
  ui_row "${BOLD}${ACCENT}$1${RESET}"
  printf '  %s├%s┤%s\n' "$BORDER" "$(ui_hline $((UI_W + 2)))" "$RESET"
}
ui_bottom() { printf '  %s╰%s╯%s\n' "$BORDER" "$(ui_hline $((UI_W + 2)))" "$RESET"; }

# A "label  value" row, used by every info screen.
ui_kv() {
  local key="$1" val="$2" avail=$((UI_W - 14)) kp
  ((${#val} > avail)) && val="${val:0:avail}"
  kp=$((14 - ${#key})); ((kp < 0)) && kp=0
  ui_row "${MUTED}${key}${RESET}$(printf '%*s' "$kp" '')${FG}${BOLD}${val}${RESET}"
}

# A status row with a colored badge: state is ok | warn | fail.
ui_status() {
  local label="$1" state="$2" detail="$3" badge lp
  case "$state" in
    ok)   badge="${GREEN}[ OK ]${RESET}" ;;
    warn) badge="${YELLOW}[WARN]${RESET}" ;;
    fail) badge="${RED}[FAIL]${RESET}" ;;
  esac
  lp=$((16 - ${#label})); ((lp < 0)) && lp=0
  ui_row "${FG}${label}${RESET}$(printf '%*s' "$lp" '')${badge}  ${MUTED}${detail}${RESET}"
}

# A menu entry: [number]  Label  description.
ui_menu() {
  local num="$1" label="$2" desc="$3" plain lpad
  plain="[$num]  $label"
  lpad=$((20 - ${#plain})); ((lpad < 0)) && lpad=0
  ui_row "${MUTED}[${RESET}${ACCENT}${BOLD}${num}${RESET}${MUTED}]${RESET}  ${FG}${label}${RESET}$(printf '%*s' "$lpad" '')${MUTED}${desc}${RESET}"
}

# Centered muted hint printed below a box.
ui_hint() {
  local msg="$1" pad
  pad=$((2 + (UI_W + 2 - ${#msg}) / 2)); ((pad < 0)) && pad=0
  printf '\n%*s%s%s%s\n' "$pad" '' "$MUTED" "$msg" "$RESET"
}

# The ANSI-art logo, drawn with a blue -> purple gradient and centered.
ui_banner() {
  local lines=(
'██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗'
'██║     ██║████╗  ██║██║   ██║╚██╗██╔╝'
'██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ '
'██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ '
'███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗'
'╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝'
  )
  local grad=("$ACCENT" "$ACCENT" "$CYAN" "$PURPLE" "$PURPLE" "$PURPLE")
  local w=0 i
  for i in "${lines[@]}"; do ((${#i} > w)) && w=${#i}; done
  local pad=$((2 + (UI_W + 2 - w) / 2)); ((pad < 0)) && pad=0
  printf '\n'
  for i in "${!lines[@]}"; do
    printf '%*s%s%s%s\n' "$pad" '' "${grad[i]}" "${lines[i]}" "$RESET"
  done
  local sub="system inspector  —  v0.69"
  local spad=$((2 + (UI_W + 2 - ${#sub}) / 2)); ((spad < 0)) && spad=0
  printf '%*s%s%s%s\n\n' "$spad" '' "$MUTED" "$sub" "$RESET"
}

# Every screen starts the same way: clear, then draw the banner.
screen_header() {
  clear
  ui_banner
}

# A styled "press enter" prompt shown after each screen.
pause() {
  printf '\n'
  read -rp "  ${MUTED}Press Enter to return to menu...${RESET} " _
}


# ----------------------------------------------------------------------------
# 3. DATA  (collect raw values only - no printing, no judging)
# ----------------------------------------------------------------------------

getKernelVersion() { uname -r; }

getOsInfo() {
  # Subshell keeps the sourced variables out of the rest of the script.
  ( . /etc/os-release 2>/dev/null; printf '%s\n' "${PRETTY_NAME:-Unknown}" )
}

getHostName() { hostname; }

getStorage() { df -h / | awk 'NR==2 {print $2, $3, $4}'; }

getStorageFreeNumber() { df -BG / | awk 'NR==2 {gsub("G", "", $4); print $4}'; }

getRamInfo() { free -h | awk 'NR==2 {print $2, $3, $7}'; }

getFreeRamNumber() { free -g | awk 'NR==2 {print $7}'; }

getCpuInfo() {
  lscpu | awk -F: '
    /Model name/   {gsub(/^[ \t]+/, "", $2); model=$2}
    /Architecture/ {gsub(/^[ \t]+/, "", $2); arch=$2}
    $1=="CPU(s)"   {gsub(/^[ \t]+/, "", $2); cpus=$2}
    END { print model; print arch; print cpus }'
}


# ----------------------------------------------------------------------------
# 4. HEALTH  (turn a raw value into an OK / WARN / FAIL row)
# ----------------------------------------------------------------------------

checkStorage() {
  local free; free=$(getStorageFreeNumber)
  if ((free >= 30)); then
    ui_status "Storage" ok "${free}G free"
  else
    ui_status "Storage" fail "only ${free}G free"
  fi
}

checkRam() {
  local free; free=$(getFreeRamNumber)
  if ((free >= 4)); then
    ui_status "Memory" ok "${free}G free"
  else
    ui_status "Memory" fail "only ${free}G free"
  fi
}

checkServices() {
  local failed; failed=$(systemctl --failed --no-legend | wc -l)
  if ((failed == 0)); then
    ui_status "Services" ok "no failed units"
  else
    ui_status "Services" fail "$failed failed unit(s)"
  fi
}

checkInternet() {
  if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    ui_status "Internet" ok "reachable"
    if ping -c 1 -W 2 google.com &>/dev/null; then
      ui_status "DNS" ok "names resolve"
    else
      ui_status "DNS" fail "cannot resolve names"
    fi
  else
    ui_status "Internet" fail "no connection"
  fi
}


# ----------------------------------------------------------------------------
# 5. SCREENS  (draw a full panel using the helpers above)
# ----------------------------------------------------------------------------

showStorage() {
  screen_header
  local total used free
  read -r total used free <<< "$(getStorage)"
  ui_top "STORAGE"
  ui_kv "Total" "$total"
  ui_kv "Used"  "$used"
  ui_kv "Free"  "$free"
  ui_bottom
}

showRam() {
  screen_header
  local total used avail
  read -r total used avail <<< "$(getRamInfo)"
  ui_top "MEMORY"
  ui_kv "Total"     "$total"
  ui_kv "Used"      "$used"
  ui_kv "Available" "$avail"
  ui_bottom
}

showCpu() {
  screen_header
  local cpu; mapfile -t cpu < <(getCpuInfo)
  ui_top "CPU"
  ui_kv "Model" "${cpu[0]}"
  ui_kv "Arch"  "${cpu[1]}"
  ui_kv "Cores" "${cpu[2]}"
  ui_bottom
}

showKernel() {
  screen_header
  ui_top "KERNEL"
  ui_kv "Release" "$(getKernelVersion)"
  ui_bottom
}

showUptime() {
  screen_header
  ui_top "UPTIME"
  ui_kv "Up for" "$(uptime -p | sed 's/^up //')"
  ui_bottom
}

showSystemInfo() {
  screen_header
  local total used free cpu
  read -r total used free <<< "$(getStorage)"
  mapfile -t cpu < <(getCpuInfo)
  ui_top "SYSTEM INFORMATION"
  ui_kv "Hostname" "$(getHostName)"
  ui_kv "OS"       "$(getOsInfo)"
  ui_kv "Kernel"   "$(getKernelVersion)"
  ui_kv "CPU"      "${cpu[0]}"
  ui_kv "Cores"    "${cpu[2]}"
  ui_kv "RAM"      "$(getRamInfo)"
  ui_kv "Storage"  "$total total, $free free"
  ui_kv "Uptime"   "$(uptime -p | sed 's/^up //')"
  ui_bottom
}

runHealthCheck() {
  screen_header
  ui_top "HEALTH CHECK"
  checkStorage
  checkRam
  checkServices
  checkInternet
  ui_bottom
}

showUpdate() {
  screen_header
  ui_top "SYSTEM UPDATE"
  ui_row "${YELLOW}${BOLD}[WARNING]${RESET}"
  ui_row "${FG}This will update every package on your system.${RESET}"
  ui_blank
  ui_row "${MUTED}command: sudo pacman -Syu${RESET}"
  ui_bottom
  printf '\n'
  read -rp "  Continue? (y/N) " answer
  if [[ "$answer" == [yY] ]]; then
    printf '\n'
    sudo pacman -Syu
  else
    printf '\n  %sUpdate cancelled.%s\n' "$MUTED" "$RESET"
  fi
}


# ----------------------------------------------------------------------------
# 6. MENU LOOP
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
