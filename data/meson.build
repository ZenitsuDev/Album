gnome = import('gnome')
gresource = gnome.compile_resources(
    'album-resources',
    'album.gresource.xml',
    source_dir: join_paths(meson.source_root(), 'data')
)

install_data(
    'album.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)
