public class Litrato.ImageFlowBoxChild : Gtk.FlowBoxChild {
    public File file { get; construct; }
    public string time { get; construct; }
    public string date { get; construct; }
    public string size_data { get; construct; }

    public ThumbnailPaintable paintable { get; set; }

    public ImageFlowBoxChild (File file, string date, string time, string size_data) {
        Object (
            file: file,
            date: date,
            time: time,
            size_data: format_size (uint64.parse (size_data))
        );
    }

    construct {
        var image = new Gtk.Image () {
            hexpand = true,
            vexpand = true,
        };
        image.paintable = paintable = new ThumbnailPaintable (file, file.get_path (), this.scale_factor);

        width_request = 100;
        height_request = 100;
        child = image;
        tooltip_text = file.get_path ();

        add_css_class (Granite.STYLE_CLASS_CARD);

        var gesture = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };
        add_controller (gesture);

        var menu = new Menu ();
        menu.append ("Move to Trash", "app.trash");

        var popover = new Gtk.PopoverMenu.from_model (menu) {
            position = Gtk.PositionType.RIGHT,
            has_arrow = false,
            autohide = true
        };
        popover.set_parent (this);

        gesture.pressed.connect ((n, x, y) => {
            popover.set_offset (((int) x) - 150, 20);
            popover.popup ();
        });

        install_action ("app.trash", null, (widget) => {
            var self = (Litrato.ImageFlowBoxChild) widget;
            var window = (Litrato.MainWindow) self.get_root ();
            window.cancel_delete_toast.send_notification ();
            window.cancel_delete_toast.handle_delete (self.file);
            window.cancel_delete_toast.default_action.connect (() => {
                self.show ();
                window.cancel_delete_toast.handle_restore (self.file);
            });
            window.cancel_delete_toast.closed.connect (() => {
                var parent = (Gtk.FlowBox) self.parent;
                parent.remove (self);
            });
            self.hide ();
        });
    }
}
