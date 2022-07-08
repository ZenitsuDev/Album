public class Album.LocationImages : Granite.SettingsPage {
    public string folder_name { get; construct; }
    public Album.MainWindow window { get; construct; }
    public int index { get; construct; }

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

            if (year2 - year1 != 0) {
                return year2 - year1;
            } else {
                if (month2 - month1 != 0) {
                    return month2 - month1;
                } else {
                    return day2 - day1;
                }
            }
        });

        var file = File.new_for_path (folder_name);
        load_images.begin (file);

	    var scrolled = new Gtk.ScrolledWindow () {
	        child = box,
	        hexpand = true,
	        vexpand = true
	    };

        child = scrolled;
        hexpand = true;
        vexpand = true;
    }

    private async void load_images (File folder) {
        try {
            var e = yield folder.enumerate_children_async ("standard::*", 0, Priority.DEFAULT);
            FileInfo info;

            while ((info = e.next_file ()) != null) {
                var content_type = info.get_content_type ();
                if ("image" in ContentType.get_mime_type (content_type)) {
                    var file = folder.resolve_relative_path (info.get_name ());
                    append_image_file (file);
                }
            }
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }

    private void append_image_file (File file) {
        var filename = file.get_path ();

    	var stat_file = Stat (filename);
        var time = Time.local (stat_file.st_mtime);
        var modification_date = "%d-%d-%d".printf (time.year + 1900, time.month, time.day);
        var modification_time = "%d:%d:%d".printf (time.hour, time.minute, time.second);

        var size_data = "1000";

        var groupable_child = new Album.ImageFlowBoxChild (file, modification_date, modification_time, size_data);

        if (!(modification_date in date_array)) {
            var segregated_flowbox = new Album.SegregatedFlowbox (modification_date, window);
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
    }
}
