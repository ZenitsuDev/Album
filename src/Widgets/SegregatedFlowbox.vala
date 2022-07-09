public class Album.SegregatedFlowbox : Gtk.ListBoxRow {
    public Gtk.FlowBox main_widget { get; set; }
    public string date { get; construct; }
    public Album.MainWindow window { get; construct; }
    private signal void can_close (bool condition);

    private int index;

    private string[] weekdays = {
        "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday", "Sunday"
    };

    public SegregatedFlowbox (string date, Album.MainWindow window) {
        Object (
            date: date,
            window: window
        );
    }

    construct {
        main_widget = new Gtk.FlowBox () {
            homogeneous = true,
            column_spacing = 10,
            row_spacing = 10,
            vexpand = true,
            hexpand = true,
            selection_mode = Gtk.SelectionMode.NONE,
            margin_top = 10,
            margin_bottom = 10
        };

        main_widget.set_sort_func ((child1, child2) => {
            switch (window.setting_popover.sort_func) {
                case 0:
                    return new_to_old (child1, child2);
                    break;
                case 1:
                    return old_to_new (child1, child2);
                    break;
            }
        });

        window.setting_popover.sort_func_changed.connect (() => {
            main_widget.invalidate_sort ();
        });

        var container_title = new Granite.HeaderLabel (formatted_date ());
        var main_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_container.append (container_title);
        main_container.append (main_widget);
        child = main_container;
        can_focus = false;

        main_widget.child_activated.connect ((chil) => {
            var child = (Album.ImageFlowBoxChild) chil;
            index = child.get_index ();

            Gdk.Texture texture = null;
            try {
                texture = Gdk.Texture.from_file (child.file);
            } catch (Error e) {
                critical (e.message);
            }

            window.preview_page.picture.paintable = texture;
            window.preview_page.label.label = child.file.get_path ();

            window.transition_stack.add_shared_element (child.child, window.preview_page.picture);
            window.transition_stack.navigate (window.preview_page);
            window.preview_page.update_properties (child.file, child.time, child.date, child.size_data);

            can_close (true);
        });

        can_close.connect ((condition) => {
            if (condition) {
                window.preview_page.halt_button.clicked.connect (halt_preview);
            } else {
                window.preview_page.halt_button.clicked.disconnect (halt_preview);
            }
        });
    }

    private string formatted_date () {
        if (date != null && date != "") {
            var splitted_date = date.split ("-");
            var year = int.parse (splitted_date[0]);
            var month = int.parse (splitted_date[1]);
            var day = int.parse (splitted_date[2]);
            var formatted_date = weekdays[
                (day + ((153 * (month + 12 * ((14 - month) / 12) - 3) + 2) / 5)
                    + (365 * (year + 4800 - ((14 - month) / 12)))
                    + ((year + 4800 - ((14 - month) / 12)) / 4)
                    - ((year + 4800 - ((14 - month) / 12)) / 100)
                    + ((year + 4800 - ((14 - month) / 12)) / 400)
                    - 32045
                ) % 7]; // https://stackoverflow.com/questions/6054016/c-program-to-find-day-of-week-given-date

            return date + " | " + formatted_date;
        } else {
            return date;
        }
    }

    public void append (Album.ImageFlowBoxChild child) {
        main_widget.append (child);
    }

    private void halt_preview () {
        var child = (Album.ImageFlowBoxChild) main_widget.get_child_at_index (index);
        window.transition_stack.add_shared_element (window.preview_page.picture, child.child);
        window.transition_stack.navigate (window.leaflet);

        can_close (false);
    }

    private int new_to_old (Gtk.FlowBoxChild child1, Gtk.FlowBoxChild child2) {
        var imagefb1 = (Album.ImageFlowBoxChild) child1;
        var imagefb2 = (Album.ImageFlowBoxChild) child2;

        var time1 = imagefb1.time.split (":");
        var time2 = imagefb2.time.split (":");

        var hour1 = int.parse (time1[0]);
        var hour2 = int.parse (time2[0]);

        var min1 = int.parse (time1[1]);
        var min2 = int.parse (time2[1]);

        var sec1 = int.parse (time1[2]);
        var sec2 = int.parse (time2[2]);

        if (hour2 - hour1 != 0) {
            return hour2 - hour1;
        } else {
            if (min2 - min1 != 0) {
                return min2 - min1;
            } else {
                return sec2 - sec1;
            }
        }
    }

    private int old_to_new (Gtk.FlowBoxChild child1, Gtk.FlowBoxChild child2) {
        var imagefb1 = (Album.ImageFlowBoxChild) child1;
        var imagefb2 = (Album.ImageFlowBoxChild) child2;

        var time1 = imagefb1.time.split (":");
        var time2 = imagefb2.time.split (":");

        var hour1 = int.parse (time1[0]);
        var hour2 = int.parse (time2[0]);

        var min1 = int.parse (time1[1]);
        var min2 = int.parse (time2[1]);

        var sec1 = int.parse (time1[2]);
        var sec2 = int.parse (time2[2]);

        if (hour2 - hour1 != 0) {
            return hour1 - hour2;
        } else {
            if (min2 - min1 != 0) {
                return min1 - min2;
            } else {
                return sec1 - sec2;
            }
        }
    }
}
