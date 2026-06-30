#!/bin/bash

getKernelVersion() {
  uname -r
}

getOsInfo() {
    lsb_release -d | awk -F'\t' '{print $2}'
}

getStorage() {
  df -h / | awk 'NR==2 {print $2, $3, $4}'
}

getStorageFreeNumber() {
  df -BG / | awk 'NR==2 {gsub("G", "", $4); print $4}'
}

getRamInfo() {
  free -h | awk 'NR==2 {print $2, $3, $7}'
}

getFreeRamNumber() {
   free -g | awk 'NR==2 {print $7}'
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
