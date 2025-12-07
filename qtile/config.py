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

import os, subprocess, sys, importlib    
from libqtile import qtile, layout, widget, bar, hook 
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown #, KeyChord
from libqtile.lazy import lazy
from qtile_extras.popup import (
    PopupRelativeLayout,
    PopupImage,
    PopupText
)
from qtile_extras import widget
from qtile_extras.widget import decorations
from qtile_extras.widget.decorations import (
    PowerLineDecoration,
    RectDecoration,
)
from scripts import colors
from scripts import microphone
#from libqtile.log_utils import logger



scripts_dir = 'scripts.'
colors = colors.GruvBox
#colors = colors.DoomOne
mod = "mod4"
alt = "mod1"
terminal = "alacritty"
browser = "brave-browser"



@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)

@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()
                
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == 'monadtall':
        qtile.current_group.layout = 'max'
    elif current_layout_name == 'max':
        qtile.current_group.layout = 'monadtall'
    
##### MOUSE CALLBACKS #####
def open_rofi_advanced():
    qtile.spawn("rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launcher9.rasi")
def open_settings():
    qtile.spawn("xfce4-settings-manager")
def open_powermenu():
    qtile.spawn("./.config/rofi/powermenu/type-1/powermenu.sh")

def update_widget(name, action):
    module = importlib.import_module(scripts_dir + name)
    func = getattr(module, action)
    func()
    for screen in qtile.screens:
        for widget in getattr(screen.top, 'widgets', []):
            if getattr(widget, 'name', '') == name:
                widget.text = f'<span foreground="{module.color()}">{module.status()}</span>'
                widget.bar.draw()

def get_updates(widget_name):
    try:
        system_updates = os.path.expanduser("~/.config/qtile/scripts/check-updates.sh")
        count = subprocess.check_output(
            [system_updates],
            text=True,
        ).strip()
        for screen in qtile.screens:
            for widget in getattr(screen.top, 'widgets', []):
                if getattr(widget, 'name', '') == widget_name:
                    widget.text = f' {count}'
                    widget.bar.draw()
    except subprocess.CalledProcessError:
        return ' Error'
    except FileNotFoundError:
        return ' Script Not Found'

                
@lazy.function   
def show_power_menu(qtile):
    controls = [
        PopupImage(
            filename="~/.config/qtile/icons/face.png",
            pos_x=0.05,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            mouse_callbacks={
                "Button1": lazy.spawn("betterlockscreen -l")
            },
        ),
        PopupImage(
            filename="~/.config/qtile/icons/face.png",
            pos_x=0.25,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            mouse_callbacks={
                "Button1": lazy.spawn("systemctl suspend")
            }
        ),
        PopupImage(
            filename="~/.config/qtile/icons/face.png",
            pos_x=0.45,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            highlight="A00000",
            mouse_callbacks={
                "Button1": lazy.spawn("qtile cmd-obj -o cmd -f shutdown")
            }
        ),
        PopupImage(
            filename="~/.config/qtile/icons/face.png",
            pos_x=0.65,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            highlight="A00000",
            mouse_callbacks={
                "Button1": lazy.spawn("systemctl reboot")
            }
        ),
        PopupImage(
            filename="~/.config/qtile/icons/face.png",
            pos_x=0.85,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            highlight="A00000",
            mouse_callbacks={
                "Button1": lazy.spawn("systemctl poweroff")
            }
        ),
        PopupText(
            text="Lock",
            pos_x=0.05,
            pos_y=0.7,
            width=0.1,
            height=0.1,
            h_align="center"
        ),
        PopupText(
            text="Sleep",
            pos_x=0.25,
            pos_y=0.7,
            width=0.1,
            height=0.2,
            h_align="center"
        ),
        PopupText(
            text="Logout",
            pos_x=0.45,
            pos_y=0.7,
            width=0.1,
            height=0.2,
            h_align="center"
        ),
        PopupText(
            text="Restart",
            pos_x=0.65,
            pos_y=0.7,
            width=0.1,
            height=0.2,
            h_align="center"
        ),
        PopupText(
            text="Shutdown",
            pos_x=0.85,
            pos_y=0.7,
            width=0.1,
            height=0.2,
            h_align="center"
        ),
    ]

    layout = PopupRelativeLayout(
        qtile,
        width=1000,
        height=200,
        controls=controls,
        background="00000060",
        initial_focus=None,
    )

    layout.show(centered=True)
    
### qtile_extras ###
arrow_powerlineRight = {
    "decorations": [
        PowerLineDecoration(
            path = "arrow_right",
            size = 11,
            stroke_colour = 'fff'
        )
    ]
}
arrow_powerlineLeft = {
    "decorations": [
        PowerLineDecoration(
            path="arrow_left",
            size=11,
        )
    ]
}
rounded_powerlineRight = {
    "decorations": [
        PowerLineDecoration(
            path="rounded_right",
            size=11,
        )
    ]
}
rounded_powerlineLeft = {
    "decorations": [
        PowerLineDecoration(
            path="rouded_left",
            size=11,
        )
    ]
}
slash_powerlineRight = {
    "decorations": [
        PowerLineDecoration(
            path="forward_slash",
            size=11,
        )
    ]
}
slash_powerlineLeft = {
    "decorations": [
        PowerLineDecoration(
            path="back_slash",
            size=11,
        )
    ]
}


