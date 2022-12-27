public class Album.SettingPopover : Gtk.Popover {
    public Album.MainWindow window { get; construct; }

    public int sort_func { get; set; }

    public signal void sort_func_changed ();

    public SettingPopover (Album.MainWindow window) {
        Object (window: window);
    }

    construct {
        var date_sort_label = new Granite.HeaderLabel ("Sorting:") {
            margin_start = 12,
            margin_top = 6
        };

        var mode_switch = new Granite.ModeSwitch.from_icon_name ("view-sort-descending", "view-sort-ascending") {
            primary_icon_tooltip_text = "Newer first",
            secondary_icon_tooltip_text = "Older first"
        };

        var switch_button = (Gtk.Switch) mode_switch.get_last_child ().get_prev_sibling ();
        switch_button.state_set.connect ((state) => {
            if (state) {
                sort_func = 1;
                Album.Application.settings.set_int ("date-sort-format", 1);
                sort_func_changed ();
            } else {
                sort_func = 0;
                Album.Application.settings.set_int ("date-sort-format", 0);
                sort_func_changed ();
            }
        });

        window.notify["visible"].connect (() => {
            if (Album.Application.settings.get_int ("date-sort-format") == 0) {
                mode_switch.active = false;
                sort_func = 0;
            } else {
                mode_switch.active = true;
                sort_func = 1;
            }
        });

        var actions_grid = new Gtk.Grid () {
            margin_end = 12,
            margin_start = 12,
            margin_bottom = 12
        };
        actions_grid.attach (date_sort_label, 0, 0);
        actions_grid.attach (mode_switch, 0, 1);

        child = actions_grid;
    }
}
