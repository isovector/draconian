#!/usr/bin/env bash

# curl http://web.archive.org/web/timemap/link/https://www2.gov.bc.ca/gov/content/covid-19/info/restrictions | grep -Eo 'http://.+/restrictions' > webmap

mkdir html
mkdir md

while read URL; do
  SLUG=$(echo $URL | grep -Eo '[0-9]{14}')
  curl $URL > html/${SLUG}.html
  sleep 1
done < webmap
