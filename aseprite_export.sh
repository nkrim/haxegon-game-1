#!/usr/bin/env bash

# alias
ase=/Applications/Aseprite.app/Contents/MacOS/aseprite

# directories
sprite_dir=./assets/sprites
out_dir=./data/graphics

# wire_sprite_64x64.aseprite
sprite=$sprite_dir/wire_sprite_64x64.aseprite
out=$out_dir/wire_sheet.png
$ase --batch \
--layer "Tile" $sprite \
--ignore-layer "Tile" \
--layer "Center/BG" $sprite \
--layer "Center/On" $sprite \
--ignore-layer "Center" \
--layer "Up/BG" --layer "Up/Default" $sprite \
--layer "Up/In" $sprite \
--layer "Up/Out" $sprite \
--ignore-layer "Up/In" $sprite \
--ignore-layer "Up" \
--layer "Down/BG" --layer "Down/Default" $sprite \
--layer "Down/In" $sprite \
--layer "Down/Out" $sprite \
--ignore-layer "Down/In" $sprite \
--ignore-layer "Down" \
--layer "Left/BG" --layer "Left/Default" $sprite \
--layer "Left/In" $sprite \
--layer "Left/Out" $sprite \
--ignore-layer "Left/In" $sprite \
--ignore-layer "Left" \
--layer "Right/BG" --layer "Right/Default" $sprite \
--layer "Right/In" $sprite \
--layer "Right/Out" $sprite \
--ignore-layer "Right/In" $sprite \
--sheet $out --sheet-pack