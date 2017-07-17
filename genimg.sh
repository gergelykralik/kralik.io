#!/usr/bin/env bash

createImage() {
    #mkdir ${1} 2>&1 >> /dev/null
    convert -background gray20 -fill ivory2 -font Fira-Mono -pointsize 50 -size 1000x400 -gravity South \
        -border 100 -bordercolor gray20 caption:"${2}

                     kralik.io
" \
        ${1}/post.png
}

cd source/_posts

for file in *.md; do
    fn=$(echo ${file:0:-3})
    fc=$(cat $file | head -2 | tail -1 | cut -c8-)
    createImage "${fn}" "$fc"

done
exit 0

