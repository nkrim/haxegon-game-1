#!/usr/bin/env bash

# alias
ase=/Applications/Aseprite.app/Contents/MacOS/aseprite

# directories
sprite_dir=./assets/sprites
out_dir=./data/graphics

# wire_sprite_64x64.aseprite
sprite=$sprite_dir/module_sprite_64x64.aseprite
out=$out_dir/module_sheet.png
$ase --batch \
--layer "Tile" $sprite \
--ignore-layer "Tile" \
--layer "Center/Shadow" $sprite \
--layer "Center/BG" $sprite \
--layer "Center/On" $sprite \
--ignore-layer "Center" \
--layer "Up/Shadow" $sprite \
--layer "Up/BG" --layer "Up/Default" $sprite \
--layer "Up/In" --layer "Up/Out" $sprite \
--ignore-layer "Up" \
--layer "Down/Shadow" $sprite \
--layer "Down/BG" --layer "Down/Default" $sprite \
--layer "Down/In" --layer "Down/Out" $sprite \
--ignore-layer "Down" \
--layer "Left/Shadow" $sprite \
--layer "Left/BG" --layer "Left/Default" $sprite \
--layer "Left/In" --layer "Left/Out" $sprite \
--ignore-layer "Left" \
--layer "Right/Shadow" $sprite \
--layer "Right/BG" --layer "Right/Default" $sprite \
--layer "Right/In" --layer "Right/Out" $sprite \
--ignore-layer "Right" \
--layer "Power/BG" $sprite \
--layer "Power/On" $sprite \
--sheet $out --sheet-pack