public class Album.PictureView : Gtk.Widget {
    public Gdk.Paintable paintable { get; construct; }
    public float scale { get; set; }
    public bool is_rotating { get; set; }
    public double degree { get; set; }
    public int current_degree { get; set; }
    public bool direction { get; set; }
    private float diff_scaling = 1;

    public PictureView (Gdk.Paintable paintable) {
        Object (paintable: paintable);
    }

    construct {
        scale = 1.0f;
    }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        int x, y;
        double w, h;

        if (paintable == null) {
          return;
        }

        var width = this.get_width () * scale;
        var height = this.get_height () * scale;
        var ratio = paintable.get_intrinsic_aspect_ratio ();

        double picture_ratio = (double) width / height;

        if (ratio > picture_ratio) {
            w = width;
            h = width / ratio;
        } else {
            w = height * ratio;
            h = height;
        }

        x = (int) (width - Math.ceil (w)) / 2;
        y = (int) Math.floor (height - Math.ceil (h)) / 2;

        if (is_rotating) {
            if (width > parent.get_height () && (current_degree == 90 || current_degree == 270)) {
                double multiplier;
                if (direction) {
                    multiplier = (degree < 180) ? (degree / 90) : ((degree - 180) / 90);
                } else {
                    multiplier = (degree < 0 && degree >= -90) ? ((degree * -1) / 90) : (((degree * -1) - 180) / 90);
                }

                var difference = width - parent.get_height ();
                var decimal = difference * multiplier;
                var allowed_scaling = decimal / width;
                diff_scaling = 1.0f - (float) allowed_scaling;
            } else {
                double multiplier;
                if (direction) {
                    multiplier = (degree < 270 && degree >= 0) ? ((degree - 90) / 90) : ((90 - (degree * -1)) / 90);
                } else {
                    multiplier = (degree >= -180 && degree <= -90) ? (((degree.abs ()) - 90) / 90) : (((degree.abs ()) - 270) / 90);
                }

                var difference = 1 - diff_scaling;
                var additive = difference * multiplier;
                diff_scaling += (float) additive;
            }

            snapshot.translate ({width / 2.0f, height / 2.0f });
            snapshot.scale (diff_scaling, diff_scaling);
            snapshot.rotate ((float) degree);
            snapshot.translate ({width / -2.0f, height / -2.0f });
        }

        snapshot.save ();
        snapshot.translate ({x, y});
        paintable.snapshot (snapshot, w, h);
        snapshot.restore ();
    }

    protected override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.CONSTANT_SIZE;
    }

    protected override void measure (Gtk.Orientation orientation, int for_size, out int min, out int nat, out int minb, out int natb) {
        minb = -1;
        natb = -1;

        /* for_size = 0 below is treated as -1, but we want to return zeros. */
        if (paintable == null || for_size == 0) {
          min = 0;
          nat = 0;
          return;
        }

        var min_width = parent.get_allocated_width ();
        var min_height = parent.get_allocated_height ();
        var default_size = 100;
        double nat_width, nat_height;

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            paintable.compute_concrete_size (0, (for_size < 0) ? 0 : for_size, default_size, default_size, out nat_width, out nat_height);
            min = (int) (Math.ceil (min_width) * scale);
            nat = (int) (Math.ceil (nat_width) * scale);
        } else {
            paintable.compute_concrete_size ((for_size < 0) ? 0 : for_size, 0, default_size, default_size, out nat_width, out nat_height);
            min = (int) (Math.ceil (min_height) * scale);
            nat = (int) (Math.ceil (nat_height) * scale);
        }

        if (nat < min) {
            min = nat;
        }
    }

    ~PictureView () {
        this.get_last_child ().unparent ();
    }
}
