public class Album.LocationImages : Granite.SettingsPage {
    public string folder_name { get; construct; }
    public int index { get; construct; }
    public Album.MainWindow window { get; construct; }

    public Album.PreviewPage preview_page { get; set; }
    public Album.ImageFlowBoxChild closeable_child { get; set; }
    public Album.SegregatedFlowbox active_segfb { get; set; }

    private Gtk.ListBox box;
    private string[] date_array = {};

    public LocationImages (string folder, int index, Album.MainWindow window) {
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
        box = new Gtk.ListBox () {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20,
            selection_mode = Gtk.SelectionMode.NONE
        };

        box.set_sort_func ((row1, row2) => {
            var date1 = ((Album.SegregatedFlowbox) row1).date.split ("-");
            var date2 = ((Album.SegregatedFlowbox) row2).date.split ("-");

            var year1 = int.parse (date1[0]);
            var month1 = int.parse (date1[1]);
            var day1 = int.parse (date1[2]);

            var year2 = int.parse (date2[0]);
            var month2 = int.parse (date2[1]);
            var day2 = int.parse (date2[2]);

            var func = 0;

            if (year2 - year1 != 0) {
                func = year2 - year1;
            } else {
                if (month2 - month1 != 0) {
                    func = month2 - month1;
                } else {
                    func = day2 - day1;
                }
            }

            switch (window.setting_popover.sort_func) {
                case 0:
                    return func; // new to old
                    break;
                case 1:
                    return func * -1; // old to new
                    break;
            }
        });

        window.setting_popover.sort_func_changed.connect (() => {
            box.invalidate_sort ();
        });

        box.set_filter_func ((wid) => {
            var flowbox = ((Album.SegregatedFlowbox) wid).main_widget;
            var children = flowbox.observe_children ();
            for (var index = 0; index < children.get_n_items (); index++) {
                var widget = (Album.ImageFlowBoxChild) children.get_item (index);
                widget.width_request = window.requested_image_size;
                widget.height_request = window.requested_image_size;
            }

            return true;
        });

        box.set_header_func ((row, before) => {
            var header = ((Album.SegregatedFlowbox) row).header;
            if (header != null) {
                var label = new Granite.HeaderLabel (header) {
                    halign = Gtk.Align.START
                };

                row.set_header (label);
            }
        });

        window.notify["requested-image-size"].connect (() => {
            box.invalidate_filter ();
        });

        preview_page = new Album.PreviewPage ();

        preview_page.images_carousel.page_changed.connect ((carousel, idx) => {
            var scrolled = (Gtk.ScrolledWindow) preview_page.images_carousel.get_nth_page (idx);
            var viewport = (Gtk.Viewport) scrolled.child;
            preview_page.picture = (Gtk.Picture) viewport.child;

            var new_index = (int) idx;
            var box_index = 0;
            while (((Album.SegregatedFlowbox) box.get_row_at_index (box_index))
                .children_count - 1 < new_index) {

                new_index = new_index -
                    ((Album.SegregatedFlowbox) box.get_row_at_index (box_index)).children_count;
                box_index++;
            }

            active_segfb = (Album.SegregatedFlowbox) box.get_row_at_index (box_index);
            closeable_child = (Album.ImageFlowBoxChild) 
                active_segfb.main_widget.get_child_at_index (new_index);

            preview_page.update_properties (closeable_child);
        });

        var file = File.new_for_path (folder_name);
        load_images.begin (file);

	    var keyboard_resize = new Gtk.EventControllerKey ();
	    var scrolled = new Gtk.ScrolledWindow () {
	        child = box,
	        hexpand = true,
	        vexpand = true
	    };
	    scrolled.add_controller (keyboard_resize);

	    this.map.connect (() => {
            window.preview_container.child = preview_page;
            scrolled.grab_focus ();
        });

	    var controller1 = (Gtk.EventControllerScroll) scrolled.observe_controllers ().get_item (2);
	    controller1.scroll.connect ((event, x, y) => {
	        var state = event.get_current_event_state ();
            if (state.to_string () == "GDK_CONTROL_MASK") {
                if (y > 0 && window.requested_image_size < 200) {
                    zoom (true);
                } else if (y < 0 && window.requested_image_size > 50) {
                    zoom (false);
                }
                return true;
            } else {
                return false;
            }
	    });

	    keyboard_resize.key_pressed.connect ((keyval, keycode, mod) => {
	        if (mod.to_string () == "GDK_CONTROL_MASK") {
	            if (keyval == 65451 && window.requested_image_size < 200) {
	                zoom (true);
	            } else if (keyval == 65453 && window.requested_image_size > 50){
	                zoom (false);
	            }
	        }
	    });

        child = scrolled;
        hexpand = true;
        vexpand = true;
    }

    private void zoom (bool val) {
        if (val) {
            window.requested_image_size = window.requested_image_size + 5;
        } else {
            window.requested_image_size = window.requested_image_size - 5;
        }

        box.invalidate_filter ();
        Album.Application.settings.set_int ("image-size", window.requested_image_size);
    }

    public void halt_preview () {
        window.transition_stack.add_shared_element (preview_page.picture, closeable_child.child);
        window.transition_stack.navigate (window.leaflet);

        active_segfb.can_close (false);
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
            box.append (segregated_flowbox);
        } else {
            for (var index = 0; index < date_array.length; index++) {
                if (date_array[index] == modification_date) {
                    var fb = (Album.SegregatedFlowbox) box.get_row_at_index (index);
                    fb.append (groupable_child);
                }
            }
        }

        var picture = new Gtk.Picture.for_paintable (groupable_child.paintable) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            vexpand = true
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = picture,
            hexpand = true,
            vexpand = true
        };

        var position = derive_position (groupable_child);
        preview_page.images_carousel.insert (scrolled, position);
    }

    private int derive_position (Album.ImageFlowBoxChild child) {
        var segregated_flowbox = (Album.SegregatedFlowbox) child.parent.parent;
        var segfb_index = segregated_flowbox.get_index ();

        int item_index = 0;
        for (var index = 0; index < segfb_index; index++) {
            var prev_segfb = (Album.SegregatedFlowbox) box.get_row_at_index (index);
            item_index += (int) prev_segfb.main_widget.observe_children ().get_n_items ();
        }

        return item_index + child.get_index ();
    }
}
