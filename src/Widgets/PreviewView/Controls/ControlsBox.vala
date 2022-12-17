public class Album.ControlsBox : Gtk.Box {
    public Album.PreviewView preview_view { get; construct; }
    public ControlsBox (Album.PreviewView preview_view) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 0,
            preview_view: preview_view
        );
    }

    construct {
        var zoom_control = new Album.Zoom (preview_view);
        append (zoom_control);

        margin_start = 10;
        margin_end = 10;
        margin_top = 10;
        margin_bottom = 10;
        hexpand = true;
    }
}
