#!/usr/bin/env bash

# Initialize all the option variables.
mode=cpu

while :; do
  case $1 in
    -h|-\?|--help)
      echo "Usage: $0 [-r|--reload] [-m|--mode <gpu|cpu>]"    # Display a usage synopsis.
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

# Check if docker exist, if not exit
if ! docker info > /dev/null 2>&1; then
  echo "This script uses docker, and it isn't running - please start docker and try again!"
  exit 1
fi

# Check if docker-compose exist, if not exit
if [[ ! -x "$(command -v docker-compose)" ]]; then
  echo "This script uses docker-compose, and it can't run it - please make sure it is installed and try again!"
  exit 1
fi

echo "=========================================================================="
echo "Testing support for mode=${mode}"
echo "=========================================================================="
# Check if nvidia driver's exist for gpu mode
if [[ $mode = gpu && ! -x "$(command -v nvidia-smi)" ]]; then
  echo "Error: nvidia-smi is not installed."
  echo 'Switching to "CPU" mode'
  mode=cpu
fi

# Check if PUBLIC_IP environment variable is set, if not exit
if [[ -z "${PUBLIC_IP}" ]]; then
  echo "PUBLIC_IP environment variable is not set. Please find your machine's public ip and set it to PUBLIC_IP."
  exit 1
fi

# Set write permission for primeqa-store, orchestrator-store, cache
chmod -R 777 primeqa-store orchestrator-store cache

echo "=========================***  START RUNTIME   ***========================="
echo "=========================================================================="
docker-compose -f docker-compose-${mode}.yaml up -d 

echo "=========================================================================="
echo "Testing containers availability ..."
echo "=========================================================================="
if ! docker ps -f name=primeqa-service -q > /dev/null 2>&1; then
  echo "PrimeQA service container failed to start. Terminating other containers ..."
  docker-compose -f docker-compose-${mode}.yaml down
  echo "Please contact IBM Research for technical assistance!"
  exit 1
fi

if ! docker ps -f name=primeqa-orchestrator -q > /dev/null 2>&1; then
  echo "Server container failed to start. Terminating other containers ..."
  docker-compose -f docker-compose-${mode}.yaml down
  echo "Please contact IBM Research for technical assistance!"
  exit 1
fi

if ! docker ps -f name=primqa-ui -q > /dev/null 2>&1; then
  echo "Application container failed to start. Terminating other containers ..."
  docker-compose -f docker-compose-${mode}.yaml down
  echo "Please contact IBM Research for technical assistance!"
  exit 1
fi

echo "Run 'docker ps' command to confirm that the service/orchestrator/ui containers are running"
echo "IMPORTANT: Please configure the services as specified in the README.md"
echo "After configuration, please open a browser (Mozilla Firefox/Google Chrome) and visit http://${PUBLIC_IP}:800"
echo "===============================***  END   ***==============================================================="