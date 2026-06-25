#!/bin/bash

showStorage() {
  echo "You have this much storage left" 
  df -h / | awk 'NR==2 {print "Storage information" "\n Free: " $4"  \n Total: " $2 " \n Used: " $5 }'
  read -p "Press Enter to continue..."
}

showRam() {
  echo "You have ram left:"
  free -h | awk 'NR==2 {print "RAM information" "\n Free: " $4"  \n Total: " $2 " \n Used: " $3 }'
  read -p "Press Enter to continue..."
}

showKernel() {
  echo "Your kernel version"
  uname -r
  read -p "Press Enter to continue..."
}

showUptime() {
  uptime -p | sed 's/^up //'
  read -p "Press Enter to continue..."
}

showUpdate() {
  echo "WARNING!

This will update your entire system."
  read -p "Do you want to continue? (y/n): " answer

  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      sudo pacman -Syu
  else
      echo "Update cancelled."
      read -p "Press Enter to continue..."
  fi
}
showExit() {
  exit
}

#starts loop

while true; do

clear

echo "========================"
echo "      Linux Check"
echo "        v0.2 Beta"
echo "========================"
echo



echo "Linux Check"
echo
echo "1. Storage"
echo "2. RAM"
echo "3. Kernel"
echo "4. Uptime"
echo "5. Update your system"
echo "6. Exit"




read -p "Press number 1-6: " input
case $input in 
  1) showStorage ;;
  2) showRam ;;
  3) showKernel ;;
  4) showUptime ;;
  5) showUpdate ;;
  6) showExit ;;
  *) echo "Invalid input. Please enter a number between 1 and 6." ;;
esac
done
