"""
    This plugin simply automatically launches a shell script at startup
"""

import os
import subprocess

from libqtile import hook


@hook.subscribe.startup_once
def startup():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])
