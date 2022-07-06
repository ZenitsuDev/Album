public class Album.LocationsSideBar : Adw.Bin {
    public Gtk.Stack stack { get; construct; }
    public LocationsSideBar (Gtk.Stack stack) {
        Object (
            stack: stack
        );
    }

    construct {
        var listbox = new Gtk.ListBox () {
            vexpand = true,
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };

        child = listbox;
        width_request = 200;

        listbox.bind_model (stack.pages, (item) => {
            var stack_page = (Gtk.StackPage) item;
            var image_view = (Album.LocationImages) stack_page.child;

            return new Album.LocationsSideBarRow (image_view);
        });

        listbox.set_header_func ((row, before) => {
            var header = ((Album.LocationsSideBarRow) row).header;
            if (header != null) {
                var label = new Gtk.Label (header) {
                    halign = Gtk.Align.START,
                    xalign = 0
                };

                label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
                row.set_header (label);
            }
        });

        listbox.row_activated.connect ((row) => {
            var sidebar_row = (Album.LocationsSideBarRow) row;
            stack.visible_child = sidebar_row.location_images;
        });
    }
}

public class Album.LocationsSideBarRow : Gtk.ListBoxRow {
    public Album.LocationImages location_images { get; construct; }
    public string header { get; construct; }

    public LocationsSideBarRow (Album.LocationImages location_images) {
        Object (
            location_images: location_images,
            header: location_images.header
        );
    }

    construct {
        var label = new Gtk.Label (location_images.title) {
            valign = Gtk.Align.CENTER,
            xalign = -1,
            margin_start = 5,
            margin_end = 5
        };
        label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        location_images.display_widget.valign = Gtk.Align.CENTER;
        location_images.display_widget.margin_start = 5;
        location_images.display_widget.margin_end = 5;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (location_images.display_widget);
        box.append (label);

        child = box;

        var gesture = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };
        add_controller (gesture);

        var remove_button = new Gtk.Button.with_label ("Remove") {
            width_request = 100,
            height_request = 20,
            margin_top = 6,
            margin_bottom = 6,
            can_focus = false
        };
        remove_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var popover = new Gtk.Popover () {
            position = Gtk.PositionType.RIGHT,
            has_arrow = false,
            autohide = true,
            child = remove_button
        };
        popover.set_parent (this);

        gesture.pressed.connect ((n, x, y) => {
            popover.set_offset (((int) x) - 180, 20);
            popover.popup ();
        });

        remove_button.clicked.connect (() => {
            var folders = Album.Application.settings.get_strv ("sidebar-folders");
            var gen_array = new GenericArray<string> ();
            gen_array.data = folders;

            gen_array.remove_index (location_images.index);

            folders = gen_array.data;

            Album.Application.settings.set_strv ("sidebar-folders", folders);

            popover.popdown ();
            var stack = (Gtk.Stack) location_images.parent;
            stack.remove (location_images);
        });
    }
}
