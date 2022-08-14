# Friday Night Funkin': Defintive Editon

Everything that you see in this engine was used on my [Week 7 Port](https://github.com/LegendLOL/Funkin-Week7) project. intended to be a addon and tweak this vanilla versions gameplay, and issues overlying in it.

## Things added/changed in this engine
**Additions**
- Asset overhaul - changed charting, file locations, ETC (newgrounds week 7 update)
- Options menu + Ghost tapping + Down/MiddleScroll
- Customizable Keybindings
- Combo Sprite
- Playable characters (pico & tankman)

**Changes/Fixes**
- LOADS of gameplay fixes (Mostly week 6 & 7)
- Made Menus more appealing & easier to browse through (options menu in particular)
- Janky Input system!
![image](https://user-images.githubusercontent.com/83415030/184519445-3fa30eb0-8442-41bf-b03b-f37650949bdc.png)

![Windows Screenshot 2022 08 13 - 22 03 37 43](https://user-images.githubusercontent.com/83415030/184519479-e518c156-6b0e-4af5-a70a-32d5ff223af7.png)

## Credits
- [Legend (thats me)](https://twitter.com/AnimatingLegend) - Programmer
- [OldFlag](https://github.com/ItzOldFlagDEV) -  Additional Programmer

## Installation Shit
First, you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple). 
1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (Download 4.1.5 instead of 4.2.0 because 4.2.0 is broken and is not working with gits properly...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
**Ignored Git & Compiling Files**
I gitignore the API keys for the game so that no one can nab them and post fake high scores on the leaderboards. But because of that the game
doesn't compile without it.

Just make a file in `/source` and call it `APIStuff.hx`, and copy & paste this into it

```haxe
package;

class APIStuff
{
	public static var API:String = "";
	public static var EncKey:String = "";
}

```
if you want to learn more about compiling this game then [read here!](https://github.com/ninjamuffin99/Funkin/blob/master/README.md#compiling-game)
