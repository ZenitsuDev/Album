public class Album.PreviewView : Adw.Bin {
    public Gtk.Picture picture { get; set; }
    public Album.PreviewHeader preview_header { get; set; }
    public Album.PreviewScroller preview_scroller { get; set; }
    public Album.MetaDataSideBar metadata_sidebar { get; set; }

    construct {
        preview_header = new Album.PreviewHeader ();

        preview_scroller = new Album.PreviewScroller (this);

        var controls_box = new Album.ControlsBox (this);

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

    public Album.ImageFlowBoxChild? active {
        private get {
            return null;
        } set {
            for (var index = 0; index < preview_scroller.page_count; index++) {
                var scrolled = preview_scroller.get_page (index);
                var viewport = (Gtk.Viewport) scrolled.child;
                if (((Gtk.Picture) viewport.child).paintable == value.paintable) {
                    picture = (Gtk.Picture) viewport.child;
                    preview_scroller.scroll_to (scrolled, false);
                    metadata_sidebar.update_metadata (value);
                }
            }
        }
    }
}
