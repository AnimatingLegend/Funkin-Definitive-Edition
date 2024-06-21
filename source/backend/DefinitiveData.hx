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

import openfl.Lib;

import objects.Character;
import objects.Boyfriend;
import objects.Boyfriend.Pico;


using StringTools;
/**
* Stuff here is subject to change.
**/

class DefinitiveData
{
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

		if(FlxG.save.data.hideHud == null)
			FlxG.save.data.hideHud = false;

		if(FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton == false;

		if(FlxG.save.data.cutscenes == null)
			FlxG.save.data.cutscenes == true;

		if(FlxG.save.data.watermark == null)
			FlxG.save.data.watermark == true;

		if (FlxG.save.data.autoPause == null) {
		//	FlxG.save.data.autoPause = true;
			FlxG.autoPause;
		}

		if(FlxG.save.data.hitsounds == null)
			FlxG.save.data.hitsounds == false;
    }
}