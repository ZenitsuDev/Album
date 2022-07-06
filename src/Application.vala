public class Album.Application : Gtk.Application {
    public static Settings settings;
    public Application () {
        Object (
            application_id: "com.zendev.album",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings ("com.zendev.album");
    }

    protected override void activate () {
        var window = new Album.MainWindow (this);
        window.present ();

        add_window (window);

        settings.bind ("window-width", window, "default-width", SettingsBindFlags.DEFAULT);
        settings.bind ("window-height", window, "default-height", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        settings.bind ("window-maximized", window, "maximized", SettingsBindFlags.SET);
    }

    public static int main (string[] args) {
        var app = new Album.Application ();
        return app.run (args);
    }
}
