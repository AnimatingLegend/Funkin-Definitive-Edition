package backend;

import flixel.util.FlxSave;

import states.TitleState;
import states.StoryMenuState;

/**
	* Definitive Data
	* This is more or less the same system Psych Engine has for their settings data, but with a few minor tweaks!!
	* this is still a WIP, things are subject to change.
**/
 
class DefinitiveData
{
	// Graphics
	public static var lowQuality:Bool = false;
	public static var antialiasing:Bool = true;
	public static var shaders:Bool = true;
	public static var cutscenes:Bool = true;
	public static var framerate:Int = 120;
	public static var showFPS:Bool = true;
	public static var fullscreen:Bool = false;

	// UI Stuff
	public static var accuracy:Bool = true;
	public static var judgements:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteSplashes:Bool = true;
	public static var watermark:Bool = true;
	public static var noteStrums:Bool = true; // cpu strums
	public static var laneUnderlay:Int = 0;

	// Gameplay
	public static var naughtyness:Bool = true;
	public static var downscroll:Bool = false;
	public static var middlescroll:Bool = false;
	public static var flashingLights:Bool = false;
	public static var camZoom:Bool = true;
	public static var autoPause:Bool = true;
	public static var ghostTapping:Bool = true;
	public static var scrollSpeed:Int = 1;
	public static var resetButton:Bool = false;
	public static var hitsounds:Bool = false;

	// Misc
	public static var weekUnlocked:Int = 8;

	public static function saveSettings()
	{
		FlxG.save.data.lowData = lowQuality;
		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.cutscenes = cutscenes;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.fps = showFPS;
		FlxG.save.data.fullscreen = fullscreen;
		FlxG.save.data.accuracy = accuracy;
		FlxG.save.data.judgementCounter = judgements;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.notesplash = noteSplashes;
		FlxG.save.data.glowStrums = noteStrums;
		FlxG.save.data.watermark = watermark;
		FlxG.save.data.laneUnderlay = laneUnderlay;
		FlxG.save.data.explicitContent = naughtyness;
		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.middlescroll = middlescroll;
		FlxG.save.data.flashingLights = flashingLights;
		FlxG.save.data.camhudZoom = camZoom;
		FlxG.save.data.autoPause = autoPause;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.scrollSpeed = scrollSpeed;
		FlxG.save.data.resetButton = resetButton;
		FlxG.save.data.hitsounds = hitsounds;
		FlxG.save.data.weekUnlocked = weekUnlocked;


		if (FlxG.save.data.weekUnlocked != null)
		{
			StoryMenuState.weekUnlocked = StoryMenuState.unlockWeeks();
			FlxG.save.flush();
		}

		#if desktop
		if(FlxG.save.data.framerateDraw != null)
		{
			FlxG.updateFramerate = FlxG.save.data.framerateDraw;
			FlxG.drawFramerate = FlxG.save.data.framerateDraw;
		}
		#end
	}

    public static function loadSettings()
    {
		/**
		* Graphics Stuff
		**/
		if (FlxG.save.data.lowData != null) {
			lowQuality = FlxG.save.data.lowData;
		}

		if (FlxG.save.data.antialiasing != null) {
			antialiasing = FlxG.save.data.antialiasing;
		}

		if (FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}

		if (FlxG.save.data.cutscenes != null) {
			cutscenes = FlxG.save.data.cutscenes;
		}

		/*
		if (FlxG.save.data.framerateDraw == null)
			FlxG.save.data.framerateDraw = 120;

		// baby proof so you can't hard lock your copy of this engine
		if (FlxG.save.data.framerateDraw > 240 || FlxG.save.data.framerateDraw < 60)
			FlxG.save.data.framerateDraw = 120;
		

		if (FlxG.save.data.fps != null) {
			showFPS = FlxG.save.data.fps;

			if 
		}
		*/

		if(FlxG.save.data.fullscreen != null) {
			fullscreen = FlxG.save.data.fullscreen;
		}

		/**
		* UI Stuff
		**/
		if (FlxG.save.data.accuracy != null) {
			accuracy = FlxG.save.data.accuracy;
		}

		if (FlxG.save.data.judgementCounter != null) {
			judgements = FlxG.save.data.judgementCounter;
		}

		if (FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}

		if (FlxG.save.data.notesplash != null) {
			noteSplashes = FlxG.save.data.notesplash;
		}

		if (FlxG.save.data.watermark != null)
			watermark = FlxG.save.data.watermark;

		if (FlxG.save.data.glowStrums != null) {
			noteStrums = FlxG.save.data.glowStrums;
		}

		if (FlxG.save.data.laneUnderlay != null) {
			laneUnderlay = FlxG.save.data.laneUnderlay;
		}

		/**
		* Gameplay Stuff
		**/
		if (FlxG.save.data.explicitContent != null) {
			naughtyness = FlxG.save.data.explicitContent;
		}

		if (FlxG.save.data.downscroll != null) {
			downscroll = FlxG.save.data.downscroll;
		}

		if (FlxG.save.data.middlescroll != null) {
			middlescroll = FlxG.save.data.middlescroll;
		}

		if (FlxG.save.data.flashingLights != null) {
			flashingLights = FlxG.save.data.flashingLights;
		}

		if (FlxG.save.data.camhudZoom != null) {
			camZoom = FlxG.save.data.camhudZoom;
		}

		if (FlxG.save.data.autoPause != null) {
			FlxG.autoPause = autoPause;
		}

		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}

		if (FlxG.save.data.scrollSpeed == null) {
			scrollSpeed = FlxG.save.data.scrollSpeed;
		}

		if (FlxG.save.data.resetButton != null) {
			resetButton = FlxG.save.data.resetButton;
		}

		if (FlxG.save.data.hitsounds != null) {
			hitsounds = FlxG.save.data.hitsounds;
		}

		/**
		* Misc
		**/
		if (FlxG.save.data.weekUnlocked != null) {
			weekUnlocked = FlxG.save.data.weekUnlocked;
		}
    }
}