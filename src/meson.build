sources = [
    'Application.vala',
    'MainWindow.vala',
    'Widgets/LocationImages.vala',
    'Widgets/SegregatedFlowbox.vala',
    'Widgets/ImageFlowBoxChild.vala',
    'Widgets/TransitionStack.vala',
    'Widgets/PreviewPage.vala',
    'Widgets/LocationsSideBar.vala',
    'Widgets/SettingPopover.vala'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gtk4'),
        dependency('granite-7'),
        dependency('libadwaita-1'),
        m_dep
    ],
    install: true
)


