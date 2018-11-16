#!/bin/bash

for file in `ls -1`
do
  sudo sed -i 's/openhab_dom/openhab_dom/g' $file
done

