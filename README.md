# Friday Night Funkin' - Definitive Edition

Everything you see in this engine was used in my [Week 7 Port](https://github.com/LegendLOL/Funkin-Week7) project. This is intended to be a more fixed and polished version of the port.

## Credits
**Friday Night Funkin'**
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programming
- [PhantomArcade3k](https://twitter.com/phantomarcade3k?lang=en) & [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Music

**Definitive Edition**
- [Legend](https://twitter.com/AnimatingLegend) - Lead Programmer/Creator

**Shoutouts**
- [yck](https://github.com/YckenEhh) - Additional Programmer (helped optimze a bunch of code)
- [TackDrawz](https://www.youtube.com/channel/UCAPDPJuunLWQJzOXA_3yEfw) - Art (made a couple of assets for my engine!)

## Things added/changed in this engine
**Additions**
- Asset overhaul: Fixed/Changed File locations, Updated Charting, ETC
- Options menu + Ghost tapping + Down/MiddleScroll + NoteSplashes, ETC
- Cutscene Handler (HTML & Desktop Builds)
- Customizable Keybindings
- Combo Sprite, Added ratings/combo sprites to games HUD
- Playable characters (pico)
- Functional Chart Editor

**Changes/Fixes**
- Made Menus more appealing & easier to browse through (options menu in particular)
- TONS of gameplay fixes
- Janky Input system!

## There has been at least one change/fix to just about every week:
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
* Better hair physics for Mom and boyfriend (identical to psych engines)
### Week 5:
* Girlfriend does Cheering animations during Cocoa & Eggnog
* On Winter Horrorland - the HUD is hidden during its mini-cutscene
### Week 6:
* On Thorns - the HUD is hidden during its mini cutscene
* Fixed major dialogue bugs, tons of backend changes
* Tweaked map size for Thorns (0.9)
### Week 7:
* Cutscenes can now be censored (again lol)

## Photos & Gifs

### Chart Editor
![Windows Screenshot 2022 08 07 - 22 53 26 56](https://user-images.githubusercontent.com/83415030/184576058-f06ddf19-7c07-494f-8529-0739b286bead.png)

### Character Editor
![Windows Screenshot 2023 12 17 - 0 0 0 0](https://cdn.discordapp.com/attachments/707022397789831261/1186123403783065691/image.png?ex=65921a80&is=657fa580&hm=d3f4dc2108f9d55e828020cf5d2617211750b813f314fe0e7912ee4ee7c120c6&)

### Gameplay
![fnf-gameplay](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/assets/83415030/546aced4-6c30-4d3f-93ed-a70fb06314ca)

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
