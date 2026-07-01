#!/bin/bash

# ----------------------------------------------------------------------------
# THEME  (Tokyo Night palette, 24-bit color)
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