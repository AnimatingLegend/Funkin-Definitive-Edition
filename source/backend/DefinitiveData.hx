package backend;

class DefinitiveData
{
    public static function settings()
    {
		/**
		* Graphic Settings
		**/
		if(FlxG.save.data.lowData == null) // Low Quality Option
			FlxG.save.data.lowData = false;

		if(FlxG.save.data.antialiasing == null) // Antialiasing Option
			FlxG.save.data.antialiasing = true;

		if(FlxG.save.data.shaders == null) // Shader Option
			FlxG.save.data.shaders = true;

		if(FlxG.save.data.cutscenes == null) // Cutscene Option
			FlxG.save.data.cutscenes == true;

		if(FlxG.save.data.framerateDraw == null) // FPS Cap Option
			FlxG.save.data.framerateDraw = 120;

		// baby proof so you can't hard lock your copy of this engine
		if (FlxG.save.data.framerateDraw > 240 || FlxG.save.data.framerateDraw < 60)
			FlxG.save.data.framerateDraw = 120;

		if(FlxG.save.data.fps == null) // FPS Counter Option
			FlxG.save.data.fps = true;

		/**
		* UI / Visual Settings
		**/
		if(FlxG.save.data.accuracy == null) // Accuracy Counter Option
			FlxG.save.data.accuracy = true;

		if(FlxG.save.data.judgementCounter == null) // Judgement Counter Option
			FlxG.save.data.judgementCounter = true;

		if(FlxG.save.data.hideHud == null) // Hide Hud Option
			FlxG.save.data.hideHud = false;

		if(FlxG.save.data.notesplash == null) // NoteSplash Option
			FlxG.save.data.notesplash = true;

		if(FlxG.save.data.watermark == null) // Watermark Option
			FlxG.save.data.watermark == true;

		if(FlxG.save.data.glowStrums == null) // CPU Strums Option
			FlxG.save.data.glowStrums = true;

		if(FlxG.save.data.laneUnderlay == null) // Land Underlay Option
			FlxG.save.data.laneUnderlay = 0;

		/**
		* Gameplay Settings
		**/
		if(FlxG.save.data.explicitContent == null) // Naughtyness
			FlxG.save.data.explicitContent = true;

		if(FlxG.save.data.downscroll == null) // Downscroll
			FlxG.save.data.downscroll = false;

		if(FlxG.save.data.middlescroll == null) // Middlescroll
			FlxG.save.data.middlescroll = false;

		if(FlxG.save.data.flashingLights == null)
			FlxG.save.data.flashingLights = true;

		if(FlxG.save.data.camhudZoom == null)
			FlxG.save.data.camhudZoom = true;

		if (FlxG.save.data.autoPause == null)
			FlxG.autoPause = true;

		if(FlxG.save.data.ghostTapping == null)
			FlxG.save.data.ghostTapping = true;

		if(FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton == false;

		if(FlxG.save.data.hitsounds == null)
			FlxG.save.data.hitsounds == false;

		/**
		* Save Data
		**/
		if(FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 8;
    }
}