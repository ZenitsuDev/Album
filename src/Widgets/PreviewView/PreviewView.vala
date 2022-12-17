public class Album.PreviewView : Adw.Bin {
    public Album.FolderImagesOverview images_overview { get; construct; }

    public Gtk.Picture active_picture { get; set; }
    public Album.PreviewHeader preview_header { get; set; }
    public Album.PreviewScroller preview_scroller { get; set; }
    public Album.MetaDataSideBar metadata_sidebar { get; set; }

    public PreviewView (Album.FolderImagesOverview overview) {
        Object (images_overview: overview);
    }

    public Album.ImageFlowBoxChild? active {
        private get {
            return null;
        } set {
            for (var index = 0; index < preview_scroller.page_count; index++) {
                var scrolled = preview_scroller.get_page (index);
                var viewport = (Gtk.Viewport) scrolled.child;
                if (((Gtk.Picture) viewport.child).paintable == value.paintable) {
                    active_picture = (Gtk.Picture) viewport.child;
                    preview_scroller.scroll_to (scrolled, false);
                    metadata_sidebar.update_metadata (value);
                }
            }
        }
    }

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
            if (active_picture != null) {
                var window = new Album.FullScreenViewer (active_picture.paintable);
                window.present ();
            }
        });

        preview_header.request_view_sidebar.connect (() => {
            leaflet.visible_child = metadata_sidebar;
        });

        metadata_sidebar.request_show_preview.connect (() => {
            leaflet.visible_child = preview_view;
        });

        preview_scroller.active_changed.connect (handle_scroller_active_changed);
    }

    private void handle_scroller_active_changed (Adw.Carousel carousel, uint index) {
        var scrolled = preview_scroller.get_page (index);
        var viewport = (Gtk.Viewport) scrolled.child;
        active_picture = (Gtk.Picture) viewport.child;

        var clicked_child_index = (int) index;
        var checked_index = 0;
        var ds_box = images_overview.date_sorting_box;

        while (ds_box.get_segfb (checked_index).children_count - 1 < clicked_child_index) {

            clicked_child_index = clicked_child_index - ds_box.get_segfb (checked_index).children_count;
            checked_index++;
        }

        images_overview.active_segfb = ds_box.get_segfb (checked_index);
        images_overview.closeable_child = images_overview.active_segfb.get_image_child (clicked_child_index);

        metadata_sidebar.update_metadata (images_overview.closeable_child);
    }
}
