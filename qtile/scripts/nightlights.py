#!/bin/python3

import os, subprocess
'''
def is_enabled():
    status = subprocess.check_output("if pgrep -x gammastep > /dev/null; then echo '1'; else echo '0'; fi", shell=True, text=True).strip()
    if status == '1':
        return True
    else:
        return False
'''
def is_enabled():
    try:
        output = subprocess.check_output(["pgrep", "-x", "gammastep"])
        return bool(output.strip())
    except subprocess.CalledProcessError:
        return False

def status():
    return '🌙' if is_enabled() else '🔆'

def toggle():
    if is_enabled():
        os.system("pkill gammastep")
    else:
        os.system("gammastep -c ~/.config/gammastep/gammastep.conf &")



