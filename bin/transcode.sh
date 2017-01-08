#!/usr/bin/env bash

input=$1
output=$2

set -euo pipefail

if [ -z $input ]; then
  >&2 echo "usage: $(basename $0) <input> [output]"
  exit 1
fi

if [ -z $output ]; then
  output=$(basename $input)
fi

if [[ $input =~ "http://" ]] || [[ $input =~ "https://" ]]; then
  input="/vsicurl/$input"
fi

echo "Transcoding bands..."
gdal_translate \
  -b 1 \
  -b 2 \
  -b 3 \
  -mask 4 \
  -co TILED=yes \
  -co COMPRESS=JPEG \
  -co PHOTOMETRIC=YCbCr \
  -co BLOCKXSIZE=512 \
  -co BLOCKYSIZE=512 \
  -co NUM_THREADS=ALL_CPUS \
  $input $output

height=$(rio info $input 2> /dev/null | jq .height)
width=$(rio info $input 2> /dev/null | jq .width)
zoom=$(get_zoom.py $input)
overviews=""

for z in $(seq 1 $zoom); do
  if [ $[$height / $[2 ** $[$z + 1]]] -lt 1 ]; then
    break
  fi

  overviews="${overviews} $[2 ** $z]"
done

echo "Adding overviews..."
gdaladdo \
  -r lanczos \
  --config GDAL_TIFF_OVR_BLOCKSIZE 512 \
  --config TILED_OVERVIEW yes \
  --config COMPRESS_OVERVIEW JPEG \
  --config PHOTOMETRIC YCBCR \
  --config BLOCKXSIZE_OVERVIEW 512 \
  --config BLOCKYSIZE_OVERVIEW 512 \
  --config NUM_THREADS_OVERVIEW ALL_CPUS \
  $output \
  $overviews

echo "Adding overviews to mask..."
gdaladdo \
  --config GDAL_TIFF_OVR_BLOCKSIZE 512 \
  --config TILED_OVERVIEW yes \
  --config COMPRESS_OVERVIEW DEFLATE \
  --config BLOCKXSIZE_OVERVIEW 512 \
  --config BLOCKYSIZE_OVERVIEW 512 \
  --config SPARSE_OK_OVERVIEW yes \
  --config NUM_THREADS_OVERVIEW ALL_CPUS \
  $output.msk \
  $overviews