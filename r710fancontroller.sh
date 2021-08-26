#!/bin/bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor,
# and if deemed too high send the raw IPMI command to enable dynamic fan control.
#
# Also get CPU temps from lm-sensors and adjust fan speeds according to defined
# speed % which should be set according to your needs (each CPU model will vary)
#
# Requires:
# ipmitool – apt-get install ipmitool
# 
# ----------------------------------------------------------------------------------

# IPMI SETTINGS:
# Modify to suit your needs.
# DEFAULT IP: 192.168.0.120
IPMIHOST=192.168.1.88
IPMIUSER=root
IPMIPW=calvin
IPMIEK=0000000000000000000000000000000000000000

LASTSPEED=0

function setfans () {
  speed=$1
  if [[ $speed == "auto" ]]; then
    # Enable automatic fan speed control
    if [[ "$speed" != "$LASTSPEED" ]]; then
      ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01 >/dev/null 2>&1 &
      LASTSPEED=${speed}
    fi
    echo "[`date`] `hostname` FANS: AUTO (SYS TEMP: $SYSTEMP C)"
  else
    speedhex=$(echo "obase=16; $speed" | bc)
    # Enable manual fan speed control
    if [[ "$speed" != "$LASTSPEED" ]]; then
      if [[ "$LASTSPEED" == "auto" ]] || [[ "$LASTSPEED" == "0" ]]; then
        ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00 >/dev/null 2>&1 &
      fi
      ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x${speedhex} >/dev/null 2>&1 &
      LASTSPEED=${speed}
    fi
    echo "[`date`] `hostname` FANS: ${speed}% (0x${speedhex}) (SYS TEMP: $SYSTEMP C)"
  fi
}

while [ 1 ]; do

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
SYSTEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)

if [[ $SYSTEMP > 30 ]]; then
  echo   "Warning: SysTemp too high! Activating dynamic fan control! ($SYSTEMP C)"
  #printf "Warning: SysTemp too high! Activating dynamic fan control! ($SYSTEMP C)" | systemd-cat -t R710-IPMI-TEMP
  #echo "Warning: SysTemp too high! Activating dynamic fan control! ($SYSTEMP C)" | /usr/bin/slacktee.sh -t "R710-IPMI-TEMP [$(hostname)]"
  setfans auto
elif [[ $SYSTEMP > 90 ]]; then
  setfans 100
elif [[ $SYSTEMP > 89 ]]; then
  setfans 95
elif [[ $SYSTEMP > 88 ]]; then
  setfans 90
elif [[ $SYSTEMP > 86 ]]; then
  setfans 80
elif [[ $SYSTEMP > 84 ]]; then
  setfans 60
elif [[ $SYSTEMP > 82 ]]; then
  setfans 58
elif [[ $SYSTEMP > 80 ]]; then
  setfans 56
elif [[ $SYSTEMP > 78 ]]; then
  setfans 54
elif [[ $SYSTEMP > 76 ]]; then
  setfans 52
elif [[ $SYSTEMP > 74 ]]; then
  setfans 50
elif [[ $SYSTEMP > 25 ]]; then
  setfans 15
elif [[ $SYSTEMP > 21 ]]; then
  setfans 10
else
  echo   "Temps OK (SYS: $SYSTEMP C)"
  # healthchecks.io #curl -fsS --retry 3 https://hchk.io/XXX >/dev/null 2>&1
  #printf "Temps OK (SYS: $SYSTEMP C, CPU: $CPUTEMP C)" | systemd-cat -t R710-IPMI-TEMP
  #10% good idle speed..
  setfans 5
fi

sleep 15

done

