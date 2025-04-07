# Adding Custom Weeks

Here ill teach you how to make customs weeks in this engine!

## Requirements
- The ability to compile FDE's Source Code. If you haven't done that already, then you can read that [here](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/blob/experimental/docs/guides/building.md).
- Some sort of text editor, but Id recommend using VS Code for changing text code wise.
- A *little* bit of coding experience :]

Now lets get started !!!!

## Steps
1. Navagate through your source code. In the ```source``` folder, you'd have to open ANOTHER folder called ```states```. If you did that then look for ```StoryMenuState.hx```, and open it on VS Code.

2. Once opened, look for a function called ```weekData()```. If you cant find it, then do ```CTRL + F``` and type in the same thing. It should look like this:

```haxe
static function weekData():Array<Dynamic>
{
	return [
		['tutorial'],
		['bopeebo', 'fresh', 'dadbattle'],
		['spookeez', 'south', "monster"],
		['pico', 'philly', "blammed"],
		['satin-panties', "high", "milf"],
		['cocoa', 'eggnog', 'winter-horrorland'],
		['senpai', 'roses', 'thorns']
	];
}
```
------------------------------------------------------------
3. Copy ```['senpai', 'roses', 'thorns']```, and paste them on an empty line below, and change the song name that you want to use.
------------------------------------------------------------
### Example
```haxe
static function weekData():Array<Dynamic>
{
	return [
		['tutorial'],
		['bopeebo', 'fresh', 'dadbattle'],
		['spookeez', 'south', "monster"],
		['pico', 'philly', "blammed"],
		['satin-panties', "high", "milf"],
		['cocoa', 'eggnog', 'winter-horrorland'],
		['senpai', 'roses', 'thorns'],
		['ugh', 'guns', 'stress']
	];
}
```
------------------------------------------------------------
4. Below ```weekData()```, theres another function called ```weekCharacters()```. It functions the same way as weekData(), but this is an array that basically displays a character of your choosing instead of songs.
------------------------------------------------------------
### Example
```haxe
var weekCharacters:Array<Dynamic> = [
	['', 'bf', 'gf'],
	['dad', 'bf', 'gf'],
	['spooky', 'bf', 'gf'],
	['pico', 'bf', 'gf'],
	['mom', 'bf', 'gf'],
	['parents-christmas', 'bf', 'gf'],
	['senpai', 'bf', 'gf'],
	['tankman', 'bf', 'gf']
];
```
------------------------------------------------------------
5. Below ```weekCharacters()```, theres another function called ```weekNames()```. It's more or less exactly like the last functions but this time is for the week titles. Create a new line under ```"Hating Simulator ft. Moawling"``` and add your week name.
------------------------------------------------------------
### Example
```haxe
public static var weekNames:Array<String> = [
		"Teaching Time",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"Hating Simulator ft. Moawling",
		"Tankman ft. JohnnyUtah"
	];
```
------------------------------------------------------------
6. Displaying a week icon for your custom week is as simple as dropping a ```.png``` into ```assets/preload/images/storymenu/titles```. Rename the file to ```week6.png```, ```week7.png```, etc.
------------------------------------------------------------
### Example
![Screenshot_1 || week_titles](https://github.com/user-attachments/assets/84e81941-7022-4010-956c-0d06442cbea8)
![Screenshot_2 || story_menu_example](https://github.com/user-attachments/assets/d0fbe04f-09e4-4043-941f-f432d40a31d2)

If you followed all of the steps correctly, you will have successfully created a new week in the Story Mode!
