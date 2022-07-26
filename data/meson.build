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

icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, 'album.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name () + '.svg'
    )
    install_data(
        join_paths('icons', i, 'album.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name () + '.svg'
    )
endforeach
