public class Album.PreviewPage : Adw.Bin {
    public Adw.Carousel images_carousel { get; set; }
    public Granite.HeaderLabel label { get; set; }
    public Gtk.Button halt_button { get; set; }
    public Gtk.Picture picture { get; set; }

    private Gtk.Label meta_title;
    private Gtk.Label meta_size;
    private Gtk.Label meta_time;
    private Gtk.Label meta_date;
    private Gtk.Label meta_filepath;

    private Gtk.Button go_back;
    private Gtk.Button go_next;

    construct {
        var preview_halt_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        preview_halt_box.append (new Gtk.Image.from_icon_name ("go-previous-symbolic"));
        preview_halt_box.append (new Granite.HeaderLabel ("Return to Gallery"));

        halt_button = new Gtk.Button () {
            child = preview_halt_box
        };
        halt_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        label = new Granite.HeaderLabel ("");
        var lbl = (Gtk.Label) label.get_last_child ();
        lbl.ellipsize = Pango.EllipsizeMode.START;

        var preview_header = new Gtk.HeaderBar () {
            decoration_layout = "close:",
            title_widget = label,
            hexpand = true,
            valign = Gtk.Align.START
        };
        preview_header.pack_start (halt_button);
        preview_header.add_css_class ("titlebar");
        preview_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        preview_header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var motion_controller = new Gtk.EventControllerMotion ();

        images_carousel = new Adw.Carousel () {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20
        };

        go_back = new Gtk.Button () {
            margin_start = 20,
            child = new Gtk.Image.from_icon_name ("go-previous-symbolic") {
                pixel_size = 48
            }
        };
        go_back.add_css_class (Granite.STYLE_CLASS_FLAT);

        go_next = new Gtk.Button () {
            margin_end = 20,
            child = new Gtk.Image.from_icon_name ("go-next-symbolic") {
                pixel_size = 48
            }
        };
        go_next.add_css_class (Granite.STYLE_CLASS_FLAT);

        var back_revealer = new Gtk.Revealer () {
            child = go_back,
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 200,
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        var next_revealer = new Gtk.Revealer () {
            child = go_next,
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 200,
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER
        };

        var buttons_overlay = new Gtk.Overlay () {
            child = images_carousel,
            hexpand = true,
            vexpand = true
        };
        buttons_overlay.add_overlay (back_revealer);
        buttons_overlay.add_overlay (next_revealer);
        buttons_overlay.add_controller (motion_controller);

        var preview_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        preview_view.append (preview_header);
        preview_view.append (buttons_overlay);
        preview_view.add_css_class (Granite.STYLE_CLASS_VIEW);

        var meta_header = new Gtk.HeaderBar () {
            decoration_layout = ":maximize",
            title_widget = new Gtk.Label ("") { visible = false },
            valign = Gtk.Align.START
        };
        meta_header.add_css_class ("titlebar");
        meta_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        meta_header.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        meta_title = new Gtk.Label ("") {
            wrap = true,
            wrap_mode = Pango.WrapMode.CHAR,
            max_width_chars = 10,
            margin_top = 10,
            margin_bottom = 20
        };
        meta_title.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        meta_size = new Gtk.Label ("") {
            xalign = -1,
            use_markup = true
        };

        meta_time = new Gtk.Label ("") {
            xalign = -1,
            use_markup = true
        };

        meta_date = new Gtk.Label ("") {
            xalign = -1,
            use_markup = true
        };

        meta_filepath = new Gtk.Label ("") {
            xalign = -1,
            use_markup = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.CHAR,
            max_width_chars = 15,
            margin_top = 20
        };

        var meta_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            vexpand = true,
            margin_start = 6,
            margin_end = 6,
            margin_top = 6,
            margin_bottom = 6,
        };
        meta_box.append (meta_title);
        meta_box.append (meta_date);
        meta_box.append (meta_time);
        meta_box.append (meta_filepath);
        meta_box.append (meta_size);

        var meta_sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            width_request = 250
        };
        meta_sidebar.append (meta_header);
        meta_sidebar.append (meta_box);
        meta_sidebar.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        var leaflet = new Adw.Leaflet () {
            transition_type = Adw.LeafletTransitionType.SLIDE,
            hexpand = true,
            vexpand = true
        };
        leaflet.append (preview_view);
        leaflet.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        leaflet.append (meta_sidebar);

        child = leaflet;

        motion_controller.enter.connect (() => {
            back_revealer.reveal_child = true;
            next_revealer.reveal_child = true;
        });

        motion_controller.leave.connect (() => {
            back_revealer.reveal_child = false;
            next_revealer.reveal_child = false;
        });

        go_back.clicked.connect (() => {
            progress_carousel (false);
        });

        go_next.clicked.connect (() => {
            progress_carousel (true);
        });

        this.map.connect (handle_navigation_button_sensitivity);
        images_carousel.page_changed.connect (handle_navigation_button_sensitivity);
    }

    public void set_active (Album.ImageFlowBoxChild child) {
        for (var index = 0; index < images_carousel.n_pages; index++) {
            var viewport = (Gtk.Viewport) images_carousel.get_nth_page (index);
            if (((Gtk.Picture) viewport.child).paintable == child.paintable) {
                picture = (Gtk.Picture) viewport.child;
                images_carousel.scroll_to (viewport, false);
                update_properties (child);
            }
        }
    }

    public void update_properties (Album.ImageFlowBoxChild child) {
        meta_title.label = child.file.get_basename ();
        meta_time.label = "<b>Time modified: </b>%s".printf (child.time);
        meta_date.label = "<b>Date modified: </b>%s".printf (child.date);
        meta_size.label = "<b>File Size: </b>%s".printf (child.size_data);
        meta_filepath.label = "<b>Path: </b>%s".printf (child.file.get_path ());
    }

    private void handle_navigation_button_sensitivity () {
        if (images_carousel.position - 1 < 0) {
            go_back.sensitive = false;
        } else if (images_carousel.position >= images_carousel.n_pages - 1) {
            go_next.sensitive = false;
        } else {
            go_back.sensitive = true;
            go_next.sensitive = true;
        }
    }

    private void progress_carousel (bool progress) {
        if (progress) {
            images_carousel.scroll_to (images_carousel.get_nth_page ((uint) images_carousel.position + 1), true);
        } else {
            images_carousel.scroll_to (images_carousel.get_nth_page ((uint) images_carousel.position - 1), true);
        }
    }
}
