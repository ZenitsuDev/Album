public enum Album.ImageSortFunc {
    NEW_TO_OLD,
    OLD_TO_NEW,
    A_TO_Z,
    Z_TO_A
}

public class Album.SettingPopover : Gtk.Popover {
    public Album.MainWindow window { get; construct; }

    public Album.ImageSortFunc sort_func { get; set; }

    public SettingPopover (Album.MainWindow window) {
        Object (window: window);
    }

    construct {
        var new_to_old = new Gtk.CheckButton.with_label ("New to old") {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 6,
        };

        var old_to_new = new Gtk.CheckButton.with_label ("Old to new") {
            margin_start = 12,
            margin_end = 12,
            margin_top = 6,
            margin_bottom = 12,
            group = new_to_old
        };

        new_to_old.toggled.connect (() => {
            sort_func = (Album.ImageSortFunc) !new_to_old.active;
        });

        if (!Album.Application.settings.get_boolean ("date-sort-format")) {
            old_to_new.active = true;
        }

        Album.Application.settings.bind ("date-sort-format", new_to_old, "active", SettingsBindFlags.DEFAULT);

        var actions_grid = new Gtk.Grid ();
        actions_grid.attach (new_to_old, 0, 0);
        actions_grid.attach (old_to_new, 0, 1);

        width_request = 150;
        height_request = 200;

        child = actions_grid;
    }
}
