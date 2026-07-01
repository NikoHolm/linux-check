#!/bin/bash

# ----------------------------------------------------------------------------
# 5. SCREENS  (draw a full panel using the helpers above)
# ----------------------------------------------------------------------------

showStorage() {
  screen_header
  local total used free
  read -r total used free <<< "$(getStorage)"
  ui_top "STORAGE"
  ui_kv "Total" "$total"
  ui_kv "Used"  "$used"
  ui_kv "Free"  "$free"
  ui_bottom
}

showRam() {
  screen_header
  local total used avail
  read -r total used avail <<< "$(getRamInfo)"
  ui_top "MEMORY"
  ui_kv "Total"     "$total"
  ui_kv "Used"      "$used"
  ui_kv "Available" "$avail"
  ui_bottom
}

showCpu() {
  screen_header
  local cpu; mapfile -t cpu < <(getCpuInfo)
  ui_top "CPU"
  ui_kv "Model" "${cpu[0]}"
  ui_kv "Arch"  "${cpu[1]}"
  ui_kv "Cores" "${cpu[2]}"
  ui_bottom
}

showKernel() {
  screen_header
  ui_top "KERNEL"
  ui_kv "Release" "$(getKernelVersion)"
  ui_bottom
}

showUptime() {
  screen_header
  ui_top "UPTIME"
  ui_kv "Up for" "$(uptime -p | sed 's/^up //')"
  ui_bottom
}

showSystemInfo() {
  screen_header
  local total used free cpu
  read -r total used free <<< "$(getStorage)"
  mapfile -t cpu < <(getCpuInfo)
  ui_top "SYSTEM INFORMATION"
  ui_kv "Hostname" "$(getHostName)"
  ui_kv "OS"       "$(getOsInfo)"
  ui_kv "Kernel"   "$(getKernelVersion)"
  ui_kv "CPU"      "${cpu[0]}"
  ui_kv "Cores"    "${cpu[2]}"
  ui_kv "RAM"      "$(getRamInfo)"
  ui_kv "Storage"  "$total total, $free free"
  ui_kv "Uptime"   "$(uptime -p | sed 's/^up //')"
  ui_bottom
}

runHealthCheck() {
  screen_header
  ui_top "HEALTH CHECK"
  checkStorage
  checkRam
  checkServices
  checkInternet
  ui_bottom
}

showUpdate() {
  screen_header
  ui_top "SYSTEM UPDATE"
  ui_row "${YELLOW}${BOLD}[WARNING]${RESET}"
  ui_row "${FG}This will update every package on your system.${RESET}"
  ui_blank
  ui_row "${MUTED}command: sudo pacman -Syu${RESET}"
  ui_bottom
  printf '\n'
  read -rp "  Continue? (y/N) " answer
  if [[ "$answer" == [yY] ]]; then
    printf '\n'
    sudo pacman -Syu
  else
    printf '\n  %sUpdate cancelled.%s\n' "$MUTED" "$RESET"
  fi
}

