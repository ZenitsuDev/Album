<div>
    <h1 align="center">Litrato</h1>
    <h3 align="center">Not to be confused with "retrato", for litrato is Filipino Translation.</h3>
    <h3 align="center">View your photos in a modern way.</h3>
</div>

![screenshot](screenshot.png)

<br>
Litrato is a photo gallery and viewer built using Vala, Gtk and Libadwaita.

## TODO
 - `Monitor changes to directories`
 - `Make dedicated Trash UI`
 - `Fix Zooming`
 - `More metadata (data) :<`
 - `Add Crop Function`
 - `Make it work on mobile`
 - `Make leaflets automatically adjusted (part of mobile)`
 - `Allow editing on other elementary software`
 - `Allow anotations`
 - `Refactor Image Displaying Procedure`
 - `Reexamine Design and UI (maybe make it look prettier?)`
 - `Make icon`
 - `Make application`
 - `Make flatpak`

## Install from source using meson
You can install Litrato by compiling it from source, here's a list of required dependencies:
 - `elementary-sdk`
 - `gtk4>=4.9`
 - `granite-7`
 - `glib-2.0`
 - `gobject-2.0`
 - `libadwaita-1`
 - `meson`

<i>For non-elementary distros, (such as Arch, Debian, etc) you are required to install "vala" as additional dependency.</i>

Clone repository and change directory
```
git clone https://github.com/treppenwitz/litrato.git
cd litrato
```

Compile, install and start Litrato on your system
```
meson _build --prefix=/usr
ninja -C _build install
com.github.treppenwitz.litrato
```

## Discussions
If you want to ask any questions or provide feedback, you can make issues in this repository

## Contributing
Feel free to send pull requests to this repository with your code.


<br>
<sup><b>License</b>: GNU GPLv3</sup>
