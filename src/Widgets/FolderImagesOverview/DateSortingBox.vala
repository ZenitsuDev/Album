public class Litrato.DateSortingBox : Adw.Bin {
    public Litrato.MainWindow window { get; construct; }
    private Gtk.ListBox listbox;

    public DateSortingBox (Litrato.MainWindow window) {
        Object (window: window);
    }

    construct {
        listbox = new Gtk.ListBox () {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20,
            selection_mode = Gtk.SelectionMode.NONE
        };

        listbox.set_sort_func ((row1, row2) => {
            var date1 = ((Litrato.SegregatedFlowbox) row1).date.split ("-");
            var date2 = ((Litrato.SegregatedFlowbox) row2).date.split ("-");

            var year1 = int.parse (date1[0]);
            var month1 = int.parse (date1[1]);
            var day1 = int.parse (date1[2]);

            var year2 = int.parse (date2[0]);
            var month2 = int.parse (date2[1]);
            var day2 = int.parse (date2[2]);

            var func = 0;

            if (year2 - year1 != 0) {
                func = year2 - year1;
            } else {
                if (month2 - month1 != 0) {
                    func = month2 - month1;
                } else {
                    func = day2 - day1;
                }
            }

            switch (window.sorter.sort_func) {
                case 0:
                    return func; // new to old
                    break;
                case 1:
                    return func * -1; // old to new
                    break;
            }
        });

        window.sorter.sort_func_changed.connect (() => {
            listbox.invalidate_sort ();
        });

        listbox.set_filter_func ((wid) => {
            var flowbox = ((Litrato.SegregatedFlowbox) wid).main_widget;
            var children = flowbox.observe_children ();
            for (var index = 0; index < children.get_n_items (); index++) {
                var widget = (Litrato.ImageFlowBoxChild) children.get_item (index);
                widget.width_request = window.requested_image_size;
                widget.height_request = window.requested_image_size;
            }

            return true;
        });

        listbox.set_header_func ((row, before) => {
            var header = ((Litrato.SegregatedFlowbox) row).header;
            if (header != null) {
                var label = new Granite.HeaderLabel (header) {
                    halign = Gtk.Align.START
                };

                row.set_header (label);
            }
        });

        window.notify["requested-image-size"].connect (() => {
            request_icon_resize ();
        });

        child = listbox;
    }

    public Litrato.SegregatedFlowbox get_segfb (int index) {
        return (Litrato.SegregatedFlowbox) listbox.get_row_at_index (index);
    }

    public void request_icon_resize () {
        listbox.invalidate_filter ();
    }

    public void append (Litrato.SegregatedFlowbox segfb) {
        listbox.append (segfb);
    }
}