keys = [
    ### essentials ###
    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod, "shift"], "Return", lazy.spawn("rofi -show drun -disable-history True"), desc='Run Launcher'),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Logout menu"),
    Key([mod, "shift"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    ### super + function keys ###
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([alt], "F4", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", maximize_by_switching_layout(), lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "b", lazy.hide_show_bar(position='all'), desc="Toggles the bar to show/hide"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    #Key([mod], "x", lazy.spawn("./.config/rofi/powermenu/type-1/powermenu.sh"), desc='Power Menu'),
    Key([mod], "x", show_power_menu(), desc='Power Menu'),
    Key([mod], "c", lazy.spawn("gedit .config/qtile/config.py"), desc='qtile config'),
    
    ### change focus ###
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    ### switch focus of monitors ###
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),

    ### resize windows ###
    Key([mod, "control"], "h", 
        lazy.layout.grow_left(), 
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(), 
        lazy.layout.add(), 
        desc="Grow window to the left"
    ),
    Key([mod, "control"], "j", 
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(), 
        desc="Grow window down"
    ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_ratio(), 
        desc="Grow window up"
    ),
    Key([mod, "control"], "l", 
        lazy.layout.grow_right(), 
        lazy.layout.grow(),
        lazy.layout.increase_ratio(), 
        lazy.layout.delete(), 
        desc="Grow window to the right"
    ),
    Key([mod], "n", 
        lazy.layout.normalize(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(), 
        lazy.layout.delete(), 
        desc="Reset all window sizes"
    ),
    
    ### monads/columns/bsp change window size left/right ###
    Key([mod], "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),
    Key([mod], "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),

    ### treetab move windows ###
    Key([mod, "shift"], "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab"),

    Key([mod, "shift"], "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab"),

    Key([mod, "shift"], "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab"
    ),
    Key([mod, "shift"], "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab"
    ),
    ### treetab toogle ###
    Key([mod, "shift"], "space", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    ### treetab prompt ###
    Key([mod, "shift"], "a", add_treetab_section, desc='Prompt to add new section in treetab'),


    #KeyChord([mod], "p", [
    #    Key([], "c", lazy.spawn("gedit .config/qtile/config.py"), desc='qtile config'),
    #])
    
    Key([], 'F9', lazy.group['scratchpad'].dropdown_toggle(terminal)),

]

groups = []
group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
group_labels = [" ", " ", " ", " ", " ", " ", " ", " ", "⛨"]
#group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall"]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))


for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            # Key(
            #    [mod, "shift"],
            #    i.name,
            #    lazy.window.togroup(i.name, switch_group=True),
            #    desc=f"Switch to & move focused window to group {i.name}",
            # ),
            # do not switch group.
            # mod + shift + group number = move focused window to group
            Key(
                [mod, "shift"], 
                i.name, 
                lazy.window.togroup(i.name),
                 desc="move focused window to group {}".format(i.name)
             ),
        ]
    )
    
groups.append(
    ScratchPad("scratchpad", [
        DropDown(terminal, terminal, height = 0.9),
]))

layout_theme = {"border_width": 4,
	"margin": 12,
	"border_focus": colors[9],
	"border_normal": colors[0]
}


layouts = [
    layout.MonadTall(**layout_theme),
    #layout.MonadWide(**layout_theme),
    #layout.Tile(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Columns(**layout_theme),
    #layout.Floating(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    #font="Ubuntu Sans Mono",
    font="Noto Sans",
    fontsize=12,
    padding=3,
    background=colors[0]
)
extension_defaults = widget_defaults.copy()
                

##### WIDGETS #####
def init_widgets_list():
    widgets_list = [
        widget.Spacer(length = 12),
        widget.Image(
             filename = "~/.config/qtile/icons/face.png",
             scale = "False",
             mouse_callbacks = {'Button1': open_rofi_advanced },
             **slash_powerlineRight,
        ),
        widget.Prompt(
             font = "Noto Sans",
             fontsize=14,
             foreground = colors[1]
        ),
        widget.GroupBox(
             fontsize = 14,
             margin_y = 5,
             margin_x = 8,
             padding_y = 0,
             padding_x = 1,
             borderwidth = 3,
             active = colors[8],
             inactive = colors[1],
             rounded = False,
             highlight_color = colors[4],
             highlight_method = "line",
             this_current_screen_border = colors[2],
             this_screen_border = colors [8],
             other_current_screen_border = colors[2],
             other_screen_border = colors[8],
             disable_drag = True,
        ),
        widget.TextBox(
             text = '|',
             font = "Noto Sans",
             foreground = colors[9],
             #background = "#00000000",
             padding = 2,
             fontsize = 14
        ),
        widget.WindowName(
             foreground = colors[8],
             #background = "#00000000",
             padding = 4,
             max_chars = 30,
             fontsize = 14,
             **arrow_powerlineRight,
        ),
        widget.CurrentLayout(
             foreground = colors[0],
             background = colors[1],
             padding = 5,
             fontsize = 16,
             **arrow_powerlineRight,
        ),
        widget.TextBox(
             name = 'system_updates',
             foreground = colors[0],
             background = colors[4],
             padding = 6,
             fontsize = 16,
             fmt = ' {}',
             #func = lambda: subprocess.check_output(["~/.config/qtile/scripts/check-updates.sh"], shell=True, text=True),
             mouse_callbacks={
                 "Button1": lambda: get_updates('system_updates')
             },
             **arrow_powerlineRight,
        ),
        widget.TextBox(
    	     name = 'microphone',
             text = microphone.status(),
             font = "Noto Sans",
             fontsize = 16,
             foreground = microphone.color(),
             padding = 6,
             fmt = '{}',
             mouse_callbacks = { 
             	 "Button1": lambda: update_widget('microphone', 'toggle'),
             	 "Button4": lambda: update_widget('microphone', 'increase_mic_volume'),
             	 "Button5": lambda: update_widget('microphone', 'decrease_mic_volume'),
     	 	 },
 	 	     **arrow_powerlineRight,
        ), 
        widget.Volume(
	         fontsize = 16,
             foreground = colors[0],
             background = colors[7],
             padding = 6, 
             fmt = '🕫 {}',
             **arrow_powerlineRight,
         ),
        widget.KeyboardLayout(
             fontsize = 15,
             foreground = colors[0],
             background = colors[3],
             padding = 6, 
             fmt = '⌨ {}',
             configured_keyboards=['us', 'ge', 'ru'],
             display_map={'us': 'EN', 'ge': 'GE', 'ru': 'RU'},
             **arrow_powerlineRight,
        ),
        widget.Clock(
    	     fontsize = 16,
             foreground = colors[8],
             padding = 6,
             mouse_callbacks = {'Button1': lambda: qtile.spawn(os.path.expanduser('~/.config/qtile/scripts/show-date.sh'))},
             format = " ⏱ %I:%M %p",
     	),
    ]
    return widgets_list

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    widgets_screen1.append(
        widget.Spacer(
            length = 8,
            **arrow_powerlineRight
        )
    )
    widgets_screen1.append(
        widget.Systray(
            padding = 6,
            icon_size = 25,
            background = '#FFFFFF',
            **slash_powerlineLeft
        )
    )
    widgets_screen1.append(widget.Spacer(
        length = 1,
        **slash_powerlineLeft
        )
    )
    widgets_screen1.append(
        widget.Image(
            filename = "~/.config/qtile/icons/settings.png",
            scale = "False",
            mouse_callbacks = {'Button1': open_settings },
            background = colors[1]
        )
    )
    widgets_screen1.append(
        widget.Spacer(length = 8,
        background = colors[1]
        )
    )
    widgets_screen1.append(
        widget.Image(
            filename = "~/.config/qtile/icons/powermenu.png",
            scale = "False",
            mouse_callbacks = {'Button1': show_power_menu },
            background = colors[1]
        )
    )
    return widgets_screen1 

def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    
    return widgets_screen2


def init_screens():
    return [
    	Screen(top=bar.Bar(widgets=init_widgets_screen1(), margin=[0, 0, 0, 0], size=30)),
    	Screen(top=bar.Bar(widgets=init_widgets_screen2(), margin=[0, 0, 0, 0], size=40))
    ]
            

if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()



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
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
       	Match(wm_class="confirmreset"),   # gitk
        Match(wm_class="dialog"),         # dialog boxes
        Match(wm_class="download"),       # downloads
        Match(wm_class="error"),          # error msgs
        Match(wm_class="file_progress"),  # file progress boxes
        Match(wm_class='kdenlive'),       # kdenlive
        Match(wm_class="makebranch"),     # gitk
        Match(wm_class="maketag"),        # gitk
        Match(wm_class="notification"),   # notifications
        Match(wm_class='pinentry-gtk-2'), # GPG key password entry
        Match(wm_class="ssh-askpass"),    # ssh-askpass
        Match(wm_class="toolbar"),        # toolbars
        Match(wm_class="Yad"),            # yad boxes
        Match(title="branchdialog"),      # gitk
        Match(title='Confirmation'),      # tastyworks exit box
        Match(title='Qalculate!'),        # qalculate-gtk
        Match(title="pinentry"),          # GPG key password entry
        Match(title="tastycharts"),       # tastytrade pop-out charts
        Match(title="tastytrade"),        # tastytrade pop-out side gutter
        Match(title="tastytrade - Portfolio Report"), # tastytrade pop-out allocation
        Match(wm_class="tasty.javafx.launcher.LauncherFxApp"), # tastytrade settings
        Match(title="nmtui-float"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None
# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = "Qogir"
wl_xcursor_size = 30

@hook.subscribe.startup_once
def autostart():
    autostart = os.path.expanduser("~/.config/qtile/scripts/autostart.sh")
    subprocess.call([autostart])
    

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
