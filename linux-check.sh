#!/bin/bash

while true; do

clear

echo "========================"
echo "      Linux Check"
echo "        v0.1 Beta"
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

  echo "You have this much storage left" 
  df -h /
  read -p "Press Enter to continue..."
  

elif [ "$input" -eq 2 ]; then
  echo "You have ram left:"
  free -h
  read -p "Press Enter to continue..."
  
elif [ "$input" -eq 3 ]; then

  echo "Your kernel version"
  uname -r
  read -p "Press Enter to continue..."
  

elif [ "$input" -eq 4 ]; then

  echo "Uptime"
  uptime
  read -p "Press Enter to continue..."
  
  elif [ "$input" -eq 5 ]; then

  echo "WARNING!

This will update your entire system."

read -p "Do you want to continue? (y/n): " answer

if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then

    sudo pacman -Syu

else
    echo "Update cancelled."
    read -p "Press Enter to continue..."
fi



elif [ "$input" -eq 6 ]; then

exit

else 
    echo "Invalid choice. Please enter a number between 1 and 6."
fi
done    




