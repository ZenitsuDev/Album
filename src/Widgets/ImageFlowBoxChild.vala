public class Album.ImageFlowBoxChild : Gtk.FlowBoxChild {
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
    }
}
