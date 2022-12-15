#}!/bin/bash
SAVEIFS=$IFS
IFS=$'\n'

# an exact size we expect floppies to be.
FLOPPY_BLOCKS_SIZE=1424

# a looser definition of how large we expect floppies to be.
# anything smaller than this size will be considered a floppy.
# this accounts for a strange thing where floppies appeared as a size of 2847
MAX_FLOPPY_BLOCKS_SIZE=10000

set found_floppy_volume

function cleanup () {
  IFS=$SAVEIFS
  exit 0
}

trap cleanup SIGINT SIGTERM

function index() {
  tr -s ' ' | cut -d ' ' -f $1
}

function find_floppy_volume() {
  for volume in `ls /Volumes` ; do
    # there is a bug here where it miscounts what column to read the
    # block size at if the volume name is more than one word.
    blocks=$(df "/Volumes/$volume" | tail -n 1 | index 2)
    if [[ $blocks = $FLOPPY_BLOCKS_SIZE ]] ; then
      found_floppy_volume=$volume
      return
    fi
  done
  unset found_floppy_volume
}

function kill_vlc() {
  vlc_pid=$(ps -ef | grep VLC | grep -v grep | index 3)
  [[ ! -z $vlc_pid ]] && kill $vlc_pid
}

function play_floppy() {
  index_file="/Volumes/$found_floppy_volume/index.txt"
  random_video=`shuf -n 1 $index_file`
  echo "random video name: $random_video"
  open -a /Applications/VLC.app "$random_video" --args -f
}

function is_floppy() {
  blocks=$(df "/Volumes/$1" | tail -n 1 | index 2)
  if [[ $blocks = $FLOPPY_BLOCKS_SIZE ]] ; then
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
  find_floppy_volume
  if [[ $is_playing = true ]] ; then
    if [ -z "$found_floppy_volume" ]; then
      echo "floppy ejected"
      unset found_floppy_volume
      is_playing=false
      kill_vlc
    fi
  else
    if [ ! -z "$found_floppy_volume" ]; then
      echo "floppy inserted"
      is_playing=true
      play_floppy
    fi
  fi

  sleep 1
done
