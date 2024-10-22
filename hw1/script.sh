#!/bin/bash

function process_cur_day {
    day_of_creation="$(date '+%Y-%m-%d')"
    time_of_creation="$(date '+%H:%M:%S')"
    file="./data_${day_of_creation}_${time_of_creation}.txt"
    echo -e "Used, Ifree, Timestamp" > "$file"
    while [[ "$day_of_creation" == "$(date '+%Y-%m-%d')" ]]; do
      timestamp_with_date="$(date '+%H:%M:%S')"
      disk="$(df -h | awk 'NR==2 {print $3}')" # -i option is now the default to conform to Version3 of the Single UNIX Specification (“SUSv3”)
      inodes="$(df | awk 'NR==2 {print $7}')"
      echo -e "$disk, $inodes, $timestamp_with_date" >> "$file"
      sleep 15
    done
}

function process  {
    while true; do
      process_cur_day
    done
}

function start {
  if [[ -f "pid.txt" ]]; then
    echo "PID: $(cat pid.txt)"
  else
    process &
    echo $! > pid.txt && echo "PID: $(cat pid.txt)"
  fi
}

function status {
  if [[ -f "pid.txt" ]]; then
    if ps -p "$(cat pid.txt)" > /dev/null; then
      echo "WORKING. PID IS $(cat pid.txt)"
    fi
  else
    echo "NOT WORKING"
  fi
}

function stop {
  if [[ -f "pid.txt" ]]; then
    kill "$(cat pid.txt)"
    rm pid.txt > /dev/null
    echo "STOPPED"
  fi
}


case "$1" in
  START)
      start
      ;;
  STOP)
      stop
      ;;
  STATUS)
      status
      ;;
  *)
      echo "HELP: argument must be one of {START|STOP|STATUS}"
      ;;
esac