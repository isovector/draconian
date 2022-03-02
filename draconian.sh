#!/usr/bin/env bash

set -ex

curl http://web.archive.org/web/timemap/link/https://www2.gov.bc.ca/gov/content/covid-19/info/restrictions | grep -Eo 'http://.+/restrictions' > webmap

mkdir html
mkdir md

# cat webmap | grep -Eo '[0-9]{14}' | grep -Eo '^.{8}' | uniq > days

rm slugs
while read DAY; do
  URL=$(cat webmap | grep "/$DAY" | head -n1 )
  SLUG=$(echo $URL | grep -Eo '[0-9]{14}')
  HTML="html/${SLUG}.html"

  echo $SLUG >> slugs

  curl -o $HTML $URL || curl -o $HTML $URL || curl -o $HTML $URL || curl -o $HTML $URL || curl -o $HTML $URL
  sed -i "s/${SLUG}//g" $HTML

  pandoc -f html -t markdown -o md/${SLUG}.md $HTML
  sleep 2
done < days

find md -name '*' -size 1 -print0 | xargs -0 rm

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

mkdir res
cd res
git init
cd ..

while read SLUG; do
  cp md/$SLUG.md res/pho.md
  cd res
  git add pho.md
  git commit -m "Update for $SLUG"
  cd ..
done < slugs
