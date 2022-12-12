public class Album.PreviewView : Adw.Bin {
    // public Adw.Carousel images_carousel { get; set; }
    public Gtk.Picture picture { get; set; }
    public Album.PreviewHeader preview_header { get; set; }
    public Album.PreviewScroller preview_scroller { get; set; }

    private Gtk.Label meta_title;
    private Gtk.Label meta_size;
    private Gtk.Label meta_time;
    private Gtk.Label meta_date;
    private Gtk.Label meta_filepath;
    private Gtk.Scale zoom_slider;
    private Gtk.ScrolledWindow scrolled;

    // private Gtk.Button go_back;
    // private Gtk.Button go_next;

    construct {
        preview_header = new Album.PreviewHeader ();

        preview_scroller = new Album.PreviewScroller (this);

        zoom_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 100, 300, 2) {
            width_request = 250,
            hexpand = true,
            halign = Gtk.Align.CENTER
        };
        zoom_slider.set_value (100);
        zoom_slider.add_mark (150, Gtk.PositionType.TOP, "150 %");
        zoom_slider.add_mark (200, Gtk.PositionType.TOP, "<b>200</b>");
        zoom_slider.add_mark (250, Gtk.PositionType.TOP, "250 %");

        zoom_slider.adjustment.notify["value"].connect (() => {
            if (picture != null) {
                var val = (float) zoom_slider.get_value () / 100;
                ((ThumbnailPaintable) picture.paintable).scale = val;
            }
        });

        var controls_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_start = 10,
            margin_end = 10,
            margin_top = 10,
            margin_bottom = 10,
            hexpand = true
        };
        controls_box.append (zoom_slider);

        var preview_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        preview_view.append (preview_header);
        // preview_view.append (buttons_overlay);
        preview_view.append (preview_scroller);
        preview_view.append (controls_box);
        preview_view.add_css_class (Granite.STYLE_CLASS_VIEW);

        var to_preview = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("go-previous-symbolic"),
            can_focus = false,
            visible = false
        };
        to_preview.add_css_class (Granite.STYLE_CLASS_FLAT);

        var meta_header = new Gtk.HeaderBar () {
            decoration_layout = ":maximize",
            title_widget = new Gtk.Label ("") { visible = false },
            valign = Gtk.Align.START
        };
        meta_header.pack_start (to_preview);
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

        leaflet.notify["folded"].connect (() => {
            if (leaflet.folded) {
                preview_scroller.buttons_visible = preview_header.parent_folded = false;
                to_preview.visible = true;
            } else {
                preview_scroller.buttons_visible = preview_header.parent_folded = true;
                to_preview.visible = false;
            }
        });

        preview_header.request_fullscreen.connect (() => {
            if (picture != null) {
                var window = new Album.FullScreenViewer (picture.paintable);
                window.present ();
            }
        });

        preview_header.request_view_sidebar.connect (() => {
            leaflet.visible_child = meta_sidebar;
        });

        to_preview.clicked.connect (() => {
            leaflet.visible_child = preview_view;
        });
    }

    public void set_active (Album.ImageFlowBoxChild child) {
        for (var index = 0; index < preview_scroller.page_count; index++) {
            scrolled = preview_scroller.get_page (index);
            var viewport = (Gtk.Viewport) scrolled.child;
            if (((Gtk.Picture) viewport.child).paintable == child.paintable) {
                picture = (Gtk.Picture) viewport.child;
                preview_scroller.scroll_to (scrolled, false);
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
}
