package states.stages;

import flixel.FlxG;
import flixel.system.FlxSound;
import states.PlayState;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.math.FlxPoint;

import objects.Character;
import objects.Boyfriend;
import objects.Boyfriend.Pico;

using StringTools;

/**
* Welcome To `StageData.hx`!
* Basically, to put it in more simpler terms
* Its Pretty jank rn, but as time moves forward it will probably be more polished and easier to understand :]

** INSTRUCTIONS **
* `songData()` - Add a song 
* `charData()` - To sum it up, this basically preloads the character, and the positioning of the stage they are on.
* `gfData()`   - This is literally `charData()` but only for the gf assets.
**/

class StageData extends MusicBeatState
{
    public static function songData():Void
	{
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'spookeez' | 'south' | 'monster':
					PlayState.curStage = 'spooky';
				case 'pico' | 'philly' | 'blammed':
					PlayState.curStage = 'philly';
				case 'satin-panties' | 'high' | 'milf':
					PlayState.curStage = 'limo';
				case 'cocoa' | 'eggnog':
					PlayState.curStage = 'mall';
				case 'winter-horrorland':
					PlayState.curStage = 'mallEvil';
				case 'senpai' | 'roses':
					PlayState.curStage = 'school';
				case 'thorns':
					PlayState.curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					PlayState.curStage = 'tank';
				default:
					PlayState.curStage = 'stage';
			}
		}

		PlayState.SONG.stage = PlayState.curStage;
	}

    public static function gfData():Void
	{
		switch (PlayState.curStage) 
		{
			case 'limo':
				PlayState.curGF = 'gf-car';
			case 'mall' | 'mallEvil':
				PlayState.curGF = 'gf-christmas';
			case 'school' | 'schoolEvil':
				PlayState.curGF = 'gf-pixel';
			case 'tank':
				PlayState.curGF = 'gf-tankmen';
			default:
				PlayState.curGF = 'gf';
		}

		if (PlayState.SONG.song.toLowerCase() == 'stress')
			PlayState.curGF = 'pico-speaker';

		PlayState.gf = new Character(400, 130, PlayState.curGF);
		PlayState.gf.scrollFactor.set(0.95, 0.95);
	}

    public static function charData():Void
	{
		PlayState.dad = new Character(100, 100, PlayState.SONG.player2);
		PlayState.camPos = new FlxPoint(PlayState.dad.getGraphicMidpoint().x, PlayState.dad.getGraphicMidpoint().y);

		PlayState.pico = new Pico(100, 100, PlayState.SONG.player1);
		PlayState.boyfriend = new Boyfriend(770, 450, PlayState.SONG.player1);

		if (PlayState.pico.curCharacter == 'pico-player')
			PlayState.camPos.x += 450;

		switch (PlayState.SONG.player2) 
		{
			case 'gf':
				PlayState.dad.setPosition(PlayState.gf.x, PlayState.gf.y);
				PlayState.gf.visible = false;
				if (PlayState.isStoryMode) {
					PlayState.camPos.x += 600;
					PlayState.tweenCamIn();
				}
			case "spooky":
				PlayState.dad.y += 200;
			case "monster":
				PlayState.dad.y += 100;
			case 'monster-christmas':
				PlayState.dad.y += 130;
			case 'dad':
				PlayState.camPos.x += 400;
			case 'pico':
				PlayState.camPos.x += 600;
				PlayState.dad.y += 300;
			case 'parents-christmas':
				PlayState.dad.x -= 500;
			case 'senpai':
				PlayState.dad.x += 150;
				PlayState.dad.y += 360;
				PlayState.camPos.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				PlayState.dad.x += 150;
				PlayState.dad.y += 360;
				PlayState.camPos.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y);
			case 'spirit':
				PlayState.dad.x -= 150;
				PlayState.dad.y += 100;
				PlayState.camPos.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y);
			case 'tankman':
				PlayState.dad.y += 180;
			case 'bf-pixel-opponent':
				PlayState.dad.x -= 80;
				PlayState.dad.y += 460;
				PlayState.camPos.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y);
		}

		// Stage Positioning
		switch (PlayState.curStage) 
		{
			case 'spooky':
				PlayState.pico.x += 100;
				PlayState.pico.y -= 60;

			case 'limo':
				PlayState.boyfriend.y -= 220;
				PlayState.boyfriend.x += 260;

			case 'mall':
				PlayState.boyfriend.x += 200;

			case 'mallEvil':
				PlayState.boyfriend.x += 320;
				PlayState.dad.y -= 80;

			case 'school':
				PlayState.boyfriend.x += 200;
				PlayState.boyfriend.y += 220;
				PlayState.gf.x += 180;
				PlayState.gf.y += 300;

			case 'schoolEvil':
				PlayState.boyfriend.x += 200;
				PlayState.boyfriend.y += 220;
				PlayState.gf.x += 180;
				PlayState.gf.y += 300;

			case 'tank':
				PlayState.gf.y += 10;
				PlayState.gf.x -= 30;
				PlayState.boyfriend.x += 40;
				PlayState.boyfriend.y += 0;
				PlayState.dad.y += 60;
				PlayState.dad.x -= 80;

				if (PlayState.curGF != 'pico-speaker') {
					PlayState.gf.x -= 170;
					PlayState.gf.y -= 75;
				}
		}
	}
}