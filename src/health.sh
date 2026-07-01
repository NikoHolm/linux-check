#!/bin/bash

# ----------------------------------------------------------------------------
# 4. HEALTH  (turn a raw value into an OK / WARN / FAIL row)
# ----------------------------------------------------------------------------

checkStorage() {
  local free; free=$(getStorageFreeNumber)
  if ((free >= 30)); then
    ui_status "Storage" ok "${free}G free"
  else
    ui_status "Storage" fail "only ${free}G free"
  fi
}

checkRam() {
  local free; free=$(getFreeRamNumber)
  if ((free >= 4)); then
    ui_status "Memory" ok "${free}G free"
  else
    ui_status "Memory" fail "only ${free}G free"
  fi
}

checkServices() {
  local failed; failed=$(systemctl --failed --no-legend | wc -l)
  if ((failed == 0)); then
    ui_status "Services" ok "no failed units"
  else
    ui_status "Services" fail "$failed failed unit(s)"
  fi
}

checkInternet() {
  if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    ui_status "Internet" ok "reachable"
    if ping -c 1 -W 2 google.com &>/dev/null; then
      ui_status "DNS" ok "names resolve"
    else
      ui_status "DNS" fail "cannot resolve names"
    fi
  else
    ui_status "Internet" fail "no connection"
  fi
}

