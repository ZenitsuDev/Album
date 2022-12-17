public class Album.MetaDataSideBar : Gtk.Box {
    private Album.MetaDataBox meta_data_box;
    private Gtk.Button to_preview;

    public signal void request_show_preview ();

    public MetaDataSideBar () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            width_request: 250
        );
    }

    public bool shift_to_preview_btn_visible {
        private get {
            return false;
        } set {
            to_preview.visible = value;
        }
    }

    construct {
        to_preview = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("go-previous-symbolic"),
            can_focus = false,
            visible = false
        };
        to_preview.add_css_class (Granite.STYLE_CLASS_FLAT);

        var header = new Gtk.HeaderBar () {
            decoration_layout = ":maximize",
            title_widget = new Gtk.Label ("") { visible = false },
            valign = Gtk.Align.START
        };
        header.pack_start (to_preview);
        header.add_css_class ("titlebar");
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        meta_data_box = new Album.MetaDataBox ();

        append (header);
        append (meta_data_box);
        add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        to_preview.clicked.connect (() => {
            request_show_preview ();
        });
    }

    public void update_metadata (Album.ImageFlowBoxChild child) {
        meta_data_box.update_properties (child);
    }
}
