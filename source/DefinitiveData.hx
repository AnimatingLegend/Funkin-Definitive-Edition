package;

import flixel.FlxG;
import flixel.system.FlxSound;
import PlayState;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import Boyfriend.Pico;
import flixel.math.FlxPoint;


using StringTools;
/**
* IMPORTANT STATE
* DefinitiveData is very under maintanence, but for now its main premise is to preload songs, stages, settings and gf.			
* StageData() - More or less self explanatory, but this is used to preload stages for certain weeks or songs. If this is not applied then the game will register a dummy stage (the default week 1 stage)
* Settings()  - False = not enabled by default | True = enabled by default
* GFData() & CharData() - Used to both preload the character, and the stage positioning of that character
**/

class DefinitiveData
{
	public static var forceNextDirectory:String = null;
	public static function stageData():Void
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
	
    public static function settings()
    {
        if(FlxG.save.data.judgementCounter == null)
			FlxG.save.data.judgementCounter = false;

		if(FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if(FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;
		
		if(FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen = false;

		if(FlxG.save.data.laneUnderlay == null)
			FlxG.save.data.laneUnderlay = 0;

		if(FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if(FlxG.save.data.framerateDraw == null)
			FlxG.save.data.framerateDraw = 120;

		// baby proof so you can't hard lock your copy of this engine
		if (FlxG.save.data.framerateDraw > 240 || FlxG.save.data.framerateDraw < 60)
			FlxG.save.data.framerateDraw = 120;

		if(FlxG.save.data.fps == null)
			FlxG.save.data.fps = true;

		if(FlxG.save.data.ghostTapping == null)
			FlxG.save.data.ghostTapping = true;

		if(FlxG.save.data.flashingLights == null)
			FlxG.save.data.flashingLights = true;

		if(FlxG.save.data.explicitContent == null)
			FlxG.save.data.explicitContent = true;

		if(FlxG.save.data.glowStrums == null)
			FlxG.save.data.glowStrums = true;

		if(FlxG.save.data.accuracy == null)
			FlxG.save.data.accuracy = true;

		if(FlxG.save.data.ratingHUD == null)
			FlxG.save.data.ratingHUD = true;

		if(FlxG.save.data.notesplash == null)
			FlxG.save.data.notesplash = true;

		if(FlxG.save.data.camhudZoom == null)
			FlxG.save.data.camhudZoom = true;

		if(FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if(FlxG.save.data.lowData == null)
			FlxG.save.data.lowData = false;

		if(FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 8;

		if(FlxG.save.data.shaders == null)
			FlxG.save.data.shaders = true;

		if(FlxG.save.data.practiceMode == null)
			FlxG.save.data.practiceMode = false;

		if(FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if(FlxG.save.data.instaKill == null)
			FlxG.save.data.instaKill = false;

		if(FlxG.save.data.hideHud == null)
			FlxG.save.data.hideHud = false;
    }
}