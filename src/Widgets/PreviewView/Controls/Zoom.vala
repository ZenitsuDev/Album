public class Litrato.Zoom : Adw.Bin {
    public Gtk.Scale zoom_slider { get; set; }
    public Litrato.PreviewView preview_view { get; construct; }
    private int old_hval;
    private int old_wval;
    private int new_hval;
    private int new_wval;
    private Litrato.PictureView picture_view;
    private double cursor_x;
    private double cursor_y;

    public Zoom (Litrato.PreviewView preview_view) {
        Object (preview_view: preview_view);
    }

    construct {
        zoom_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 300, 2) {
            width_request = 250
        };
        zoom_slider.add_mark (75, Gtk.PositionType.TOP, "75 %");
        zoom_slider.add_mark (150, Gtk.PositionType.TOP, "<b>150</b>");
        zoom_slider.add_mark (225, Gtk.PositionType.TOP, "225 %");

        this.realize.connect (() => {
            picture_view = preview_view.active_picture.view;

            preview_view.active_picture.motion_controller.motion.connect ((x,y) => {
                cursor_x = x;
                cursor_y = y;
            });

            picture_view.scroll_controller.scroll.connect ((x, y) => {
                if (picture_view.scroll_controller.get_current_event_state () == Gdk.ModifierType.CONTROL_MASK) {
                    if (y < 0) { // zooming in
                        var zoom_val = (zoom_slider.get_value () < 300) ? Gtk.ScrollType.STEP_RIGHT : Gtk.ScrollType.NONE;
                        zoom_slider.move_slider (zoom_val);
                    } else {
                        var zoom_val = (zoom_slider.get_value () > 0) ? Gtk.ScrollType.STEP_LEFT : Gtk.ScrollType.NONE;
                        zoom_slider.move_slider (zoom_val);
                    }

                    var hupper = picture_view.hadjustment.upper;
                    var vupper = picture_view.vadjustment.upper;
                    var hsize = picture_view.hadjustment.page_size;
                    var vsize = picture_view.vadjustment.page_size;

                    var hcenter = (hupper - hsize) / 2;
                    var vcenter = (vupper - vsize) / 2;

                    if (cursor_x < hcenter) {
                        picture_view.hadjustment.value = (hcenter - cursor_x) / 2;
                    } else {
                        picture_view.hadjustment.value = (hcenter + cursor_x) / 2;
                    }

                    if (cursor_y < vcenter) {
                        picture_view.vadjustment.value = (vcenter - cursor_y) / 2;
                    } else {
                        picture_view.vadjustment.value = (vcenter + cursor_y) / 2;
                    }
                }
            });
        });

        zoom_slider.adjustment.notify["value"].connect (() => {
            if (preview_view.active_picture != null && picture_view != null) {
                var texture = preview_view.active_picture.paintable;

                var val = (int) zoom_slider.get_value ();

                var multiplier_w = (float) texture.get_intrinsic_width () / (float) picture_view.get_allocated_width ();
                var multiplier_h = (float) texture.get_intrinsic_height () / (float) picture_view.get_allocated_height ();

                new_wval = (int) (val * multiplier_w);
                new_hval = (int) (val * multiplier_h);

                if (new_hval >= old_hval && new_wval >= old_wval) {
                    zoom ((new_wval - old_wval), (new_hval - old_hval));
                } else {
                    zoom ((-(old_wval - new_wval)), (-(old_hval - new_hval)));
                }

                picture_view.hadjustment.value = (picture_view.hadjustment.upper - picture_view.hadjustment.page_size) / 2;
                picture_view.vadjustment.value = (picture_view.vadjustment.upper - picture_view.vadjustment.page_size) / 2;

                old_hval = new_hval;
                old_wval = new_wval;
            }
        });
        hexpand = true;
        halign = Gtk.Align.CENTER;

        child = zoom_slider;
    }

    private void zoom (int width, int height) {
        preview_view.active_picture.set_size_request (
            preview_view.active_picture.get_allocated_width () + width,
            preview_view.active_picture.get_allocated_height () + height
        );
    }
}
