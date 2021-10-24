#!/bin/csh -f
set inroot = "/media/rosinski/My Passport/Pictures/FallColors2021"
set outroot = .
echo -n "Enter Pic: "
#read pic < /dev/stdin
set pic = $<
convert -resize 1000x750 "${inroot}"/${pic}.JPG ${outroot}/${pic}.1000x750.JPG
convert -resize 160x120 "${inroot}"/${pic}.JPG ${outroot}/${pic}.160x120.JPG
