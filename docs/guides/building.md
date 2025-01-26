# Building The Game

### Warning
**In order compile the game for Windows you will need atleast 6GB+ of space, so if you have NO space left then you should clear up some space !**

**Also note that this is a guide to build the game on your own. If you just want to play Funkin-Definitive-Edition then [download it here](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/releases). But if you want to build the game yourself, then continue reading.**

### Stuff Needed
- [Git](https://git-scm.com/) (required)
- [Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (this version is recommended because their latest versions have issues running this specific engine)
    - [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) (required)
- [Visual Community](https://visualstudio.microsoft.com/)
     - Visual Community Components (Required/Setup.bat)
     - MSVC v142 - VS 2019 C++ x64/x86 build tools - (Latest)
     - Windows 10 SDK - (Latest)
- [VS Code](https://code.visualstudio.com/Download)
    - VS Code (EXTENSTIONS)
        - [Lime](https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension)
        - [HXCCP Debugger](https://marketplace.visualstudio.com/items?itemName=vshaxe.hxcpp-debugger)

After installing everything above, you will need to install these additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
hxCodec
newgrounds
actuate
```
So for each of those type ``haxelib install [library]`` so for example ``haxelib install newgrounds``

If you installed Git or Lime then you would need to install these libraries also

```
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addon
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```

### Compiling the game
If everything is installed perfectly, then you are ready to compile the game! Follow these steps on how to do it:
- Run ```lime test <target>```. replace ```<target>``` with the platform you want to build your game with like ```windows```, ```mac```, ```linux```, & ```html5```. (ie. ```lime test windows```)
- *side note* - If you want to run the debug build of the game, then follow step 1 but put ```-debug``` after it. (ie. ```lime test windows -debug```)
- The build will be in ```Funkin-Definitive-Edition/export/release/<target>/bin```, with ```<target>``` also being the platform you're building the game with. (ie ```Funkin-Definitive-Edition/export/windows/release/bin```)

*side note* - If you're compiling the game for the first time, then it should take about 4 - 5 minutes to fully compile and start running. But after that, it should take a couple of seconds.

And if everything goes all according to plan, then your game should be compiled, and running perfectly fine!

### Additional Guides
If you want a better guide on how to use the command line then follow [ninjamuffin's haxeflixel tips guide](https://ninjamuffin99.newgrounds.com/news/post/1090480).