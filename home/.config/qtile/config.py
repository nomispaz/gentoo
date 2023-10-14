# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os, sys
import subprocess
import qtile_extras
from colors import colors
from qtile_extras import widget
from libqtile import bar, layout, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland import InputConfig

from qtile_extras.widget.decorations import PowerLineDecoration, RectDecoration
from mymodules.mywidgets import myvolume, mymicrophone
import myfunctions

from libqtile import hook

# environment variables
os.environ["WLR_NO_HARDWARE_CURSORS"] = "1"
os.environ["RANGER_LOAD_DEFAULT_RC"] = "false"
os.environ["XDG_SESSION_TYPE"] = "wayland"

# autostart
@hook.subscribe.startup_once
def start_once():
    script = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([script])

# define input configurations for x11/wayland
if qtile.core.name == "x11":
    None
elif qtile.core.name == "wayland":
    wl_input_rules = {
        "type:touchpad": InputConfig(tap=True,middle_emulation=True),
        "type:keyboard": InputConfig(kb_layout='de',kb_variant='nodeadkeys')
    }

# Modkey is windows-key
mod = "mod4"

# standard terminal
terminal = 'kitty'

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),

    # fn keys
    Key([], "XF86MonBrightnessDown", lazy.spawn('brightnessctl set 5%-')),
    Key([], "XF86MonBrightnessUp", lazy.spawn('brightnessctl set 5%+')),
    Key([], "XF86AudioLowerVolume", lazy.spawn('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-')),
    Key([], "XF86AudioRaiseVolume", lazy.spawn('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+')),
    Key([], "XF86AudioMute", lazy.spawn('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle')),

    # start programs with shortcuts
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn('brave-bin'), desc="Launch Brave-bin"),
    Key([mod], "s", lazy.spawn('prime-run steam'), desc="Launch steam on nvidia"),
    Key([mod], "r", lazy.spawn('wofi --show drun'), desc="Launch wofi"),
    Key([mod], "e", lazy.spawn('vscodium'), desc="Launch vscodium"),

    # screenshots
    Key([mod], "Print", lazy.spawn('grim -g "$(slurp)"', shell=True), desc="Screenshot"),

]


layouts = [
    layout.Columns(border_focus_stack=colors['Red'],border_focus=[colors['Rosewater']], border_width=4, insert_position=1),
    # Try more layouts by unleashing below layouts.
    # layout.Matrix(),
    # layout.Max(),
]

widget_defaults = dict(
    font="Font Awesome 5 Free",
    fontsize=18,
    padding=0,
    background=colors['Transparent'],
    foreground=colors['Base'],
)
extension_defaults = widget_defaults.copy()

decoration_group = {
    "decorations": [
        RectDecoration(use_widget_background=True, padding_y=5, filled=True, radius=0),
        PowerLineDecoration(path="forward_slash", padding_y=5)
    ],
    "padding": 10,
}

# inject qtile-extra decorations into mywidgets
widget.modify(myvolume.Volume, **decoration_group)
widget.modify(mymicrophone.Mic, **decoration_group)

#widgets
#widget.CurrentLayout(**decoration_group),
wGroupBox = widget.GroupBox(background=colors['Overlay0'],**decoration_group)
wWindowName = widget.WindowName(background=colors['Transparent'],**decoration_group)
wTextBox = widget.TextBox(width=1000,background=colors['Transparent'])
wStatusNotifier = qtile_extras.widget.StatusNotifier(background=colors['Transparent'],**decoration_group)
wThermalSensor = widget.ThermalSensor(background=colors['Red'], threshold=100, width=80,**decoration_group)
wBacklight = widget.Backlight(background=colors['Rosewater'],backlight_name="amdgpu_bl1",**decoration_group,width=70,format=myfunctions.myfunctions.get_icons('nerd_sun')+" {percent:2.0%}")
wVolume = myvolume.Volume(background=colors['Lavender'],**decoration_group)
wMic = mymicrophone.Mic(background=colors['Lavender'],**decoration_group)
wCPU = widget.CPU(background=colors['Sky'],width=180,**decoration_group)
wMemory = widget.Memory(background=colors['Sky'],width=120, format="RAM: {MemPercent}%",**decoration_group)
wNet = widget.Net(background=colors['Sapphire'],**decoration_group,width=180,format='Net: {down:.0f}{down_suffix} ↓↑ {up:.0f}{up_suffix}')
wBattery = widget.Battery(background=colors['Sapphire'],width=50,**decoration_group)
wClock = widget.Clock(background=colors['Blue'],format="%Y-%m-%d %a %H:%M",width=220,**decoration_group)
            
screens = [
    Screen(
        top=bar.Bar(
            [
                wGroupBox,
                wWindowName,
                wTextBox,
                wStatusNotifier,
                wThermalSensor,
                wBacklight,
                wVolume,
                wMic,
                wCPU,
                wMemory,
                wNet,
                wBattery,
                wClock
                ],
            32,
            background=colors['Transparent'],
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
    Screen(
        top=bar.Bar(
            [
                wGroupBox,
                wWindowName,
                wTextBox,
                wStatusNotifier,
                wThermalSensor,
                wBacklight,
                wVolume,
                wMic,
                wCPU,
                wMemory,
                wNet,
                wBattery,
                wClock
                ],
            32,
            background=colors['Transparent'],
        ),
    ),
]

#groups = [Group(i) for i in "1234"]
groups = [
    Group(name="1", screen_affinity=0),
    Group(name="2", screen_affinity=0),
    Group(name="3", screen_affinity=1),
    Group(name="4", screen_affinity=1),
]


for i in groups:
    keys.extend([
        # Switch to group N
        Key(
            [mod], 
            i.name, 
            lazy.to_screen(0) if i.name in '12' else lazy.to_screen(1),
            lazy.group[i.name].toscreen()
        ),
        # Move window to group N
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),),
    ])

else:
    for i in groups:
        keys.extend([
            # Switch to group N
            Key([mod], i.name, lazy.group[i.name].toscreen()),

            # Move window to group N
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),),
        ])


# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = True
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = False

wmname = "LG3D"
