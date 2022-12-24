#!/bin/sh

for filepath in ./src/*.yaml; do
  filename="$(basename "$filepath")"
  ./build1.sh $filename
done
