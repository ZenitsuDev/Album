public class Album.ImageFlowBoxChild : Gtk.FlowBoxChild {
    public File file { get; construct; }
    public string time { get; construct; }
    public string date { get; construct; }
    public string size_data { get; construct; }

    public ImageFlowBoxChild (File file, string date, string time, string size_data) {
        Object (
            file: file,
            date: date,
            time: time,
            size_data: format_size (uint64.parse (size_data))
        );
    }

    construct {
        var image = new Gtk.Image () {
            hexpand = true,
            vexpand = true
        };
        image.paintable = new ThumbnailPaintable (file, file.get_path (), image);

        width_request = 100;
        height_request = 100;
        child = image;
        tooltip_text = file.get_path ();

        add_css_class (Granite.STYLE_CLASS_CARD);
    }
}

public class ThumbnailPaintable : Object, Gdk.Paintable {
    private Gtk.Widget widget;
    private File file;
    private string tag;
    private int full_width;
    private int full_height;

    private Gdk.Texture previous_cache;
    private Gdk.Texture cache;
    private int last_width;
    private int last_height;

    private bool loading;
    private static TextureLoader loader = new TextureLoader ();

    public ThumbnailPaintable (File file, string tag, Gtk.Widget widget) {
        this.file = file;
        this.tag = tag.replace ("/", "-");
        this.widget = widget;

        Gdk.Pixbuf.get_file_info (file.get_path (), out full_width, out full_height);
    }

    private void snapshot (Gdk.Snapshot gdk_snapshot, double width, double height) {
        int w = (int) Math.ceil (width) * widget.scale_factor;
        int h = (int) Math.ceil (height) * widget.scale_factor;

        if ((w != last_width || h != last_height) && cache != null) {
            previous_cache = cache;
            cache = null;
        }

        if (cache == null && !loading) {
            last_width = w;
            last_height = h;
            loading = true;

            loader.load (file, w, h, tag, this, (w2, h2, t) => {
                loading = false;

                if (w2 == last_width && h2 == last_height) {
                    cache = t;
                    invalidate_contents ();
                }
            });
        }

        var snapshot = gdk_snapshot as Gtk.Snapshot;

        if (cache == null && previous_cache != null) {
            snapshot.append_texture (previous_cache, {{ 0, 0, }, { (float) width, (float) height }});
            return;
        }

        if (cache == null)
            return;

        snapshot.append_texture (cache, {{ 0, 0, }, { (float) width, (float) height }});
    }

    private int get_intrinsic_width () {
        return full_width;
    }

    private int get_intrinsic_height () {
        return full_height;
    }
}

public class TextureLoader : Object {
    public delegate void TextureReadyCallback (int width, int height, Gdk.Texture? texture);

    private struct TextureRequest {
        File file;
        int width;
        int height;
        string tag;
        Object source;
        unowned TextureReadyCallback cb;
    }

    private AsyncQueue<TextureRequest?> request_queue;
    private Thread thread;

    construct {
        request_queue = new AsyncQueue<TextureRequest?> ();
        thread = new Thread<void*> (null, run_loader_thread);
    }

    private void run_callback (TextureRequest request, Gdk.Texture? texture) {
        Idle.add (() => {
            request.cb (request.width, request.height, texture);
            return Source.REMOVE;
        });
    }

    private void get_dimensions (TextureRequest request, out int width, out int height, out int x, out int y) {
        var desired_width = request.width;
        var desired_height = request.height;

        int w, h;
        Gdk.Pixbuf.get_file_info (request.file.get_path (), out w, out h);

        var aspect_ratio = (double) w / h;

        if ((double) h / desired_height > (double) w / desired_width) {
            h = (int) (desired_width / aspect_ratio);
            w = desired_width;
        } else {
            w = (int) (desired_height * aspect_ratio);
            h = desired_height;
        }

        assert (w >= desired_width);
        assert (h >= desired_height);

        width = w;
        height = h;

        x = (w - desired_width) / 2;
        y = (h - desired_height) / 2;
    }


    private void* run_loader_thread () {
        while (true) {
            var request = request_queue.pop ();
            var file = request.file;

            var texture = load_from_cache (request);
            if (texture != null) {
                run_callback (request, texture);
                continue;
            }

            int x, y, width, height;
            get_dimensions (request, out width, out height, out x, out y);

            var file_path = file.get_path ();
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_scale (file_path, width, height, false);
                pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, x, y, request.width, request.height);
                save_to_cache (request, pixbuf);

                run_callback (request, Gdk.Texture.for_pixbuf (pixbuf));
            } catch (Error e) {
                Gdk.Texture texture_paintable = null;
                try {
                    texture_paintable = Gdk.Texture.from_file (file);
                } catch (Error err) {
                    critical (err.message);
                }

                var bytes = texture_paintable.save_to_png_bytes ();
                var temp_file = File.new_for_path (Environment.get_user_cache_dir () + "/" + bytes.length.to_string () + "tmp.png");
                temp_file.replace_contents (bytes.get_data (), null, false, 0, null, null);

                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (temp_file.get_path (), width, height, false);
                    pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, x, y, request.width, request.height);
                    save_to_cache (request, pixbuf);

                    run_callback (request, Gdk.Texture.for_pixbuf (pixbuf));
                } catch (Error egg) {
                    critical (egg.message);
                }
            }
        }
    }

    private File get_cache_file (TextureRequest request) throws Error {
        var cache_dir = Environment.get_user_cache_dir ();
        return File.new_for_path (@"$cache_dir/com.zendev.album.cached/$(request.width)x$(request.height)/$(request.tag)");
    }

    private Gdk.Texture? load_from_cache (TextureRequest request) {
        File file;
        try {
            file = get_cache_file (request);
        }
        catch (Error e) {
            critical (e.message);
            return null;
        }

        try {
            return Gdk.Texture.from_file (file);
        }
        catch (Error e) {
            return null;
        }
    }

    private void save_to_cache (TextureRequest request, Gdk.Pixbuf pixbuf) {
        try {
            var dir = get_cache_file (request);
            var parent = dir.get_parent ();

            if (!parent.query_exists ())
                parent.make_directory_with_parents ();

            pixbuf.save (dir.get_path (), "png", null);
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    public void load (File file, int width, int height, string tag, Object source, TextureReadyCallback cb) {
        request_queue.push_front ({ file, width, height, tag, source, cb });
    }
}
