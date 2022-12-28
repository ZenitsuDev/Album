public class Album.Sorter : Adw.Bin {
    public Album.MainWindow window { get; construct; }

    public int sort_func { get; set; }

    public signal void sort_func_changed ();

    public Sorter (Album.MainWindow window) {
        Object (window: window);
    }

    construct {
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

        child = mode_switch;

        margin_end = 10;
    }
}
