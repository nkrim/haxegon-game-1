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
--ignore-layer "Power" \
--layer "Bridge/BG" $sprite \
--layer "Bridge/On_Horiz" $sprite \
--layer "Bridge/On_Vert" $sprite \
--ignore-layer "Bridge/On_Horiz" $sprite \
--ignore-layer "Bridge" \
--layer "Diode/BG" $sprite \
--layer "Diode/On" $sprite \
--ignore-layer "Diode/BG" --ignore-layer "Diode/On" \
--layer "Diode/Outputs/Up/BG" $sprite \
--layer "Diode/Outputs/Up/On" $sprite \
--ignore-layer "Diode/Outputs/Up" \
--layer "Diode/Outputs/Down/BG" $sprite \
--layer "Diode/Outputs/Down/On" $sprite \
--ignore-layer "Diode/Outputs/Down" \
--layer "Diode/Outputs/Left/BG" $sprite \
--layer "Diode/Outputs/Left/On" $sprite \
--ignore-layer "Diode/Outputs/Left" \
--layer "Diode/Outputs/Right/BG" $sprite \
--layer "Diode/Outputs/Right/On" $sprite \
--ignore-layer "Diode/Outputs/Right" \
--layer "Diode/Inputs/Up/BG" $sprite \
--layer "Diode/Inputs/Up/On" $sprite \
--ignore-layer "Diode/Inputs/Up" \
--layer "Diode/Inputs/Down/BG" $sprite \
--layer "Diode/Inputs/Down/On" $sprite \
--ignore-layer "Diode/Inputs/Down" \
--layer "Diode/Inputs/Left/BG" $sprite \
--layer "Diode/Inputs/Left/On" $sprite \
--ignore-layer "Diode/Inputs/Left" \
--layer "Diode/Inputs/Right/BG" $sprite \
--layer "Diode/Inputs/Right/On" $sprite \
--ignore-layer "Diode" \
--sheet $out --sheet-pack