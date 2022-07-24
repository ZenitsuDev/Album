public class Album.SegregatedFlowbox : Gtk.ListBoxRow {
    public string date { get; construct; }
    public Album.MainWindow window { get; construct; }
    public Album.LocationImages location_images { get; construct; }

    public Gtk.FlowBox main_widget { get; set; }
    public int index { get; set; }
    public int children_count { get; set; }
    public string header { get; set; }

    public signal void can_close (bool condition);

    private string[] weekdays = {
        "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday", "Sunday"
    };

    public SegregatedFlowbox (Album.LocationImages location_images, string date, Album.MainWindow window) {
        Object (
            date: date,
            window: window,
            location_images: location_images
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

            var func = 0;
            if (hour2 - hour1 != 0) {
                func = hour2 - hour1;
            } else {
                if (min2 - min1 != 0) {
                    func = min2 - min1;
                } else {
                    func = sec2 - sec1;
                }
            }

            switch (window.setting_popover.sort_func) {
                case 0:
                    return func; // new to old
                    break;
                case 1:
                    return func * -1; // old to new
                    break;
            }
        });

        window.setting_popover.sort_func_changed.connect (() => {
            main_widget.invalidate_sort ();
        });

        header = formatted_date ();
        child = main_widget;
        can_focus = false;

        main_widget.child_activated.connect ((chil) => {
            var child = (Album.ImageFlowBoxChild) chil;
            index = child.get_index ();

            location_images.preview_page.set_active (child);

            window.transition_stack.add_shared_element (child.child, location_images.preview_page.picture);
            window.transition_stack.navigate (window.preview_container);
            location_images.preview_page.picture.add_css_class ("checkered");

            can_close (true);
        });

        can_close.connect ((condition) => {
            if (condition) {
                location_images.preview_page.halt_button.clicked.connect (location_images.halt_preview);
            } else {
                location_images.preview_page.halt_button.clicked.disconnect (location_images.halt_preview);
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
        children_count = (int) main_widget.observe_children ().get_n_items ();
    }
}
