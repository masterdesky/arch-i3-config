# Lock screen is a blurred version of the last frame before screenlock
img=/tmp/i3lock.png

scrot -o $img
convert $img -blur 64x5 -scale 5% -scale 2000% $img

i3lock -e -u -i $img &
