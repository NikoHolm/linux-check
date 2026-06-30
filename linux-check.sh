#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/src/utils.sh"
source "$SCRIPT_DIR/src/getters.sh"
source "$SCRIPT_DIR/src/display.sh"
source "$SCRIPT_DIR/src/health.sh"
source "$SCRIPT_DIR/src/logs.sh"


while true; do

clear

showMenu

echo "========================"
echo "      Linux Check"
echo "        v0.3 Beta"
echo "========================"
echo


echo "Linux Check"
echo
echo "1. Storage"
echo "2. RAM"
echo "3. CPU"
echo "4. Kernel"
echo "5. Uptime"
echo "6. Update your system"
echo "7. Health Check (Currently not working) " 
echo "8. Show System Information"
echo "0. Exit"

read -p "Press number 0-8: " input

clear

case $input in
  1) showStorage 
      pause;;
  2) showRam 
      pause;;
  3) showCpu 
      pause;;
  4) showKernel 
      pause;;
  5) showUptime 
      pause;;
  6) showUpdate 
      pause;;
  7) runHealthCheck
      pause;;   
  8) showSystemInfo
      pause;;
  0) showExit ;;

  *) echo "Invalid input. Please enter a number between 0 and 8." ;;
esac
done
