from libqtile import bar, widget

from ..utils import get_gmail_config, auto_detect_interface

# from .colors import colors


top_bar = True
bottom_bar = False

# Nice To Have
# Volume
# Moc / Mpd / Mpd2 / Mpris / Mpris2 / cmus
# QuickExit
# YahooWeather


def widget_stack():
    gmail_config = {
        'update_interval': 50,
        'fmt': 'in[%s] unread(%s)',
        **get_gmail_config()
    }
    return [
        widget.CurrentScreen(),
        widget.GroupBox(),
        widget.Prompt(),
        widget.TaskList(),
        widget.GmailChecker(**gmail_config),
        widget.Sep(),
        widget.CheckUpdates(),
        widget.Sep(),
        widget.Wlan(interface=auto_detect_interface()),
        widget.Sep(),
        widget.DF(visible_on_warn=False, format="Disk free {r:.1f}%"),
        widget.Sep(),
        widget.CPUGraph(),
        widget.Memory(),
        widget.Sep(),
        widget.Battery(update_interval=1, format="🔋 {char} {percent:2.0%}"),
        widget.Sep(),
        widget.Systray(),
        widget.Notify(),
        widget.Clock(),
        widget.CurrentLayoutIcon(),
    ]


top_bars = [
    bar.Bar(widget_stack(), 24),
    bar.Bar(widget_stack(), 24),
]
