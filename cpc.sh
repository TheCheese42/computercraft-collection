# CPC = Copy Contents
# Copies both contents/ and flash/ to the target disk.
# Expects path to disk.
# Example: ~/.minecraft/saves/Test/computercraft/disk/0/

rm -rf "$1/contents"
cp -r contents/ "$1"
rm -rf "$1/flash"
cp -r flash/* "$1"
