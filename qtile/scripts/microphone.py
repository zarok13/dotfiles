import os, subprocess
from . import colors
#from libqtile.log_utils import logger


colors = colors.Microphone

# Use the PipeWire standard identifier for the default source
default_source_alias = '@DEFAULT_SOURCE@'

# Specific identifier for your USB microphone source name
# Note: You should verify this name using 'pactl list short sources' in your environment
usb_source_name = 'alsa_input.usb-21102019_THRONMAX_PULSE_MICROPHONE-00.iec958-stereo'


# Helper function to get the current default source name dynamically
def get_current_source_name():
    # Use 'pw-metadata' or 'pactl info' to find the default source,
    # but the alias '@DEFAULT_SOURCE@' is often easier for commands
    # We will use the alias for setting/getting values
    return subprocess.check_output(
        "pactl info | grep 'Default Source' | awk '{print $3}'",
        shell=True,
        text=True
    ).strip()


# Function to handle automatic switching if the USB mic is available
def current_input():
    current_source = get_current_source_name()
    # Check if the USB device name exists in the list of sources
    try:
        usb_connected_check = subprocess.check_output(
            f"pactl list short sources | grep '{usb_source_name}'",
            shell=True,
            text=True
        ).strip()
    except subprocess.CalledProcessError:
        # Grep returns non-zero exit code if string not found
        usb_connected_check = ''

    # always set to usb microphone if available and not already set
    if current_source != usb_source_name and usb_connected_check != '':
        # We use the specific name when setting the source
        subprocess.check_output(
            f"pactl set-default-source {usb_source_name}",
            shell=True,
            text=True
        )

# Call the auto-switch function on script start
current_input()


# Helper functions for status/volume (now using the default_source_alias)

def get_volume():
    # Use @DEFAULT_SOURCE@ alias to always target the current default device
    volume = subprocess.check_output(
        r"pactl get-source-volume @DEFAULT_SOURCE@ | grep -Po '\d+(?=%)' | head -n 1",
        shell=True,
        text=True
    ).strip()
    return volume + '%'

def is_muted():
    # Use the alias for reliability
    result = subprocess.run(
        ["pactl", "get-source-mute", default_source_alias],
        capture_output=True,
        text=True,
        check=True
    )
    status_output = result.stdout.strip()
    # Check if the output string explicitly contains 'Mute: yes'
    return status_output == 'Mute: yes'

def status():
    # Ensure colors module is handled correctly by your environment
    return '󰍭   M' if is_muted() else '󰍬   ' + get_volume()

def color():
    return colors[0] if is_muted() else colors[1]

def increase_mic_volume():
    # Check current volume first to prevent going over 100% in one step
    vol = subprocess.check_output(
        "pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%'",
        shell=True,
        text=True
    )
    if int(vol) < 100:
        # Use os.system for simplicity here as in original script
        os.system("pactl set-source-volume @DEFAULT_SOURCE@ +5%")

def decrease_mic_volume():
    os.system("pactl set-source-volume @DEFAULT_SOURCE@ -5%")

def toggle():
    # 1. Ensure we are targeting the right source first
    current_input() 
    
    # 2. Execute the toggle command via OS call
    os.system("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    
    # 3. (Optional) Print the *new* state for debugging to qtile.log
    #if is_muted():
    #    logger.warning("DEBUG: Microphone is now MUTED")
    #else:
    #    logger.warning("DEBUG: Microphone is now UNMUTED")

