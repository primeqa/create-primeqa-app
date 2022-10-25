#!/usr/bin/env bash

# Check if docker-compose exist, if not exit
if [[ ! -x "$(command -v docker-compose)" ]]; then
  echo "This script uses docker-compose, and it can't run it - please make sure it is installed and try again!"
  exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo "This script uses docker, and it isn't running - please start docker and try again!"
  exit 1
fi

mode=gpu

while :; do
  case $1 in
    -h|-\?|--help)
      echo "Usage: $0 [-m|--mode <gpu|cpu>]"    # Display a usage synopsis.
      exit
      ;;
    -m|--mode)
      if [ "$2" ]; then
        mode=$2
        shift
      else
        die 'ERROR: "--mode" requires a non-empty option argument.'
      fi
      ;;
    --m|--mode=?*)
      mode=${1#*=} # Delete everything up to "=" and assign the remainder.
      ;;
    --mode=)         # Handle the case of an empty --mode=
      die 'ERROR: "--mode" requires a non-empty option argument.'
      ;;
    --)            # End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)             # Default case: No more options, so break out of the loop.
      break
  esac

  shift
done


echo "=========================================================================="
echo "Testing support for mode=${mode}"
echo "=========================================================================="
# Check if nvidia driver's exist for gpu mode
if [[ $mode = gpu && ! -x "$(command -v nvidia-smi)" ]]; then
  echo "Error: nvidia-smi is not installed."
  echo 'Switching to "CPU" mode'
  mode=cpu
fi
echo "=========================================================================="
echo "Terminating and cleaning containers"
echo "=========================================================================="
docker-compose -f docker-compose-${mode}.yaml down
