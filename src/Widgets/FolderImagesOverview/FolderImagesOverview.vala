public class Album.FolderImagesOverview : Granite.SettingsPage {
    public string folder_name { get; construct; }
    public int index { get; construct; }
    public Album.MainWindow window { get; construct; }

    public Album.PreviewView preview_page { get; set; }
    public Album.ImageFlowBoxChild closeable_child { get; set; }
    public Album.SegregatedFlowbox active_segfb { get; set; }
    public Album.DateSortingBox date_sorting_box { get; set; }

    private string[] date_array = {};

    public FolderImagesOverview (string folder, int index, Album.MainWindow window) {
        var home_name = Environment.get_variable ("HOME");
        var title_name = (folder == home_name) ? "Home" : Filename.display_basename (folder);
        var image = new Gtk.Image () {
            pixel_size = 24
        };

        switch (title_name) {
            case "Home":
                image.gicon = new ThemedIcon ("user-home");
                break;
            case "Documents":
                image.gicon = new ThemedIcon ("folder-documents");
                break;
            case "Music":
                image.gicon = new ThemedIcon ("folder-music");
                break;
            case "Pictures":
                image.gicon = new ThemedIcon ("folder-pictures");
                break;
            case "Videos":
                image.gicon = new ThemedIcon ("folder-videos");
                break;
            case "Downloads":
                image.gicon = new ThemedIcon ("folder-download");
                break;
            default:
                image.gicon = new ThemedIcon ("folder");
                break;
        }

        if (".local/share/Trash/files" in folder) {
            title_name = "Trash";
            image.gicon = new ThemedIcon ("user-trash");
        }

        Object (
            display_widget: image,
            folder_name: folder,
            title: title_name,
            header: (index == 0) ? "Locations" : null,
            window: window,
            index: index
        );
    }

    construct {
        var file = File.new_for_path (folder_name);
        load_images.begin (file);

        date_sorting_box = new Album.DateSortingBox (window);

        preview_page = new Album.PreviewView (this);

	    var scrolled = new Gtk.ScrolledWindow () {
	        child = date_sorting_box,
	        hexpand = true,
	        vexpand = true
	    };

	    child = scrolled;
        hexpand = true;
        vexpand = true;

        var keyboard_resize = new Gtk.EventControllerKey ();
	    scrolled.add_controller (keyboard_resize);

	    this.map.connect (() => {
            window.preview_container.child = preview_page;
            scrolled.grab_focus ();
        });

	    var controller1 = (Gtk.EventControllerScroll) scrolled.observe_controllers ().get_item (2);
	    controller1.scroll.connect ((event, x, y) => {
	        var state = event.get_current_event_state ();
            if (state == Gdk.ModifierType.CONTROL_MASK) {
                if (y > 0 && window.requested_image_size < 200) {
                    enlarge_icons (true);
                } else if (y < 0 && window.requested_image_size > 50) {
                    enlarge_icons (false);
                }
                return true;
            } else {
                return false;
            }
	    });

	    keyboard_resize.key_pressed.connect ((keyval, keycode, mod) => {
	        if (mod == Gdk.ModifierType.CONTROL_MASK) {
	            if (Gdk.keyval_name (keyval) == "equal" && window.requested_image_size < 200) {
	                enlarge_icons (true);
	            } else if (Gdk.keyval_name (keyval) == "minus" && window.requested_image_size > 50){
	                enlarge_icons (false);
	            }
	        }
	    });
    }

    private void enlarge_icons (bool val) {
        if (val) {
            window.requested_image_size = window.requested_image_size + 5;
        } else {
            window.requested_image_size = window.requested_image_size - 5;
        }

        date_sorting_box.request_icon_resize ();
        Album.Application.settings.set_int ("image-size", window.requested_image_size);
    }

    public void halt_preview () {
        window.transition_stack.add_shared_element (preview_page.active_picture, closeable_child.child);
        window.transition_stack.navigate (window.leaflet);

        active_segfb.can_close = false;
    }

    private async void load_images (File folder) {
        try {
            var e = yield folder.enumerate_children_async ("standard::*", 0, Priority.DEFAULT);
            FileInfo info;

            while ((info = e.next_file ()) != null) {
                var content_type = info.get_content_type ();
                if ("image" in ContentType.get_mime_type (content_type)) {
                    var file = folder.resolve_relative_path (info.get_name ());
                    append_image_file (info, file);
                }
            }
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }

    private void append_image_file (FileInfo info, File file) {
        var filename = file.get_path ();

    	var stat_file = Stat (filename);
        var time = Time.local (stat_file.st_mtime);
        var modification_date = "%d-%d-%d".printf (time.year + 1900, time.month, time.day);
        var modification_time = "%d:%s:%s".printf (time.hour,
            (time.minute > 9) ? time.minute.to_string () : "0" + time.minute.to_string (),
            (time.second > 9) ? time.second.to_string () : "0" + time.second.to_string ()
        );

        var size_data = info.get_size ().to_string ();

        var groupable_child = new Album.ImageFlowBoxChild (file, modification_date, modification_time, size_data);

        if (!(modification_date in date_array)) {
            var segregated_flowbox = new Album.SegregatedFlowbox (this, modification_date, window);
            segregated_flowbox.append (groupable_child);
            date_array += modification_date;
            date_sorting_box.append (segregated_flowbox);
        } else {
            for (var index = 0; index < date_array.length; index++) {
                if (date_array[index] == modification_date) {
                    var fb = date_sorting_box.get_segfb (index);
                    fb.append (groupable_child);
                }
            }
        }

        var picture = new Gtk.Picture.for_paintable (groupable_child.paintable) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            vexpand = true,
            keep_aspect_ratio = true
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = picture,
            hexpand = true,
            vexpand = true
        };

        var position = derive_position (groupable_child);
        preview_page.preview_scroller.insert_page (scrolled, position);
    }

    private int derive_position (Album.ImageFlowBoxChild child) {
        var segregated_flowbox = (Album.SegregatedFlowbox) child.parent.parent;
        var segfb_index = segregated_flowbox.get_index ();

        int item_index = 0;
        for (var index = 0; index < segfb_index; index++) {
            var prev_segfb = date_sorting_box.get_segfb (index);
            item_index += (int) prev_segfb.children_count;
        }

        return item_index + child.get_index ();
    }
}
