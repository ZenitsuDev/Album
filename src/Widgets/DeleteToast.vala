public class Litrato.DeleteToast : Granite.Toast {

    public DeleteToast (string title) {
        Object (title: title);
    }

    construct {
        set_default_action ("Undo");
    }

    public void handle_delete (File file) {
        var basename = file.get_basename ();
        var home = Environment.get_home_dir ();
        var del_file = File.new_for_path ("%s/.local/share/Trash/files/%s".printf (home, basename));

        try {
		    file.move (del_file, FileCopyFlags.NONE);
	    } catch (Error e) {
		    print ("Error: %s\n", e.message);
	    }
    }

    public void handle_restore (File file) {
        var basename = file.get_basename ();
        var home = Environment.get_home_dir ();
        var del_file = File.new_for_path ("%s/.local/share/Trash/files/%s".printf (home, basename));

        try {
		    del_file.move (file, FileCopyFlags.NONE);
	    } catch (Error e) {
		    print ("Error: %s\n", e.message);
	    }
    }
}
