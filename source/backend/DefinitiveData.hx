package backend;

import flixel.FlxG;
import flixel.util.FlxSave;
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
* DISCLAIMER - IMPORTANT STATE (well one of them, think of this as a Main.hx part 2 but instead of using components trying to build the game its components IN the game to make it run better and more easier to navigate and use.)
* Settings()  - False = not enabled by default | True = enabled by default

* STAGE STUFF MOVED TO `Stage.hx`
**/

@:structInit class SaveVariables {
	public var autoPause:Bool = true;
}

class DefinitiveData
{
	public static var prefs:SaveVariables = {};

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
		
		#if (html5 && !switch)
		if(FlxG.save.data.framerateDraw == null)
			FlxG.save.data.framerateDraw = 120;

		FlxG.autoPause = DefinitiveData.prefs.autoPause;
		#end

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

		if(FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton == false;
    }
}