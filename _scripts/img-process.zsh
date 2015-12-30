#!/usr/bin/zsh

SRC="$1"
DST="$2"

img_filter=" -type f -iname '*.jpg'"

echo Working in $SRC

# STEP0: copy originals to the source folder
cd "$SRC"
if [[ -e 'src' ]]; then
  if [[ ! -d 'src' ]]; then
    echo 'Error, src exists but is nto a directory'
    exit 1
  fi
else
  mkdir 'src'
fi
for d in $(find . -mindepth 1 -maxdepth 1 -not -name 'orig' -not -name 'scale' -not -name 'icon' -not -name 'src' ); do
  cp -ruv "$d" src
done

MAX_FILE_SIZE=8000000
MAX_MEMORY_SIZE=512MiB

# STEP 1: Rotate all images using EXIF data
cd "$SRC/src"
STEP=orig
for f in $(find . -type f -iname '*.jpg' -o -iname ''); do
  d="../$STEP/$f"
  if [[ -f "$d" ]]; then
    continue
  fi
  # skip big files on dell mini
  s=$(wc -c < "$f")
  if [[ $s -ge $MAX_FILE_SIZE ]]; then
    echo Skip $f too big: $s
    continue
  fi
  echo "Rotate $f -> $d"
  mkdir -p $(dirname "$d")
  convert "$f" -auto-orient "$d"
done

# STEP 2, resize and compress
SIZE=500
STEP=scale
cd "$SRC/orig"
for f in $(find . -type f -iname '*.jpg'); do
  d="../$STEP/$f"
  if [[ -f "$d" ]]; then
    continue
  fi
  # skip big files on dell mini
  s=$(wc -c < "$f")
  if [[ $s -ge $MAX_FILE_SIZE ]]; then
    echo Skip $f too big: $s
    continue
  fi
  echo "Resize $f -> $d"
  mkdir -p $(dirname "$d")
  convert "$f" -resize ${SIZE}x${SIZE}^  "$d"
done

# STEP 3, icons
cd "$SRC/orig"
for SIZE in 16 32 64 128 256; do
  STEP=icon
  for f in $(find . -type f -iname '*.jpg' ! -path './pano/*'); do
    d="../$STEP/$SIZE/$f"
    if [[ -f "$d" ]]; then
      continue
    fi
    # skip big files on dell mini
    s=$(wc -c < "$f")
    if [[ $s -ge $MAX_FILE_SIZE ]]; then
      echo Skip $f too big: $s
      continue
    fi
    echo "Iconize $f -> $d"
    mkdir -p $(dirname "$d")
    convert "$f" -resize ${SIZE}x${SIZE}^ -gravity center -extent ${SIZE}x${SIZE} "$d"
  done
done

cd "$SRC"
# LAST STEP, copy all the data to the final folders

mkdir -p "$DST"
for f in $(ls "$SRC/orig"); do
  cp -rfvu "$SRC/orig/$f" "$DST";
done

for d in scale icon; do
  mkdir -p "$DST/$d"
  cp -rufv "$SRC/$d" "$DST"
done

