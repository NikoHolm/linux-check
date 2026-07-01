#!/bin/bash
# ============================================================================
# Linux Check - a small TUI for inspecting your system
#
# Entry point of the application.
# Loads modules from src/ and starts the menu loop.
#
# See README.md for project structure and feature guide.
# ============================================================================


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


source "$DIR/src/theme.sh"
source "$DIR/src/ui.sh"
source "$DIR/src/data.sh"
source "$DIR/src/health.sh"
source "$DIR/src/screens.sh"
source "$DIR/src/menu.sh"


init_theme

run_menu
