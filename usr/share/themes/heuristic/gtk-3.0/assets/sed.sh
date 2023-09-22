#!/bin/sh
sed -i \
         -e 's/#51A2DA/rgb(0%,0%,0%)/g' \
         -e 's/#FFFFFF/rgb(100%,100%,100%)/g' \
    -e 's/#000000/rgb(50%,0%,0%)/g' \
     -e 's/#285bff/rgb(0%,50%,0%)/g' \
     -e 's/#51A2DA/rgb(50%,0%,50%)/g' \
     -e 's/#d3dae3/rgb(0%,0%,50%)/g' \
	"$@"
