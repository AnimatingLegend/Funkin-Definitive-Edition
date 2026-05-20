package funkin.backend.utils;

class DefinitiveData
{
    	public static function initialize()
    	{
		/**
		* Graphic Settings
		**/
		if (FlxG.save.data.lowQuality == null) FlxG.save.data.lowQuality = false;
		if (FlxG.save.data.antialiasing == null) FlxG.save.data.antialiasing = true;
		if (FlxG.save.data.shaders == null) FlxG.save.data.shaders = true;
		if (FlxG.save.data.debugDisplay == null) FlxG.save.data.debugDisplay = false;
		if (Main.debugDisplay != null)
		{
			Main.toggleFPS(FlxG.save.data.debugDisplay);
			Main.debugDisplay.backgroundOpacity = FlxG.save.data.debugDisplayBGOpacity / 100;
			Main.debugDisplay.set_backgroundOpacityVisible(FlxG.save.data.debugDisplay);
		}
		if (FlxG.save.data.debugDisplayBGOpacity == null) FlxG.save.data.debugDisplayBGOpacity = 50;
		if (FlxG.save.data.fpsCap == null) FlxG.save.data.fpsCap = 60;
		if (FlxG.save.data.fpsCap > 280 || FlxG.save.data.fpsCap < 60) FlxG.save.data.fpsCap = 60;
		if (FlxG.save.data.launchInFullscreen == null) FlxG.save.data.launchInFullscreen = false;

		/**
		 * UI Settings
		 */
		if (FlxG.save.data.accuracyDisplay == null) FlxG.save.data.accuracyDisplay = true;
		if (FlxG.save.data.JudgementDisplay == null) FlxG.save.data.JudgementDisplay = true;
		if (FlxG.save.data.hideHUD == null) FlxG.save.data.hideHUD = false;
		if (FlxG.save.data.strumLineBG == null) FlxG.save.data.strumLineBG = 0.0;
		if (FlxG.save.data.noteSplash == null) FlxG.save.data.noteSplash = true;
		if (FlxG.save.data.hideCPUStrums == null) FlxG.save.data.hideCPUStrums = true;
		if (FlxG.save.data.fdeWatermark == null) FlxG.save.data.fdeWatermark = true;

		/**
		* Gameplay Settings
		**/
		if (FlxG.save.data.naughtyness == null) FlxG.save.data.naughtyness = true;
		if (FlxG.save.data.downscroll == null) FlxG.save.data.downscroll = false;
		if (FlxG.save.data.middlescroll == null) FlxG.save.data.middlescroll = false;
		if (FlxG.save.data.flashingLights == null) FlxG.save.data.flashingLights = true;
		if (FlxG.save.data.cameraZooms == null) FlxG.save.data.cameraZooms = true;
		if (FlxG.save.data.autoPause == null) FlxG.save.data.autoPause = true;
		if (FlxG.save.data.ghostTapping == null) FlxG.save.data.ghostTapping = true;
		if (FlxG.save.data.hitsoundVolume == null) FlxG.save.data.hitsoundVolume = 0.0;
		if (FlxG.save.data.scrollSpeed == null) FlxG.save.data.scrollSpeed = 1;

		/**
		 * Save Data
		 */
		if (FlxG.save.data.weeksUnlocked == null) FlxG.save.data.weeksUnlocked = 8;
		if (FlxG.save.data.resetHighscores == null) FlxG.save.data.resetHighscores = 0;
    	}
}