
#!/bin/bash

# ----------------------------------------------------------------------------
# UI LIBRARY  (the drawing helpers every screen is built from)
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

