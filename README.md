## General Info

Steam Sky is an open source roguelike with a steampunk setting. You are a
commander of a flying ship, as leader you will be traveling across floating
bases, engaging in combat, trading goods etc. There is no mandatory ending
to the game, you may freely play until your character dies. The game is
currently under heavy development, but is in a playable state. Steam Sky is
available for Linux and Windows.

## Game versions
There are currently 2 versions of the game:
- 3.0.x: "stable" version of game. This version will receive bug fixes but
  no new features. Source code for this version is in *3.0* branch.
- 3.x: "development" version of game, future version 4.0. This is where
  game feature updates happen. Due to new features, save compatibility
  will typically break between releases. Use this version at your own risk.
  Source code for this version is in the *master* branch.

## Build game from sources

To build(works on Linux and Windows too) you need:

* compiler - GCC with enabled Ada support or (best option) GNAT from:

  https://www.adacore.com/download/

  It is recommended to use GNAT GPL 2018 to compile the game on Linux.
  Game does not work with old compilers (like GCC 4.9) since it
  lacks full support for Ada 2012

* GtkAda library which should be available in most Linux distributions. Best
  option is to use (with GNAT GPL) AdaCore version of GtkAda from:

  https://www.adacore.com/download/more

  At this moment tested version of GtkAda is 2018 and game require GTK library
  in version 3.14 (may not works with other versions).

If you have all the required packages, navigate to the main directory(where
this file is) to compile:

* Easiest way to compile game is use Gnat Programming Studio included in GNAT.
  Just run GPS, select *steamsky.gpr* as a project file and select option
  `Build All`.

* If you prefer using console: in main source code directory type `gprbuild`
  for debug mode build or for release mode: `gprbuild -XMode=release`


## Running Steam Sky

### Linux
If you downloaded the binaries, you're set. Just run the `./steamsky.sh`
script to start the game. The game will not work without some variables
set in that script.


### Windows
If you compiled the game or downloaded the binaries just clicking on
`steamsky.exe` in the `bin` directory should run it.

### Starting parameters
You can specify the game directories through command-line parameters.
Possible options are:

* --datadir=[directory] This is where the game data files are kept.
   Example: `./steamsky.sh --datadir=/home/user/game/tmp`.
   Default value is *data/*

* --savedir=[directory] This is where savegames and logs are kept.
   The Game must have write permission to this directory.
   Example: `./steamsky.sh --savedir=/home/user/.saves`.
   Default value is *data/saves/*

* --docdir=[directory] This is where the game documentation is.
   Example `./steamsky.sh --docdir=/usr/share/steamsky/doc`.
   Default value is *doc/*.

* --modsdir=[directory] This is where mods are loaded from.
   Example:`./steamsky.sh --modsdir=/home/user/.mods`.
   Default value is *data/mods/*

* --themesdir=[directory] This is where custom themes are loaded from.
   Example: `./steamsky.sh --themesdir=/home/user/.mods`.
   Default value is *data/themes/*

Of course, you can set all parameters together:
`./steamsky.sh --datadir=somedir/ --savedir=otherdir/ --docdir=anotherdir/`

Paths to directories can be absolute or relative where file `steamsky` is. For
Windows, use `steamsky.exe` instead `./steamsky.sh`.

## Modding Support
For detailed informations about modifying various game elements or debugging
game, see [MODDING.md](bin/doc/MODDING.md)

## Contributing to project
For detailed informations about contributing to the project
(bugs reporting, ideas propositions, code conduct, etc),
see [CONTRIBUTING.md](bin/doc/CONTRIBUTING.md)

## Licenses
The game is made available under the [GPLv3](bin/doc/COPYING) license.

The GtkAda and XmlAda libraries distributed with game are also under the GPLv3 license.

The Gtk library distributed with game is under the LGPLv2.1 license: https://www.gtk.org/

The Licensing for the fonts distributed with the game is as follows:

* Font Roboto is under Apache v2.0 license: https://fonts.google.com/specimen/Roboto
* Font Hack is under MIT license: https://sourcefoundry.org/hack/
* Font Z003 is under AGPL v3 license: https://github.com/ArtifexSoftware/urw-base35-fonts
* Font Rye is under Open Font License: https://fonts.google.com/specimen/Rye


The changelog and a copy of the GPLv3 license can be found in the [doc](bin/doc) directory.


That's all for now, as usual, probably I forgot about something important ;)

Bartek thindil Jasicki
