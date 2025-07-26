#!/usr/bin/env python3
import gi
import subprocess
import os
import json
from datetime import datetime
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf

class AasmiStartMenu(Gtk.Window):
    def __init__(self):
        super().__init__(title="AASMI Menu")
        self.set_default_size(550, 700)
        self.set_border_width(15)
        self.set_position(Gtk.WindowPosition.CENTER_ALWAYS)
        self.set_decorated(False)
        self.set_app_paintable(True)
        self.connect("draw", self.on_draw)
        
        # Load user preferences
        self.config_dir = os.path.expanduser("~/.config/aasmi-menu")
        os.makedirs(self.config_dir, exist_ok=True)
        self.config_file = os.path.join(self.config_dir, "config.json")
        self.load_config()
        
        # Apply CSS
        self.apply_css()
        
        # Main layout
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        self.add(vbox)
        
        # Search entry
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("Search applications...")
        self.search_entry.connect("search-changed", self.on_search_changed)
        vbox.pack_start(self.search_entry, False, False, 0)
        
        # Notebook for tabs
        notebook = Gtk.Notebook()
        notebook.set_show_tabs(True)
        notebook.set_show_border(False)
        vbox.pack_start(notebook, True, True, 0)
        
        # All Apps tab
        all_apps_scrolled = Gtk.ScrolledWindow()
        all_apps_scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.all_apps_flowbox = Gtk.FlowBox()
        self.all_apps_flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.all_apps_flowbox.set_max_children_per_line(3)
        all_apps_scrolled.add(self.all_apps_flowbox)
        notebook.append_page(all_apps_scrolled, Gtk.Label(label="All Apps"))
        
        # Favorites tab
        fav_scrolled = Gtk.ScrolledWindow()
        self.fav_flowbox = Gtk.FlowBox()
        self.fav_flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.fav_flowbox.set_max_children_per_line(3)
        fav_scrolled.add(self.fav_flowbox)
        notebook.append_page(fav_scrolled, Gtk.Label(label="Favorites"))
        
        # Recent tab
        recent_scrolled = Gtk.ScrolledWindow()
        self.recent_flowbox = Gtk.FlowBox()
        self.recent_flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.recent_flowbox.set_max_children_per_line(3)
        recent_scrolled.add(self.recent_flowbox)
        notebook.append_page(recent_scrolled, Gtk.Label(label="Recent"))
        
        # System tab
        system_scrolled = Gtk.ScrolledWindow()
        system_flowbox = Gtk.FlowBox()
        system_flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        system_flowbox.set_max_children_per_line(2)
        system_scrolled.add(system_flowbox)
        notebook.append_page(system_scrolled, Gtk.Label(label="System"))
        
        # App data
        self.all_apps = [
            {"name": "Web Browser", "cmd": "firefox", "icon": "web-browser"},
            {"name": "File Manager", "cmd": "thunar", "icon": "system-file-manager"},
            {"name": "Terminal", "cmd": "xfce4-terminal", "icon": "utilities-terminal"},
            {"name": "Text Editor", "cmd": "mousepad", "icon": "accessories-text-editor"},
            {"name": "Media Player", "cmd": "vlc", "icon": "vlc"},
            {"name": "Settings", "cmd": "xfce4-settings-manager", "icon": "preferences-system"},
            {"name": "Theme Switcher", "cmd": "toggle-theme", "icon": "preferences-desktop-theme"},
            {"name": "Calculator", "cmd": "galculator", "icon": "accessories-calculator"},
            {"name": "Screenshot", "cmd": "xfce4-screenshooter", "icon": "applets-screenshooter"},
            {"name": "Lock Screen", "cmd": "xdg-screensaver lock", "icon": "system-lock-screen"}
        ]
        
        self.system_apps = [
            {"name": "Shutdown", "cmd": "systemctl poweroff", "icon": "system-shutdown"},
            {"name": "Restart", "cmd": "systemctl reboot", "icon": "system-restart"},
            {"name": "Log Out", "cmd": "xfce4-session-logout", "icon": "system-log-out"},
            {"name": "Suspend", "cmd": "systemctl suspend", "icon": "system-suspend"}
        ]
        
        # Populate apps
        self.populate_apps()
        
        # Close button
        close_btn = Gtk.Button(label="Close")
        close_btn.connect("clicked", lambda w: self.close())
        vbox.pack_end(close_btn, False, False, 0)
    
    def apply_css(self):
        css_provider = Gtk.CssProvider()
        css = """
            window {
                background: linear-gradient(135deg, #FFB6C1, #ADD8E6);
                border-radius: 20px;
                box-shadow: 0 8px 16px rgba(0,0,0,0.3);
                border: 2px solid rgba(255,105,180,0.7);
            }
            .app-button {
                background-color: #FF69B4;
                color: white;
                border-radius: 12px;
                padding: 10px;
                margin: 5px;
                border: none;
                box-shadow: 0 4px 6px rgba(255,105,180,0.4);
                transition: all 0.2s ease;
            }
            .app-button:hover {
                background-color: #FF85C1;
                box-shadow: 0 6px 10px rgba(255,105,180,0.6);
            }
            .fav-button {
                background-color: #2E2B4F;
            }
            notebook tab {
                background-color: rgba(255,255,255,0.2);
                border-radius: 8px 8px 0 0;
                padding: 6px 12px;
                margin: 0 2px;
            }
            notebook tab:active {
                background-color: rgba(255,255,255,0.4);
            }
        """
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
    def load_config(self):
        self.config = {"favorites": [], "recent": []}
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    self.config = json.load(f)
            except:
                pass
    
    def save_config(self):
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f)
    
    def populate_apps(self):
        # Clear all boxes
        for child in self.all_apps_flowbox.get_children():
            self.all_apps_flowbox.remove(child)
        for child in self.fav_flowbox.get_children():
            self.fav_flowbox.remove(child)
        for child in self.recent_flowbox.get_children():
            self.recent_flowbox.remove(child)
        
        # Add all apps
        for app in self.all_apps:
            self.add_app_button(app, self.all_apps_flowbox)
        
        # Add favorites
        for fav in self.config["favorites"]:
            app = next((a for a in self.all_apps if a["cmd"] == fav), None)
            if app:
                self.add_app_button(app, self.fav_flowbox, True)
        
        # Add recent apps
        for recent in self.config["recent"][:6]:  # Show last 6
            app = next((a for a in self.all_apps if a["cmd"] == recent), None)
            if app:
                self.add_app_button(app, self.recent_flowbox)
    
    def add_app_button(self, app, flowbox, is_fav=False):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        
        try:
            icon = Gtk.IconTheme.get_default().load_icon(app["icon"], 48, 0)
            image = Gtk.Image.new_from_pixbuf(icon)
        except:
            image = Gtk.Image.new_from_icon_name("application-x-executable", Gtk.IconSize.DIALOG)
        
        label = Gtk.Label(label=app["name"])
        label.set_max_width_chars(15)
        label.set_ellipsize(3)  # PANGO_ELLIPSIZE_END
        
        btn = Gtk.Button()
        btn.get_style_context().add_class("app-button")
        if is_fav:
            btn.get_style_context().add_class("fav-button")
        
        btn.connect("clicked", self.on_app_clicked, app)
        btn.connect("button-press-event", self.on_app_right_click, app)
        
        box.pack_start(image, False, False, 0)
        box.pack_start(label, False, False, 0)
        btn.add(box)
        flowbox.add(btn)
    
    def on_app_clicked(self, button, app):
        try:
            subprocess.Popen(app["cmd"], shell=True)
            # Add to recent apps
            if app["cmd"] in self.config["recent"]:
                self.config["recent"].remove(app["cmd"])
            self.config["recent"].insert(0, app["cmd"])
            self.save_config()
            self.close()
        except Exception as e:
            dialog = Gtk.MessageDialog(
                parent=self,
                flags=0,
                message_type=Gtk.MessageType.ERROR,
                buttons=Gtk.ButtonsType.OK,
                text=f"Error launching {app['name']}"
            )
            dialog.format_secondary_text(str(e))
            dialog.run()
            dialog.destroy()
    
    def on_app_right_click(self, button, event, app):
        if event.button == 3:  # Right click
            menu = Gtk.Menu()
            
            fav_item = Gtk.MenuItem(label="Add to Favorites" if app["cmd"] not in self.config["favorites"] else "Remove from Favorites")
            fav_item.connect("activate", self.toggle_favorite, app)
            menu.append(fav_item)
            
            menu.show_all()
            menu.popup_at_pointer(event)
            return True
        return False
    
    def toggle_favorite(self, menu_item, app):
        if app["cmd"] in self.config["favorites"]:
            self.config["favorites"].remove(app["cmd"])
        else:
            self.config["favorites"].append(app["cmd"])
        self.save_config()
        self.populate_apps()
    
    def on_search_changed(self, entry):
        search_text = entry.get_text().lower()
        for child in self.all_apps_flowbox.get_children():
            button = child.get_child()
            box = button.get_child()
            label = box.get_children()[1]
            visible = search_text in label.get_text().lower()
            child.set_visible(visible)
    
    def on_draw(self, widget, cr):
        cr.set_operator(Gdk.cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(Gdk.cairo.OPERATOR_OVER)
        return False

if __name__ == "__main__":
    win = AasmiStartMenu()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()