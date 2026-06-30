#!/bin/bash

checkStorage() {
  free=$(getStorageFreeNumber)

  if [ "$free" -ge 30 ]; then
    echo "Storage: OK - ${free}G free"
  else
    echo "Storage: FAILED - only ${free}G free"
  fi
}

checkRam() {
  mapfile -t ramInfo < <(getFreeRamNumber)
  freeRam=${ramInfo[0]}

  if [ "$freeRam" -ge 4 ]; then
    echo "RAM: OK - ${freeRam}G free"
  else
    echo "RAM: FAILED - only ${freeRam}G free"
  fi
}

checkFailedServices() {
    failed=$(systemctl --failed --no-legend | wc -l)

    if [ "$failed" -eq 0 ]; then
        echo "Services: OK"
    else
        echo "Services: FAILED ($failed failed services)"
    fi
}

checkInternetConnection() {

    if ping -c 1 1.1.1.1 &> /dev/null; then
        echo "Internet: OK"
    else
        echo "Internet: FAILED"
        return
    fi

    if ping -c 1 google.com &> /dev/null; then
        echo "DNS: OK"
    else
        echo "DNS: FAILED"
    fi
}