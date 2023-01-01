public class Litrato.PreviewView : Adw.Bin {
    public Litrato.FolderImagesOverview images_overview { get; construct; }

    public Litrato.PictureWidget active_picture { get; set; }
    public Litrato.PreviewHeader preview_header { get; set; }
    public Litrato.PreviewScroller preview_scroller { get; set; }
    public Litrato.MetaDataSideBar metadata_sidebar { get; set; }

    public PreviewView (Litrato.FolderImagesOverview overview) {
        Object (images_overview: overview);
    }

    public Litrato.ImageFlowBoxChild? active {
        private get {
            return null;
        } set {
            for (var index = 0; index < preview_scroller.page_count; index++) {
                var view = preview_scroller.get_page (index);
                if (view.child.paintable == value.paintable) {
                    active_picture = view.child;
                    preview_scroller.scroll_to (view, false);
                    metadata_sidebar.update_metadata (value);
                }
            }
        }
    }

    construct {
        preview_header = new Litrato.PreviewHeader ();

        preview_scroller = new Litrato.PreviewScroller (this);

        var controls_box = new Litrato.ControlsBox (this);

        var preview_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        preview_view.append (preview_header);
        preview_view.append (preview_scroller);
        preview_view.append (controls_box);
        preview_view.add_css_class (Granite.STYLE_CLASS_VIEW);

        metadata_sidebar = new Litrato.MetaDataSideBar ();

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
                var window = new Litrato.FullScreenViewer (active_picture.paintable);
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
        var view = preview_scroller.get_page (index);
        active_picture = view.child;

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
