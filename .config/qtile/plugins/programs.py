from libqtile.command import lazy

BROWSER = 'firefox'

registered_functions = {
    'open_browser': lazy.spawn(BROWSER),
    'slock': lazy.spawn("slock"),
    'slack': lazy.spawn("slack"),
}
