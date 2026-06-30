#!/bin/bash


pause() {

  read -p "Press Enter to continue..."
}

showBanner(){

echo "========================"
echo "      Linux Check"
echo "        v0.3 Beta"
echo "========================"
echo

}

showMenu() {

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

}