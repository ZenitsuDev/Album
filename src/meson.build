sources = [
    'Application.vala',
    'MainWindow.vala',
    'Widgets/SegregatedFlowbox.vala',
    'Widgets/ImageFlowBoxChild.vala',
    'Widgets/TransitionStack.vala',
    'Widgets/LocationsSideBar.vala',
    'Widgets/ThumbnailPaintable.vala',
    'Widgets/Sorter.vala',
    'Widgets/DeleteToast.vala',

    'Widgets/FolderImagesOverview/DateSortingBox.vala',
    'Widgets/FolderImagesOverview/FolderImagesOverview.vala',

    'Widgets/PreviewView/PreviewView.vala',
    'Widgets/PreviewView/PreviewHeader.vala',
    'Widgets/PreviewView/PreviewScroller.vala',
    'Widgets/PreviewView/PictureView.vala',

    'Widgets/PreviewView/MetaDataBox.vala',
    'Widgets/PreviewView/MetaDataSideBar.vala',

    'Widgets/PreviewView/Controls/ControlsBox.vala',
    'Widgets/PreviewView/Controls/Zoom.vala',
    'Widgets/PreviewView/Controls/Rotate.vala',

    'Widgets/FullScreenView/FullScreenViewer.vala'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

executable(
    meson.project_name(),
    sources,
    gresource,
    dependencies: [
        dependency('gtk4'),
        dependency('granite-7'),
        dependency('libadwaita-1'),
        m_dep
    ],
    install: true
)


