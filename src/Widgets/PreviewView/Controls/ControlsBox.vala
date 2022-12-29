public class Litrato.ControlsBox : Gtk.Box {
    public Litrato.PreviewView preview_view { get; construct; }
    public ControlsBox (Litrato.PreviewView preview_view) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 0,
            preview_view: preview_view
        );
    }

    construct {
        var zoom_control = new Litrato.Zoom (preview_view);
        var rotate_control = new Litrato.Rotate (preview_view);

        append (rotate_control);
        append (zoom_control);

        margin_start = 10;
        margin_end = 10;
        margin_top = 10;
        margin_bottom = 10;
        hexpand = true;
    }
}
