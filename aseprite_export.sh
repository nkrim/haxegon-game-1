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
--layer "Diode/And_BG" $sprite \
--layer "Diode/And_On" $sprite \
--ignore-layer "Diode/And_BG" --ignore-layer "Diode/And_On" \
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
--layer "Diode/Inputs/Up/On" $sprite \
--ignore-layer "Diode/Inputs/Up" \
--layer "Diode/Inputs/Down/On" $sprite \
--ignore-layer "Diode/Inputs/Down" \
--layer "Diode/Inputs/Left/On" $sprite \
--ignore-layer "Diode/Inputs/Left" \
--layer "Diode/Inputs/Right/On" $sprite \
--ignore-layer "Diode" \
--layer "Reciever/Tool_Display" $sprite \
--layer "Reciever/Outputs/Up/BG" --layer "Reciever/Outputs/Down/BG" --layer "Reciever/Outputs/Left/BG" --layer "Reciever/Outputs/Right/BG" $sprite \
--ignore-layer "Reciever/Tool_Display" \
--layer "Reciever/BG" $sprite \
--ignore-layer "Reciever/Outputs/Up/BG" --ignore-layer "Reciever/Outputs/Down/BG" --ignore-layer "Reciever/Outputs/Left/BG" --ignore-layer "Reciever/Outputs/Right/BG" $sprite \
--ignore-layer "Reciever/BG" \
--layer "Reciever/Color_Mask" $sprite --ignore-layer "Reciever/Color_Mask" \
--layer "Reciever/Outputs/Up/On" --layer "Reciever/Outputs/Down/On" --layer "Reciever/Outputs/Left/On" --layer "Reciever/Outputs/Right/On" $sprite \
--ignore-layer "Reciever/Outputs" \
--layer "Reciever/Inputs/Up_In" $sprite --ignore-layer "Reciever/Inputs/Up_In" \
--layer "Reciever/Inputs/Down_In" $sprite --ignore-layer "Reciever/Inputs/Down_In" \
--layer "Reciever/Inputs/Left_In" $sprite --ignore-layer "Reciever/Inputs/Left_In" \
--layer "Reciever/Inputs/Right_In" $sprite --ignore-layer "Reciever/Inputs/Right_In" \
--sheet $out --sheet-pack

# tooltip_sprite_64x64.aseprite
sprite=$sprite_dir/tooltip_sprite_64x64.aseprite
out=$out_dir/tooltip_sheet.png
$ase --batch \
--layer "Tabs/Dirs/Disabled_Hover" $sprite \
--layer "Tabs/Dirs/Disabled" $sprite \
--layer "Tabs/Dirs/Enabled_Hover" $sprite \
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






