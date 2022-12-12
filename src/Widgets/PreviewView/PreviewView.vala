public class Album.PreviewView : Adw.Bin {
    public Gtk.Picture picture { get; set; }
    public Album.PreviewHeader preview_header { get; set; }
    public Album.PreviewScroller preview_scroller { get; set; }
    public Album.MetaDataSideBar metadata_sidebar { get; set; }

    private Gtk.Scale zoom_slider;
    private Gtk.ScrolledWindow scrolled;

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
        preview_view.append (preview_scroller);
        preview_view.append (controls_box);
        preview_view.add_css_class (Granite.STYLE_CLASS_VIEW);

        metadata_sidebar = new Album.MetaDataSideBar ();

        var leaflet = new Adw.Leaflet () {
            transition_type = Adw.LeafletTransitionType.SLIDE,
            hexpand = true,
            vexpand = true
        };
        leaflet.append (preview_view);
        leaflet.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        leaflet.append (metadata_sidebar);

        child = leaflet;

        leaflet.notify["folded"].connect (() => {
            if (leaflet.folded) {
                preview_scroller.buttons_visible = preview_header.parent_folded = false;
                metadata_sidebar.shift_to_preview_btn_visible = true;
            } else {
                preview_scroller.buttons_visible = preview_header.parent_folded = true;
                metadata_sidebar.shift_to_preview_btn_visible = false;
            }
        });

        preview_header.request_fullscreen.connect (() => {
            if (picture != null) {
                var window = new Album.FullScreenViewer (picture.paintable);
                window.present ();
            }
        });

        preview_header.request_view_sidebar.connect (() => {
            leaflet.visible_child = metadata_sidebar;
        });

        metadata_sidebar.request_show_preview.connect (() => {
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
                metadata_sidebar.update_metadata (child);
            }
        }
    }
}
