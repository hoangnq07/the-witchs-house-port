#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/the_witchs_house"
CONFDIR="$GAMEDIR/conf"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY 2>/dev/null

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

# Ensure the conf directory exists
mkdir -p "$CONFDIR"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

FOLDER="gamedata"

echo "Launching The Witch's House..."

if [ -d "$GAMEDIR/$FOLDER" ]; then
    cp -f falcon_mkxp.bin "$GAMEDIR/$FOLDER/falcon_mkxp.bin"
    cp -f mkxp.conf "$GAMEDIR/$FOLDER/mkxp.conf"
    chmod +x "$GAMEDIR/$FOLDER/falcon_mkxp.bin"

    # CPU/GPU governor boost
    OLD_CPU_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    GPU_GOV_FILE=$(ls /sys/class/devfreq/*/governor 2>/dev/null | grep -i gpu | head -n 1)
    OLD_GPU_GOV=""
    [ -n "$GPU_GOV_FILE" ] && OLD_GPU_GOV=$(cat "$GPU_GOV_FILE" 2>/dev/null)
    if [ -n "$OLD_CPU_GOV" ]; then
        for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo performance | $ESUDO tee "$g" > /dev/null 2>&1
        done
    fi
    [ -n "$OLD_GPU_GOV" ] && echo performance | $ESUDO tee "$GPU_GOV_FILE" > /dev/null 2>&1

    cd "$GAMEDIR/$FOLDER"

    $GPTOKEYB "falcon_mkxp.bin" -c "$GAMEDIR/the_witchs_house.gptk" &
    ./falcon_mkxp.bin

    # Restore governors
    if [ -n "$OLD_CPU_GOV" ]; then
        for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "$OLD_CPU_GOV" | $ESUDO tee "$g" > /dev/null 2>&1
        done
    fi
    [ -n "$OLD_GPU_GOV" ] && echo "$OLD_GPU_GOV" | $ESUDO tee "$GPU_GOV_FILE" > /dev/null 2>&1

    $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
    $ESUDO systemctl restart oga_events &
    printf "\033c" > /dev/tty0 2>/dev/null
fi

pm_finish
