#!/bin/bash

# By:  Saifullah Balghari

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_your_wallpaper>"
    exit 1
fi

# Generate pywal colors from the wallpaper
echo "Generating pywal colors..."
wal -i "$1"
echo "Generated pywal colors"

# Reload with the new colors
echo "Reloading waybar, hyprland and dunst..."
pkill waybar
waybar &
echo "Successfully reloaded waybar and dunst"

sleep 0.2
echo "Running script..."
# This will convert wal color (color11 and color0) into ARGB for hyprland's borders
~/.config/hypr/scripts/update_hyprland_colors.sh

# This will store a blured version of the current wallpaper for hyprlock's background
~/.config/hypr/scripts/cache_wallpaper.sh "$1"

# This will apply wal colors to dunst the notification daemon
~/.config/hypr/scripts/update_dunst_color.sh
echo "Successfully ran the scripts"

pkill dunst && dunst &
hyprctl reload