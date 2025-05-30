#!/bin/python3

import os, subprocess
from . import colors

colors = colors.Microphone

usb_source = 'alsa_input.usb-21102019_THRONMAX_PULSE_MICROPHONE-00.iec958-stereo'
current_source = subprocess.check_output("pactl info | grep 'Default Source' | awk '{print $3}' | head", shell = True, text = True).strip()
def current_input():
    current_source = subprocess.check_output("pactl info | grep 'Default Source' | awk '{print $3}' | head", shell = True, text = True).strip()
    usb_connected = subprocess.check_output("pactl list short sources | grep " + usb_source + " | awk '{print $2}'", shell = True, text = True)
    #always set to usb microphone if available
    if(current_source != usb_source and usb_connected != ''):
        subprocess.check_output("pactl set-default-source " + usb_source, shell = True, text = True)
        current_source = usb_source

current_input()

#Helper functions
def get_volume():
    volume = subprocess.check_output(r"pactl get-source-volume " + current_source + r" | grep -Po '\d+(?=%)' | head -n 1", shell = True, text = True).strip()
    return volume + '%'

def is_muted():
    status = subprocess.check_output("pactl get-source-mute " + current_source, shell = True, text = True)
    return str.strip(status) == 'Mute: yes'

def status():
    return '󰍭  M' if is_muted() else '󰍬  ' + get_volume()

def color():
    return colors[0] if is_muted() else colors[1]

def increase_mic_volume():
    vol = subprocess.check_output("pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%'", shell = True, text = True)
    if int(vol) < 100:
        os.system("pactl set-source-volume " + current_source + " +5%")

def decrease_mic_volume():
    os.system("pactl set-source-volume " + current_source + " -5%")

def toggle():
    current_input()
    global current_source 
    current_source = subprocess.check_output("pactl info | grep 'Default Source' | awk '{print $3}' | head", shell = True, text = True).strip()
    global usb_connected 
    usb_connected = subprocess.check_output("pactl list short sources | grep " + usb_source + " | awk '{print $2}'", shell = True, text = True)
    if(current_source != usb_source and usb_connected != ''):
        subprocess.check_output("pactl set-default-source " + usb_source, shell = True, text = True)
        current_source = usb_source
    os.system("pactl set-source-mute " + current_source + " toggle")



