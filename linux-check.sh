#!/bin/bash

showStorage() {

  df -h / | awk 'NR==2 {print "Storage information" "\n Free: " $4"  \n Total: " $2 " \n Used: " $5 }'
  read -p "Press Enter to continue..."
}

showRam() {

  free -h | awk 'NR==2 {print "RAM information" "\n Free: " $4"  \n Total: " $2 " \n Used: " $3 }'
  read -p "Press Enter to continue..."
}

showCpu() {

  lscpu | awk -F: '
/Model name/ {model=$2}
/Architecture/ {arch=$2}
/^CPU\(s\)/ {cpus=$2}
END {
  print "CPU information"
  print "Model:" model
  print "Architecture:" arch
  print "CPU(s):" cpus
}'
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
echo "3. CPU"
echo "4. Kernel"
echo "5. Uptime"
echo "6. Update your system"
echo "7. Exit"

read -p "Press number 1-7: " input
case $input in
  1) showStorage ;;
  2) showRam ;;
  3) showCpu ;;
  4) showKernel ;;
  5) showUptime ;;
  6) showUpdate ;;
  7) showExit ;;
  *) echo "Invalid input. Please enter a number between 1 and 7." ;;
esac
done
