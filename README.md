# Friday Night Funkin': Defintive Editon

Everything that you see in this engine was used on my [Week 7 Port](https://github.com/LegendLOL/Funkin-Week7) project. This is intended to be a more fixed and polished version of the port.

**HTML5 VERSION OUT NOW!!!**
[PLAY IT NOW!!!!](https://animatinglegend.github.io/projects/funkin-definitive-edition/)

## Credits & Shoutouts
- [Legend (thats me)](https://twitter.com/AnimatingLegend) - Programmer
- [OldFlag](https://github.com/ItzOldFlagDEV) - Additional Programmer

## Things added/changed in this engine
**Additions**
- Asset overhaul: Fixed/Changed File locations, Updated Charting, ETC
- Options menu + Ghost tapping + Down/MiddleScroll + NoteSplashes, ETC
- Cutscene Handler (HTML & Desktop Builds)
- Customizable Keybindings
- Combo Sprite, Added ratings/combo sprites to games HUD
- Playable characters (pico)
- Functionable Chart Editor

**Changes/Fixes**
- Made Menus more appealing & easier to browse through (options menu in particular)
- TONS of gameplay fixes
- Janky Input system!

## there has been atleast one change/fix to just about every week:
### Week 1:
* Added Unused stage lights
* Updated Dad's Left sing sprite
* Girlfriend does Cheering animations during Bopeebo
### Week 2:
* Added mini cutscene/transition to Monster
* When lightning occurs, the camera zooms in slightly
### Week 3:
* Your Camera shakes when a train passes by
* Boyfriend does "Hey" animation during Philly
* Girlfriend does Cheering animations during Blammed
### Week 4:
* Better hair physics for Mom & Boyfriend (identical to psych engines)
### Week 5:
* Girlfriend does Cheering animations during Cocoa & Eggnog
* On Winter Horrorland - the HUD is hidden during its mini cutscene
### Week 6:
* On Thorns - the HUD is hidden during its mini cutscene
* Fixed major dialogue bugs, tons of backend changes
* Tweaked map size for Thorns (0.9)
### Week 7:
* Tankman Cutscenes are now censored

## Photos & Gifs
### Options Menu
![Windows Screenshot 2022 08 13 - 22 03 37 43](https://user-images.githubusercontent.com/83415030/184519479-e518c156-6b0e-4af5-a70a-32d5ff223af7.png)

### Chart Editor
![Windows Screenshot 2022 08 07 - 22 53 26 56](https://user-images.githubusercontent.com/83415030/184576058-f06ddf19-7c07-494f-8529-0739b286bead.png)

### Gameplay
![ezgif-1-2b0132a422](https://user-images.githubusercontent.com/83415030/189006860-b5a84f6b-12db-4b79-ab6c-e56808a28f37.gif)

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
	inline public static var API:String = "51348:TtzK0rZ8";
	inline public static var EncKey:String = "5NqKsSVSNKHbF9fPgZPqPg==";
	inline public static var SESSION:String = null;
}

```
if you want to learn more about compiling this game then [read here!](https://github.com/ninjamuffin99/Funkin/blob/master/README.md#compiling-game)
