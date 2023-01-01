public class Litrato.PictureView : Gtk.Widget {
    public Litrato.ImageFlowBoxChild flowbox_child { get; construct; }
    public Litrato.PictureWidget child { get; set; }
    public Gtk.EventControllerScroll scroll_controller { get; set; }
    public Gtk.Adjustment hadjustment { get; set; }
    public Gtk.Adjustment vadjustment { get; set; }

    public PictureView (Litrato.ImageFlowBoxChild flowbox_child) {
        Object (flowbox_child: flowbox_child);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        child = new Litrato.PictureWidget (flowbox_child) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            vexpand = true,
            view = this
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = child,
            hexpand = true,
            vexpand = true
        };
        scrolled.set_parent (this);

        hadjustment = scrolled.hadjustment;
        vadjustment = scrolled.vadjustment;

        scroll_controller = (Gtk.EventControllerScroll) scrolled.observe_controllers ().get_item (1);

        hexpand = true;
        vexpand = true;
    }

    ~PictureView () {
        this.get_last_child ().unparent ();
    }
}
