#!/bin/bash


# ----------------------------------------------------------------------------
# 3. DATA  (collect raw values only - no printing, no judging)
# ----------------------------------------------------------------------------

getKernelVersion() { uname -r; }

getOsInfo() {
  # Subshell keeps the sourced variables out of the rest of the script.
  ( . /etc/os-release 2>/dev/null; printf '%s\n' "${PRETTY_NAME:-Unknown}" )
}

getHostName() { hostname; }

getStorage() { df -h / | awk 'NR==2 {print $2, $3, $4}'; }

getStorageFreeNumber() { df -BG / | awk 'NR==2 {gsub("G", "", $4); print $4}'; }

getRamInfo() { free -h | awk 'NR==2 {print $2, $3, $7}'; }

getFreeRamNumber() { free -g | awk 'NR==2 {print $7}'; }

getCpuInfo() {
  lscpu | awk -F: '
    /Model name/   {gsub(/^[ \t]+/, "", $2); model=$2}
    /Architecture/ {gsub(/^[ \t]+/, "", $2); arch=$2}
    $1=="CPU(s)"   {gsub(/^[ \t]+/, "", $2); cpus=$2}
    END { print model; print arch; print cpus }'
}
