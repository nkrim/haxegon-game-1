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

# tooltip_sprite_64x64.aseprite
sprite=$sprite_dir/tooltip_sprite_64x64.aseprite
out=$out_dir/tooltip_sheet.png
$ase --batch \
--layer "Tabs/Dirs/Disabled" $sprite \
--layer "Tabs/Dirs/Enabled" $sprite \
--ignore-layer "Tabs/Dirs" \
--layer "Tabs/Toggle/Disabled" $sprite \
--layer "Tabs/Toggle/Enabled" $sprite \
--ignore-layer "Tabs/Toggle" \
--layer "Tabs/Rotation/Disabled" $sprite \
--layer "Tabs/Rotation/Enabled" $sprite \
--ignore-layer "Tabs/Rotation" \
--layer "Main/BG_Disabled" $sprite \
--ignore-layer "Main/BG_Disabled" --layer "Main/BG" $sprite \
--ignore-layer "Main/BG" \
--layer "Settings/Dirs/BG" --layer "Settings/Dirs/Outline" $sprite \
--ignore-layer "Settings/Dirs/BG" --ignore-layer "Settings/Dirs/Outline" \
--layer "Settings/Dirs/Disabled/Up" $sprite --ignore-layer "Settings/Dirs/Disabled/Up" \
--layer "Settings/Dirs/Disabled/Down" $sprite --ignore-layer "Settings/Dirs/Disabled/Down" \
--layer "Settings/Dirs/Disabled/Left" $sprite --ignore-layer "Settings/Dirs/Disabled/Left" \
--layer "Settings/Dirs/Disabled/Right" $sprite --ignore-layer "Settings/Dirs/Disabled/Right" \
--ignore-layer "Settings/Dirs" \
--sheet $out --sheet-pack






