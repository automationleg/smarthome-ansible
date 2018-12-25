#!/bin/bash

for file in `ls -1 *.json`
do
  sudo sed -i 's/${DS_OPENHAB_DOM}/openhab_dom/g' $file
done

