# flake8: noqa: F401
from .bar import top_bar, bottom_bar, top_bars
from .colors import colors, background_color, foreground_color


widget_defaults = {
    "font": "Arial",  # TODO: Use a better font
    "fontsize": 12,
    "padding": 3,
    "foreground": foreground_color,
    "background": background_color,
}

layout_theme = {
    "border_width": 2,
    "margin": 0,
    "border_focus": colors[9],
    "border_normal": colors[2],
}
