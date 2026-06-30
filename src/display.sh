#!/bin/bash

showStorage() {

  echo "Storage Information"
  read total used free <<< "$(getStorage)"
  echo "Total: $total"
  echo "Used:  $used"
  echo "Free:  $free"
}

showRam() {
  read total used free <<< "$(getRamInfo)"

  echo "RAM Information"
  echo "Free:  $free"
  echo "Total: $total"
  echo "Used:  $used"
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
  checkStorage
  checkRam
  checkFailedServices
  checkInternetConnection
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