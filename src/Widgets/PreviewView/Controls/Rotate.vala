public class Album.Rotate : Gtk.Box {
    public Album.PreviewView view { get; construct; }
    private int current_degree = 0;

    public Rotate (Album.PreviewView view) {
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

        var animation = new Adw.TimedAnimation (view.active_picture, 0, 90, 100, 
            new Adw.CallbackAnimationTarget ((value) => {
                var scrolled = (Gtk.ScrolledWindow) view.active_picture.parent.parent;
                var w = scrolled.get_allocated_width ();
                var h = scrolled.get_allocated_height ();
                var transform = new Gsk.Transform ();

                if (direction) {
                    switch (current_degree) {
                        case 90:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((float) value);
                            transform = transform.translate ({ -h / 2.0f, -w / 2.0f });
                            view.active_picture.allocate (h, w, -1, transform);
                            break;
                        case 180:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((float) value + 90);
                            transform = transform.translate ({ -w / 2.0f, -h / 2.0f });
                            view.active_picture.allocate (w, h, -1, transform);
                            break;
                        case 270:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((float) value + 180);
                            transform = transform.translate ({ -h / 2.0f, -w / 2.0f });
                            view.active_picture.allocate (h, w, -1, transform);
                            break;
                        case 0:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((float) value + 270);
                            transform = transform.translate ({ -w / 2.0f, -h / 2.0f });
                            view.active_picture.allocate (w, h, -1, transform);
                            break;
                    }
                } else {
                    switch (current_degree) {
                        case 270:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate (-1 * (float) value);
                            transform = transform.translate ({ -h / 2.0f, -w / 2.0f });
                            view.active_picture.allocate (h, w, -1, transform);
                            break;
                        case 180:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((-1 * (float) value) - 90);
                            transform = transform.translate ({ -w / 2.0f, -h / 2.0f });
                            view.active_picture.allocate (w, h, -1, transform);
                            break;
                        case 90:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((-1 * (float) value) - 180);
                            transform = transform.translate ({ -h / 2.0f, -w / 2.0f });
                            view.active_picture.allocate (h, w, -1, transform);
                            break;
                        case 0:
                            transform = transform.translate ({ w / 2.0f, h / 2.0f });
                            transform = transform.rotate ((-1 * (float) value) - 270);
                            transform = transform.translate ({ -w / 2.0f, -h / 2.0f });
                            view.active_picture.allocate (w, h, -1, transform);
                            break;
                    }
                }
            })
        ) {
            easing = Adw.Easing.EASE_IN_OUT_CUBIC
        };
        animation.play ();
    }
}
