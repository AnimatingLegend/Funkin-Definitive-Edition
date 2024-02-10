package;

import flixel.FlxG;
import flixel.system.FlxSound;
import PlayState;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

class DefinitiveData
{
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

		if(FlxG.save.data.timerOption == null)
			FlxG.save.data.timerOption = true;

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
			FlxG.save.data.hideHud == false;
    }
}