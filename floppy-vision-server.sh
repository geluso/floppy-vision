#!/bin/bash
SAVEIFS=$IFS
IFS=$'\n'

function cleanup () {
  IFS=$SAVEIFS
  exit 0
}

trap cleanup SIGINT SIGTERM

function total_volume_count() {
  ls /Volumes | wc | tr -s ' ' | cut -d ' ' -f 2
}

function floppy_volume_count() {
  count=0
  for volume in `ls /Volumes` ; do
    blocks=$(df "/Volumes/$volume" | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
    if [[ $blocks = 2847 ]] ; then
      count=$(($count + 1))
    fi
  done
  echo $count
}

function kill_vlc() {
  vlc_pid=$(ps -ef | grep VLC | grep -v grep | tr -s ' ' | cut -d ' ' -f 3)
  [[ ! -z $vlc_pid ]] && kill $vlc_pid
}

function play_floppy() {
  for volume in `ls /Volumes` ; do
    blocks=$(df "/Volumes/$volume" | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
    if [[ $blocks = 2847 ]] ; then
      for line in `cat "/Volumes/$volume/index.txt"` ; do
        open -a /Applications/VLC.app "$line"
      done
      break
    fi
  done
}

function is_floppy() {
  blocks=$(df "/Volumes/$1" | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
  if [[ $blocks = 2847 ]] ; then
    return 0
  else
    return 1
  fi
}

echo "   __ _                                 _     _                               "
echo "  / _| |                               (_)   (_)              ________________"
echo " | |_| | ___  _ __  _ __  _   _  __   ___ ___ _  ___  _ __   |[]             |"
echo " |  _| |/ _ \| '_ \| '_ \| | | | \ \ / / / __| |/ _ \| '_ \  |  __________   |"
echo " | | | | (_) | |_) | |_) | |_| |  \ V /| \__ \ | (_) | | | | |  |King of |   |"
echo " |_| |_|\___/| .__/| .__/ \__, |   \_/ |_|___/_|\___/|_| |_| |  |The Hill|   |"
echo "             | |   | |       | |                             |  |________|   |"
echo "             | |   | |       | |                             |   ________    |"
echo "             | |   | |     __/ |                             |   [ [ ]  ]    |"
echo "             |_|   |_|    |___/                              \___[_[_]__]____|"
echo
echo "waiting for floppy..."

is_playing=false
while true ; do
  floppies=$(floppy_volume_count)
  if [[ $is_playing = true ]] ; then
    if [[ $floppies = 0 ]]; then
      echo "floppy ejected"
      is_playing=false
      kill_vlc
    fi
  else
    if [[ $floppies = 1 ]]; then
      echo "floppy inserted"
      is_playing=true
      play_floppy
    fi
  fi

  sleep 1
done
