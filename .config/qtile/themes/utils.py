import json
import os


def get_gmail_config():
    """
        This should return a dict having two keys :
            - username
            - password
    """
    with open(os.path.expanduser('~/.config/gmail.json'), 'r') as f:
        return json.load(f)


def auto_detect_interface():
    with open('/proc/net/dev', 'r') as f:
        for line in f:
            info = line.split()
            if len(info) > 10 and info[0] not in ['lo:', 'face'] and float(info[1]) > 0:
                return info[0][:-1]
