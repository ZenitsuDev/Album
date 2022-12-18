public class Album.Zoom : Adw.Bin {
    public Gtk.Scale zoom_slider { get; set; }
    public Album.PreviewView preview_view { get; construct; }
    private int old_hval;
    private int old_wval;
    private Gtk.ScrolledWindow scrolled;
    private double cursor_x;
    private double cursor_y;

    public Zoom (Album.PreviewView preview_view) {
        Object (preview_view: preview_view);
    }

    construct {
        zoom_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 300, 2) {
            width_request = 250
        };
        zoom_slider.add_mark (75, Gtk.PositionType.TOP, "75 %");
        zoom_slider.add_mark (150, Gtk.PositionType.TOP, "<b>150</b>");
        zoom_slider.add_mark (225, Gtk.PositionType.TOP, "225 %");

        this.map.connect (() => {
            scrolled = (Gtk.ScrolledWindow) preview_view.active_picture.parent.parent;

            var motion_controller = (Gtk.EventControllerMotion) preview_view.active_picture.observe_controllers ().get_item (0);
            motion_controller.motion.connect ((x,y) => {
                cursor_x = x;
                cursor_y = y;
            });

            var scroll_controller = (Gtk.EventControllerScroll) scrolled.observe_controllers ().get_item (1);
            scroll_controller.scroll.connect ((x, y) => {
                if (scroll_controller.get_current_event_state () == Gdk.ModifierType.CONTROL_MASK) {
                    if (y < 0) { // zooming in
                        zoom_x (30);
                        zoom_y (30);
                    } else {
                        zoom_x (-30);
                        zoom_y (-30);
                    }

                    var hupper = scrolled.hadjustment.upper;
                    var vupper = scrolled.vadjustment.upper;
                    var hsize = scrolled.hadjustment.page_size;
                    var vsize = scrolled.vadjustment.page_size;

                    var hcenter = (hupper - hsize) / 2;
                    var vcenter = (vupper - vsize) / 2;

                    if (cursor_x < hcenter) {
                        scrolled.hadjustment.value = (hcenter - cursor_x) / 2;
                    } else {
                        scrolled.hadjustment.value = (hcenter + cursor_x) / 2;
                    }

                    if (cursor_y < vcenter) {
                        scrolled.vadjustment.value = (vcenter - cursor_y) / 2;
                    } else {
                        scrolled.vadjustment.value = (vcenter + cursor_y) / 2;
                    }
                }
            });
        });

        zoom_slider.adjustment.notify["value"].connect (() => {
            if (preview_view.active_picture != null && scrolled != null) {
                var texture = preview_view.active_picture.paintable;

                var val = (int) zoom_slider.get_value ();

                var multiplier_w = (float) texture.get_intrinsic_width () / (float) scrolled.get_allocated_width ();
                var multiplier_h = (float) texture.get_intrinsic_height () / (float) scrolled.get_allocated_height ();

                var wval = (int) (val * multiplier_w);
                var hval = (int) (val * multiplier_h);

                if (hval >= old_hval && wval >= old_wval) {
                    zoom_x (wval - old_wval);
                    zoom_y (hval - old_hval);
                } else {
                    zoom_x (-(old_wval - wval));
                    zoom_y (-(old_hval - hval));
                }

                scrolled.hadjustment.value = (scrolled.hadjustment.upper - scrolled.hadjustment.page_size) / 2;
                scrolled.vadjustment.value = (scrolled.vadjustment.upper - scrolled.vadjustment.page_size) / 2;

                old_hval = hval;
                old_wval = wval;
            }
        });
        hexpand = true;
        halign = Gtk.Align.CENTER;

        child = zoom_slider;
    }

    private void zoom_x (int val) {
        preview_view.active_picture.width_request = preview_view.active_picture.get_allocated_width () + val;
    }

    private void zoom_y (int val) {
        preview_view.active_picture.height_request = preview_view.active_picture.get_allocated_height () + val;
    }
}
