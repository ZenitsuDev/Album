public class Album.ImageFlowBoxChild : Gtk.FlowBoxChild {
    public File file { get; construct; }
    public string time { get; construct; }
    public string date { get; construct; }
    public string size_data { get; construct; }

    public ImageFlowBoxChild (File file, string date, string raw_time, string size_data) {
        var seconds = double.parse (raw_time[6:]);
        var new_seconds = (Math.round (seconds)).to_string ();
        new_seconds = (raw_time[6] != '0') ? new_seconds : "0" + new_seconds;

        var formatted_size = format_size (uint64.parse (size_data));
        Object (
            file: file,
            date: date,
            time: raw_time.replace (raw_time[6:], new_seconds),
            size_data: formatted_size
        );
    }

    construct {
        Gdk.Texture texture = null;
        try {
            texture = Gdk.Texture.from_file (file);
        } catch (Error e) {
            warning (e.message);
        }

        var image = new Gtk.Image.from_paintable (texture) {
            hexpand = true,
            vexpand = true
        };

        width_request = 100;
        height_request = 100;
        child = image;
        tooltip_text = file.get_path ();

        add_css_class (Granite.STYLE_CLASS_CARD);
    }
}
