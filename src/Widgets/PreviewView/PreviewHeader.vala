public class Litrato.PreviewHeader : Gtk.Widget {
    private Granite.HeaderLabel label;
    private Gtk.Button view_fullscreen;
    private Gtk.Button folded_view_info;
    private Gtk.Box preview_halt_box;

    public signal void request_halt_preview ();
    public signal void request_fullscreen ();
    public signal void request_view_sidebar ();

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    public string? active_title {
        private get {
            return null;
        } set {
            ((Gtk.Label) label.get_last_child ()).set_label (value);
        }
    }

    public bool parent_folded {
        private get {
            return false;
        } set {
            view_fullscreen.visible = preview_halt_box.get_last_child ().visible = value;
            folded_view_info.visible = value ? false : true;
        }
    }

    construct {
        preview_halt_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        preview_halt_box.append (new Gtk.Image.from_icon_name ("go-previous-symbolic"));
        preview_halt_box.append (new Granite.HeaderLabel ("Return to Gallery"));

        var halt_button = new Gtk.Button () {
            child = preview_halt_box
        };
        halt_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        label = new Granite.HeaderLabel ("");
        var lbl = (Gtk.Label) label.get_last_child ();
        lbl.ellipsize = Pango.EllipsizeMode.START;

        view_fullscreen = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("video-display-symbolic"),
            can_focus = false
        };
        view_fullscreen.add_css_class (Granite.STYLE_CLASS_FLAT);

        folded_view_info = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("dialog-information-symbolic"),
            can_focus = false,
            visible = false
        };
        folded_view_info.add_css_class (Granite.STYLE_CLASS_FLAT);

        var preview_header = new Gtk.HeaderBar () {
            decoration_layout = "close:",
            title_widget = label,
            hexpand = true,
            valign = Gtk.Align.START
        };
        preview_header.pack_start (halt_button);
        preview_header.pack_end (view_fullscreen);
        preview_header.pack_end (folded_view_info);
        preview_header.add_css_class ("titlebar");
        preview_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        preview_header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        preview_header.set_parent (this);
        hexpand = true;

        halt_button.clicked.connect (() => {
            request_halt_preview ();
        });

        view_fullscreen.clicked.connect (() => {
            request_fullscreen ();
        });

        folded_view_info.clicked.connect (() => {
            request_view_sidebar ();
        });
    }

    ~PreviewHeader () {
        this.get_last_child ().unparent ();
    }
}
