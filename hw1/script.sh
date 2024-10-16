#!/bin/bash

# $1 - file to write
function write_data_in_file {
  disk="$(df -h | awk 'NR==2 {print $3}')" # -i option is now the default to conform to Version3 of the Single UNIX Specification (“SUSv3”)
  inodes="$(df | awk 'NR==2 {print $7}')"
  echo -e "Used, Ifree \n$disk, $inodes" > "$1"
}

function process  {
  prev_timestamp=
  prev_day=
    while true; do
      next_timestamp="$(date '+%Y-%m-%d_%H:%M:%S')"
      next_day="$(date '+%Y-%m-%d')"
      if [[ -n "$prev_timestamp" ]] && [[  "$prev_day" == "$next_day"  ]]; then
        rm ./data_"$prev_timestamp".txt > /dev/null
      fi
      write_data_in_file ./data_"$next_timestamp".txt
      prev_timestamp="$next_timestamp"
      prev_day="$next_day"
      sleep 100
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