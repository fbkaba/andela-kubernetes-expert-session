#!/usr/bin/env sh
set -eu
printf '%s\n' 'Generating 5 demo traces...'
i=1
while [ "$i" -le 5 ]; do
  curl -s http://localhost:8080/api/order
  printf '\n'
  i=$((i+1))
done
printf '%s\n' 'Open Jaeger: http://localhost:16686'
