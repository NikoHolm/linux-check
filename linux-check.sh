#!/bin/bash

showStorage() {
  echo "You have this much storage left" 
  df -h /
  read -p "Press Enter to continue..."
}

showRam() {
  echo "You have ram left:"
  free -h
  read -p "Press Enter to continue..."
}

showKernel() {
  echo "Your kernel version"
  uname -r
  read -p "Press Enter to continue..."
}

showUptime() {
  echo "Uptime"
  uptime
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

#starts loop


read -p "Press number 1-6: " input

if [ "$input" -eq 1 ]; then
    showStorage
elif [ "$input" -eq 2 ]; then
    showRam
elif [ "$input" -eq 3 ]; then
    showKernel
elif [ "$input" -eq 4 ]; then
    showUptime
elif [ "$input" -eq 5 ]; then
    showUpdate
elif [ "$input" -eq 6 ]; then
    showExit

else 
    echo "Invalid choice. Please enter a number between 1 and 6."
    read -p "Press Enter to continue..."
fi
done    




