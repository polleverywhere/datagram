#! /bin/bash

# Build script to compile Hamlet templates
cd lib/datagram/public/templates

for file in *.haml; do
  haml-jr < $file > ${file/.haml}.js
done

for file in *.js; do
  echo "(window.JST || (window.JST = {}))['${file/.js}'] = " > tmpfile
  cat $file >> tmpfile
  mv tmpfile $file
done

cat *.js > ../templates.js
rm *.js