# Compiling

> [!CAUTION]
> **In order compile the game for Windows you will need 6GB+ of space, so if you have NO space left then you should clear up some space !**
> 
> **Also note that this is a guide to build the game on your own. If you just want to play Funkin-Definitive-Edition then [download it here](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/releases)**.

## Setup
- Download **[Haxe](https://haxe.org/download)** (preferably [`v4.1.5`](https://haxe.org/download/version/4.1.5/) - [`v4.2.5`](https://haxe.org/download/version/4.2.5/))
- Download **[Git](https://git-scm.com/)**
    - Run `git clone https://github.com/AnimatingLegend/Funkin-Definitive-Edition.git` from the directory you want to store this repository.
- Run `cd Funkin-Definitive-Edition`.
- Run `haxelib --global install hmm` & `haxelib --global run hmm setup` to install hmm.json
    - Run `hmm install`.
    - Once the install is completed, run `haxelib run lime setup`.

## Platform Setup
### Windows
- Install **[Visual Studio Build Tools](https://visualstudio.microsoft.com/)**.
- When prompted, select 'Individual Components' and install the following:
    - MSVC v142 - VS 2022 C++ x64/x86 build tools
    - Windows 10/11 SDK

## Compiling
- Run `lime test <target>` to compile the game
- Run `lime run <target>` if you want to relaunch the game.

### Build Flags
Here are some of the useful build flags you can add that affects your game build. These flags can be found in [`InitState.hx`](../source/funkin/InitState.hx).
- `-debug`: Enables the in-game debug console.
- `-DPREVIEW_ANIMATION_EDITOR`: With this flag, you can forcibly launch the animation debug editor.
- `-DPREVIEW_CHART_EDITOR`: With this flag, you can forcibly launch the chart editor.
- `-DFREEPLAY_MENU`: With this flag, you can forcibly launch the freeplay menu.
    * This saves a bunch of time if you want to test songs.
- `-debug -DFEATURE_CACHE`: With this flag, you can forcibly launch the cache menu on startup when using a debug build.