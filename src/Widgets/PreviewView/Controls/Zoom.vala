public class Album.Zoom : Gtk.Widget {
    public Gtk.Scale zoom_slider { get; set; }
    public Album.PreviewView preview_view { get; construct; }

    public Zoom (Album.PreviewView preview_view) {
        Object (preview_view: preview_view);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        zoom_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 100, 300, 2) {
            width_request = 250
        };
        zoom_slider.set_value (100);
        zoom_slider.add_mark (150, Gtk.PositionType.TOP, "150 %");
        zoom_slider.add_mark (200, Gtk.PositionType.TOP, "<b>200</b>");
        zoom_slider.add_mark (250, Gtk.PositionType.TOP, "250 %");

        zoom_slider.adjustment.notify["value"].connect (() => {
            if (preview_view.picture != null) {
                var val = (float) zoom_slider.get_value () / 100;
                ((ThumbnailPaintable) preview_view.picture.paintable).scale = val;
            }
        });
        hexpand = true;
        halign = Gtk.Align.CENTER;

        zoom_slider.set_parent (this);
    }

    ~Zoom () {
        this.get_last_child ().unparent ();
    }
}
