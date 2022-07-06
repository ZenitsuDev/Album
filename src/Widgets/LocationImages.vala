public class Album.LocationImages : Granite.SettingsPage {
    public string folder_name { get; construct; }
    public Album.MainWindow window { get; construct; }
    public int index { get; construct; }

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
        var box = new Gtk.ListBox () {
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

        string[] date_array = {};

        var file = File.new_for_path (folder_name);
        file.enumerate_children_async.begin ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, Priority.DEFAULT, null, (obj, res) => {
		    try {
			    var enumerator = file.enumerate_children_async.end (res);
			    FileInfo info;
			    while ((info = enumerator.next_file (null)) != null) {
				    var content_type = info.get_content_type ();
				    if ("image" in ContentType.get_mime_type (content_type)) {
				        var filename = enumerator.get_child (info).get_path ();
				        string output;

	                    try {
		                    Process.spawn_command_line_sync ("stat '%s'".printf(filename), out output, null, null);
	                    } catch (SpawnError e) {
		                    print ("Error: %s\n", e.message);
	                    }

	                    var modification_data = output.split ("\n")[5].split (" ");
	                    var modification_date = modification_data[1];
	                    var modification_time = modification_data[2];

	                    var size_data = output.split ("\n")[1].split ("  ")[1][6:];

	                    var groupable_child = new Album.ImageFlowBoxChild (enumerator.get_child (info), modification_date, modification_time, size_data);

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
            } catch (Error e) {
	            print ("Error: %s\n", e.message);
            }
        });

	    var scrolled = new Gtk.ScrolledWindow () {
	        child = box,
	        hexpand = true,
	        vexpand = true
	    };

        child = scrolled;
        hexpand = true;
        vexpand = true;
    }
}
