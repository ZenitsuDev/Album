public class Album.FullScreenViewer : Gtk.Window {
    public Gdk.Paintable paintable { get; construct; }

    public FullScreenViewer (Gdk.Paintable paintable) {
        Object (paintable: paintable);
    }

    construct {
        var close = new Gtk.Button () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START,
            margin_top = 6,
            margin_end = 6,
            can_focus = false,
            child = new Gtk.Image.from_icon_name ("window-close-symbolic") {
                pixel_size = 24
            }
        };
        close.add_css_class (Granite.STYLE_CLASS_FLAT);

        var overlay = new Gtk.Overlay () {
            child = new Gtk.Picture.for_paintable (paintable)
        };
        overlay.add_overlay (close);

        child = overlay;
        fullscreen ();

        var key_con = new Gtk.EventControllerKey ();
        ((Gtk.Widget) this).add_controller (key_con);

        key_con.key_pressed.connect ((keyval) => {
            if (keyval == 32 || keyval == 65307) {
                this.close ();
            }
        });

        close.clicked.connect (() => {
            this.close ();
        });
    }
}
