public class Album.PreviewScroller : Gtk.Widget {
    private Gtk.Button go_back;
    private Gtk.Button go_next;
    private Adw.Carousel images_carousel;
    private Gtk.Revealer back_revealer;
    private Gtk.Revealer next_revealer;

    public Album.PreviewView preview_view { get; construct; }

    public signal void active_changed (Adw.Carousel carousel, uint index);

    public PreviewScroller (Album.PreviewView view) {
        Object (preview_view: view);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    public uint page_count {
        get {
            return images_carousel.n_pages;
        } private set {}
    }

    public bool buttons_visible {
        private get {
            return false;
        } set {
            back_revealer.visible = next_revealer.visible = value;
        }
    }

    construct {
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

        back_revealer = new Gtk.Revealer () {
            child = go_back,
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 200,
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        next_revealer = new Gtk.Revealer () {
            child = go_next,
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 200,
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER
        };

        var motion_controller = new Gtk.EventControllerMotion ();
        var key_controller = new Gtk.EventControllerKey ();
        add_controller (key_controller);

        var buttons_overlay = new Gtk.Overlay () {
            child = images_carousel,
            hexpand = true,
            vexpand = true
        };
        buttons_overlay.add_overlay (back_revealer);
        buttons_overlay.add_overlay (next_revealer);
        buttons_overlay.add_controller (motion_controller);

        buttons_overlay.set_parent (this);
        hexpand = vexpand = true;

        images_carousel.page_changed.connect (handle_navigation_button_sensitivity);

        motion_controller.enter.connect (() => {
            back_revealer.reveal_child = next_revealer.reveal_child = true;
        });

        motion_controller.leave.connect (() => {
            back_revealer.reveal_child = next_revealer.reveal_child = false;
        });

        go_back.clicked.connect (() => {
            progress_carousel (false);
        });

        go_next.clicked.connect (() => {
            progress_carousel (true);
        });

        this.map.connect (() => {
            handle_navigation_button_sensitivity ();
        });

        this.unmap.connect (() => {
            go_back.sensitive = go_next.sensitive = true;
        });

        key_controller.key_pressed.connect ((keyval) => {
            if (keyval == 65363 && go_next.sensitive) {
                progress_carousel (true);
            } else if (keyval == 65361 && go_back.sensitive) {
                progress_carousel (false);
            }
        });

        images_carousel.page_changed.connect ((car, idx) => {
            active_changed (car, idx);
        });
    }

    ~PreviewScroller () {
        this.get_last_child ().unparent ();
    }

    public void insert_page (Gtk.ScrolledWindow child, int position) {
        images_carousel.insert (child, position);
    }

    public Gtk.ScrolledWindow get_page (uint index) {
        return (Gtk.ScrolledWindow) images_carousel.get_nth_page (index);
    }

    public void scroll_to (Gtk.ScrolledWindow child, bool animate) {
        images_carousel.scroll_to (child, animate);
    }

    private void progress_carousel (bool progress) {
        if (progress) {
            images_carousel.scroll_to (images_carousel.get_nth_page ((uint) images_carousel.position + 1), true);
        } else {
            images_carousel.scroll_to (images_carousel.get_nth_page ((uint) images_carousel.position - 1), true);
        }
    }

    private void handle_navigation_button_sensitivity () {
        if (images_carousel.position - 1 < 0) {
            go_back.sensitive = false;
        } else if (images_carousel.position >= images_carousel.n_pages - 1) {
            go_next.sensitive = false;
        } else {
            go_back.sensitive = go_next.sensitive = true;
        }
    }
}
