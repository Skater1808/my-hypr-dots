#!/bin/bash

# 1. Pfad zu Ihrem Wallpaper-Ordner
WALLPAPER_DIR="$HOME/Pictures/Wallpaper/"

# 2. Alle unterstützten Bilder alphabetisch sortiert in ein Array einlesen
mapfile -d '' WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 | sort -z)

# Falls der Ordner leer ist, abbrechen
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  echo "Keine Bilder im Ordner $WALLPAPER_DIR gefunden!"
  exit 1
fi

# 3. Das aktuell aktive Wallpaper über awww ermitteln
CURRENT_WALL=$(awww query | grep -o '/home/emil/Pictures/Wallpaper/[^ ]*' | head -n 1)

# Index des nächsten Bildes bestimmen
NEXT_INDEX=0

if [ -n "$CURRENT_WALL" ]; then
  # Suche die Position des aktuellen Bildes im Array
  for i in "${!WALLPAPERS[@]}"; do
    if [ "${WALLPAPERS[$i]}" = "$CURRENT_WALL" ]; then
      # Wenn gefunden, nimm das nächste Element
      NEXT_INDEX=$(((i + 1) % ${#WALLPAPERS[@]}))
      break
    fi
  done
fi

# 4. Das nächste Wallpaper in der Reihenfolge setzen
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# Schaltet das Bild mit einer flüssigen Wisch-Animation um
awww img "$NEXT_WALLPAPER" --transition-type wipe --transition-angle 30 --transition-step 90

# 5. Farben mit wallust generieren (nutzt ~/.config/wallust/wallust.toml Templates)
# Erzeugt: ~/.config/kitty/colors.conf, ~/.config/waybar/style.css, ~/.config/wofi/style.css
wallust run "$NEXT_WALLPAPER"

# Kitty reload (sendet SIGUSR1 an alle kitty Prozesse, lädt colors.conf neu)
pkill -SIGUSR1 kitty

# Waybar neu laden via SIGUSR2 (oder Neustart falls nicht läuft)
pkill -SIGUSR2 waybar 2>/dev/null || (pkill waybar 2>/dev/null && waybar &)

# Wofi/Rofi braucht keinen Reload - liest style.css beim nächsten Start neu ein

# QuickShell liest ~/.cache/wal/colors.json live ein (watchChanges),
# ein Neustart ist nicht mehr nötig. Bar nur starten, falls sie nicht läuft.
pgrep -x quickshell >/dev/null || quickshell -c /home/emil/.config/quickshell >/dev/null 2>&1