public class Litrato.LocationsSideBar : Adw.Bin {
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

            var title1 = ((Litrato.FolderImagesOverview) page1.child).title;
            var title2 = ((Litrato.FolderImagesOverview) page2.child).title;

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
            var image_view = (Litrato.FolderImagesOverview) stack_page.child;

            return new Litrato.LocationsSideBarRow (image_view);
        });

        listbox.set_header_func ((row, before) => {
            var header = ((Litrato.LocationsSideBarRow) row).header;
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
            var sidebar_row = (Litrato.LocationsSideBarRow) row;
            stack.visible_child = sidebar_row.image_overview;

            if (mobile_folder_switcher != null) {
                mobile_folder_switcher.active_id = sidebar_row.image_overview.title;
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
                var image_overview = (Litrato.FolderImagesOverview) stack_page.child;
                mobile_folder_switcher.append (image_overview.title, image_overview.title);

                if (stack.visible_child == image_overview) {
                    mobile_folder_switcher.active_id = image_overview.title;
                }
            }
        }
    }
}

public class Litrato.LocationsSideBarRow : Gtk.ListBoxRow {
    public Litrato.FolderImagesOverview image_overview { get; construct; }
    public string header { get; construct; }

    public LocationsSideBarRow (Litrato.FolderImagesOverview image_overview) {
        Object (
            image_overview: image_overview,
            header: image_overview.header
        );
    }

    construct {
        var label = new Gtk.Label (image_overview.title) {
            valign = Gtk.Align.CENTER,
            xalign = -1,
            margin_start = 5,
            margin_end = 5
        };
        label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        image_overview.display_widget.valign = Gtk.Align.CENTER;
        image_overview.display_widget.margin_start = 5;
        image_overview.display_widget.margin_end = 5;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (image_overview.display_widget);
        box.append (label);

        child = box;
        tooltip_text = image_overview.folder_name;

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
            var self = (Litrato.LocationsSideBarRow) widget;
            var folders = Litrato.Application.settings.get_strv ("sidebar-folders");
            string[] diminished_folder = {};

            foreach (var folder in folders) {
                if (folder != self.image_overview.folder_name) {
                    diminished_folder += folder;
                }
            }

            Litrato.Application.settings.set_strv ("sidebar-folders", diminished_folder);

            var stack = (Gtk.Stack) self.image_overview.parent;
            stack.remove (self.image_overview);
        });
    }
}
