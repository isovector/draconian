#!/usr/bin/env bash

curl http://web.archive.org/web/timemap/link/https://www2.gov.bc.ca/gov/content/covid-19/info/restrictions | grep -Eo 'http://.+/restrictions' > webmap

mkdir html
mkdir md

cat webmap | grep -Eo '[0-9]{14}' | grep -Eo '^.{8}' | uniq > days

while read DAY; do
  URL=$(cat webmap | grep "/$DAY" | head -n1 )
  SLUG=$(echo $URL | grep -Eo '[0-9]{14}')
  curl $URL | sed "s/${SLUG}//g" > html/${SLUG}.html
  pandoc -f html -t markdown -o md/${SLUG}.md html/${SLUG}.html &
done < days

for MD in md/*.md; do
  sed -i '/^ *:::/d' $MD
  sed -i '/div>/d' $MD
  sed -i 's/\[[^\]*]\]{[^}]*}//' $MD
  sed -i -n '/^!\[Share/q;p' $MD
  sed -i '0,/{#main-content-anchor/d' $MD
  sed -i 's/([/h#][^)]*)//g' $MD
  sed -i 's/{[#.][^}]*}//g' $MD
  sed -i 's/\[\]//g' $MD
done
