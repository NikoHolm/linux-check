#!/bin/bash
pause() {
   # every test pause function will be called after the test is completed to allow the user to read the output before returning to the main menu.
  read -p "Press Enter to continue..."
}

# Data retrieval functions

getKernelVersion() {
  uname -r
}

getOsInfo() {
    lsb_release -d | awk -F'\t' '{print $2}'
}

getStorage() {
  df -h / | awk 'NR==2 {print $2, $3, $4}'
}

getRamInfo() {
  free -h | awk 'NR==2 {print $2, $3, $4}'
}

getHostName() {
  hostname
}

getCpuInfo() {
  lscpu | awk -F: '
  /Model name/   {gsub(/^[ \t]+/, "", $2); model=$2}
  /Architecture/ {gsub(/^[ \t]+/, "", $2); arch=$2}
  $1=="CPU(s)"   {gsub(/^[ \t]+/, "", $2); cpus=$2}
  END {
    print model
    print arch
    print cpus
  }'
}



# Display functions

showStorage() {

  echo "Storage Information"
  read total used free <<< "$(getStorage)"
  echo "Total: $total"
  echo "Used:  $used"
  echo "Free:  $free"
}

showRam() {
  mapfile -t ramInfo < <(getRamInfo)

  echo "RAM Information"
  echo "Free:  ${ramInfo[0]}"
  echo "Total: ${ramInfo[1]}"
  echo "Used:  ${ramInfo[2]}"
}

showCpu() {
  mapfile -t cpuInfo < <(getCpuInfo)

  echo "CPU Information"
  echo "Model: ${cpuInfo[0]}"
  echo "Architecture: ${cpuInfo[1]}"
  echo "CPU(s): ${cpuInfo[2]}"
}



showKernel() {
  echo "Your kernel version"
  getKernelVersion
  
}

showUptime() {
  uptime -p | sed 's/^up //'
  
}

showUpdate() {
  echo "WARNING!

This will update your entire system."
  read -p "Do you want to continue? (y/n): " answer

  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      sudo pacman -Syu
  else
      echo "Update cancelled."
  fi
}

# Health check is currently not working

runHealthCheck() {
  echo "Running health check..."
  

  echo "Health check completed."
  
}


showSystemInfo() {
  echo "System Information:"
  echo "-------------------"
  echo "Hostname: $(getHostName)"
  echo "Operating System: $(getOsInfo)"
  echo "Kernel Version: $(getKernelVersion)"
  echo "CPU: $(getCpuInfo | head -n1)"
  echo "RAM: $(getRamInfo)"
  echo "Storage: $(getStorage)"
}

showExit() {
  exit
}

#starts loop

while true; do

clear

echo "========================"
echo "      Linux Check"
echo "        v0.2.5 Beta"
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
