public class Litrato.Rotate : Gtk.Box {
    public Litrato.PreviewView view { get; construct; }
    private int current_degree = 0;

    public Rotate (Litrato.PreviewView view) {
        Object (
            view: view,
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 10
        );
    }

    construct {
        var rotate_left_image = new Gtk.Image.from_icon_name ("object-rotate-left-symbolic") {
            pixel_size = 24
        };

        var rotate_right_image = new Gtk.Image.from_icon_name ("object-rotate-right-symbolic") {
            pixel_size = 24
        };

        var rotate_left_button = new Gtk.Button () {
            child = rotate_left_image,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.END
        };
        rotate_left_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var rotate_right_button = new Gtk.Button () {
            child = rotate_right_image,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.END
        };
        rotate_right_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        halign = Gtk.Align.END;
        valign = Gtk.Align.CENTER;

        append (rotate_left_button);
        append (rotate_right_button);

        rotate_left_button.clicked.connect (() => {
            rotate (false);
        });

        rotate_right_button.clicked.connect (() => {
            rotate (true);
        });
    }

    private void rotate (bool direction) { // false is counter, true is clockwise
        if (direction) {
            current_degree += 90;

            if (current_degree == 360) {
                current_degree = 0;
            }
        } else {
            if (current_degree == 0) {
                current_degree = 360;
            }

            current_degree -= 90;
        }

        var animation = new Adw.TimedAnimation (view.active_picture, 0, 90, 200, new Adw.CallbackAnimationTarget ((value) => {
            view.active_picture.is_rotating = true;
            view.active_picture.current_degree = current_degree;
            view.active_picture.direction = direction;
            if (direction) {
                view.active_picture.degree = current_degree + value - 90;
            } else {
                view.active_picture.degree = (-1 * (float) value) - (270 - current_degree);
            }
            view.active_picture.queue_resize ();
        })) {
            easing = Adw.Easing.EASE_IN_OUT_CUBIC
        };
        animation.play ();
    }
}
