# Building The Game

*Warning: In order compile the game for Windows you will need 6GB+ of space, so if you have NO space left then you should clear up some space !!!!*

### Stuff Needed
- [Git](https://git-scm.com/)(required)
- [Haxe 4.1.5](https://haxe.org/download/version/4.1.5/)(required)
    - [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)(required)
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
newgrounds
actuate
```
So for each of those type ``haxelib install [library]`` so for example ``haxelib install newgrounds``

If you installed Git or Lime then you would need to install these libraries also

```
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addon
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git extension-webm https://github.com/KadeDev/extension-webm
lime rebuild extension-webm windows
```

### Compiling the game
If everthing is installed perfectly then you should be able to compile the game nicely. You just need to run ```lime test html5 -debug``` to build the HTML5 version of the game. if you want to run the game on desktop then you can do ```lime test <windows, linux, mac>``` (if you want a better guide on how to use the command line then follow [ninjamuffin's haxeflixel tips guide](https://ninjamuffin99.newgrounds.com/news/post/1090480).)