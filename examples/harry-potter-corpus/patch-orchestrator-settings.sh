#! /usr/bin/env bash

readonly PUBLIC_IP=${1:-127.0.0.1}

curl -s -o /dev/null -w "%{http_code}" -X 'PATCH' \
  "http://${PUBLIC_IP}:50059/settings" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "retrievers": {
    "PrimeQA": {
      "service_endpoint": "primeqa:50051"
    },
    "alpha": 0.8
  },
  "readers": {
    "PrimeQA": {
      "service_endpoint": "primeqa:50051",
      "beta": 0.7
    }
  }
}'

echo
