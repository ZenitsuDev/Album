public class Album.LocationsSideBar : Adw.Bin {
    public Gtk.Stack stack { get; construct; }

    private Gtk.ComboBoxText mobile_folder_switcher;
    private Gtk.SortListModel sort_model;
    private Gtk.ListBox listbox;

    public LocationsSideBar (Gtk.Stack stack) {
        Object (stack: stack);
    }

    public Gtk.ComboBoxText alternative {
        get {
            return mobile_folder_switcher;
        } set {
            mobile_folder_switcher = value;
            mobile_folder_switcher.changed.connect (() => {
                listbox.select_row (listbox.get_row_at_index (mobile_folder_switcher.active));
            });
            update_mobile_switchers ();
        }
    }

    construct {
        listbox = new Gtk.ListBox () {
            vexpand = true,
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };

        child = listbox;
        width_request = 200;

        var sort = new Gtk.CustomSorter ((r1, r2) => {
            var page1 = (Gtk.StackPage) r1;
            var page2 = (Gtk.StackPage) r2;

            var title1 = ((Album.LocationImages) page1.child).title;
            var title2 = ((Album.LocationImages) page2.child).title;

            if (title1 == "Trash") {
                return 1;
            } else if (title2 == "Trash") {
                return -1;
            } else {
                return 0;
            }
        });

        sort_model = new Gtk.SortListModel (stack.pages, sort);

        listbox.bind_model (sort_model, (item) => {
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

        listbox.row_selected.connect ((row) => {
            var sidebar_row = (Album.LocationsSideBarRow) row;
            stack.visible_child = sidebar_row.location_images;

            if (mobile_folder_switcher != null) {
                mobile_folder_switcher.active_id = sidebar_row.location_images.title;
            }
        });

        sort_model.items_changed.connect (() => {
            if (mobile_folder_switcher != null) {
                update_mobile_switchers ();
            }
        });
    }

    private void update_mobile_switchers () {
        if (mobile_folder_switcher != null && sort_model != null) {
            for (var index = 0; index < sort_model.get_n_items (); index++) {
                var stack_page = (Gtk.StackPage) sort_model.get_item (index);
                var loc_images = (Album.LocationImages) stack_page.child;
                mobile_folder_switcher.append (loc_images.title, loc_images.title);

                if (stack.visible_child == loc_images) {
                    mobile_folder_switcher.active_id = loc_images.title;
                }
            }
        }
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
        tooltip_text = location_images.folder_name;

        var gesture = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };
        add_controller (gesture);

        var menu = new Menu ();
        menu.append ("Remove", "app.remove");

        var popover = new Gtk.PopoverMenu.from_model (menu) {
            position = Gtk.PositionType.RIGHT,
            has_arrow = false,
            autohide = true
        };
        popover.set_parent (this);

        gesture.pressed.connect ((n, x, y) => {
            popover.set_offset (((int) x) - 180, 20);
            popover.popup ();
        });

        install_action ("app.remove", null, (widget) => {
            var self = (Album.LocationsSideBarRow) widget;
            var folders = Album.Application.settings.get_strv ("sidebar-folders");
            string[] diminished_folder = {};

            foreach (var folder in folders) {
                if (folder != self.location_images.folder_name) {
                    diminished_folder += folder;
                }
            }

            Album.Application.settings.set_strv ("sidebar-folders", diminished_folder);

            var stack = (Gtk.Stack) self.location_images.parent;
            stack.remove (self.location_images);
        });
    }
}
