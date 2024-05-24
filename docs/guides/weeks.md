# Adding Custom Weeks

Here ill teach you how to make customs weeks in this engine!

## Requirements
- The ability to compile FDE's Source Code. If you haven't done that already, then you can read that [here](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/blob/experimental/docs/guides/building.md).
- Some sort of text editor, but Id recommend using VS Code for changing text code wise.
- A *little* bit of coding experience :]

Now lets get started !!!!

## Steps
1. Navagate through your source code. in the ```source``` folder, you'd have to open ANOTHER folder called ```states```. If you did that then look for ```StoryMenuState.hx```, and open it on VS Code.

2. Once opened, look for a function called ```weekData()```. If you cant find it then do ```CTRL + F``` and type in the same thing. It should look like this:

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
3. Copy ```['ugh', 'guns', 'stress']``` and paste them on an empty line below, and change the song name that you want to use.
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
		['ugh', 'guns', 'stress'],
                ['darnell', 'lit-up', '2hot']
	];
}
```
------------------------------------------------------------
4. Below ```weekData()```, theres another function called ```weekCharacters()```. It functions the same way as weekData() but this is an array that basically displays a character of your choosing instead of songs.
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
	['tankman', 'bf', 'gf'],
        ['darnell', 'pico', 'nene']
];
```
------------------------------------------------------------
5. Below ```weekCharacters()```, theres another function called ```weekNames()```. It's more or less exactly like the last functions but this time is for the week titles. create a new line under ```"Tankman ft. JohnnyUtah"``` and add your week name.
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
		"Tankman ft. JohnnyUtah",
        "Darnell"
	];
```
------------------------------------------------------------
6. Displaying a week icon for your custom week is as simple as dropping a ```.png``` into ```assets/preload/images/storymenu.``` Rename the file to ```week7.png```, ```week8.png```, etc.
------------------------------------------------------------
### Example
![Screenshot_1](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/assets/83415030/8e1b57a6-928f-4f4d-9138-eb28ff01f275)

![Screenshot_2](https://github.com/AnimatingLegend/Funkin-Definitive-Edition/assets/83415030/9b711550-7677-43bc-9dbb-325280635660)

*jus a little side note: i dont have darnell or nene weekCharacter assets added in the game so i removed it from weekCharacters*

If you followed all of the steps correctly, you will have successfully created a new week in the Story Mode!