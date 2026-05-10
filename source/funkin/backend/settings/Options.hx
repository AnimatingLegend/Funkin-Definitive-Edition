package funkin.backend.settings;

import funkin.backend.utils.DefinitiveData;
import funkin.backend.utils.Highscore;

import funkin.menus.OptionsMenuState;
import funkin.menus.StoryMenuState;

/**
 * Initialize a new option category (i.e. Controls, Graphics, etc.)
 */
class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	private var _name:String = "New Category";

	public final function getOptions():Array<Option>
		return _options;

	public final function addOption(opt:Option)
		_options.push(opt);

	public final function removeOption(opt:Option)
		_options.remove(opt);

	public final function getName()
		return _name;

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

/**
 * Initialize a new option
 */
class Option
{
	public function new()
		display = updateDisplay();

	private var display:String;
	private var description:String = "";
	private var acceptValues:Bool = false;

	public var withoutCheckboxes:Bool = false;
	public var boldDisplay:Bool = true;

	/**
	 * Get the display of the option
	 * @return String
		return display
	 */
	public final function getDisplay():String
		return display;

	/**
	 * Get the accept value of the option
	 * @return Bool
		return acceptValues
	 */
	public final function getAccept():Bool
		return acceptValues;

	/**
	 * Get the description of the option
	 * @return String
		return description
	 */
	public final function getDescription():String
		return description;

	/**
	 * Press the option
	 * @param changeData 
	 * @return Bool
		return false
	 */
	public function pressKey(value:Bool):Bool
		return false;

	/**
	 * Update the display
	 * @return String
		return ""
	 */
	private function updateDisplay():String
		return "";

	/**
	 * If your option has number values press your left key to update.
	 * @return Bool
		return false
	 */
	public function pressLeftKey():Bool
		return false;

	/**
	 * If your option has number values press your right key to update.
	 * @return Bool
		return false
	 */
	public function pressRightKey():Bool
		return false;
}

// * ---------------------------------------	* \\
// * GRAPHIC SETTINGS                       	* \\
// * --------------------------------------- * \\
class LowQuality extends Option
{
	public function new(desc:String):Void
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.lowQuality = !FlxG.save.data.lowQuality;
		acceptValues = FlxG.save.data.lowQuality;
		display = updateDisplay();

		return true;
	}

	private override function updateDisplay():String
		return 'Low Quality';
}

class Antialiasing extends Option
{
	public function new(desc:String):Void
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;

		acceptValues = FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Antialiasing';
}

class Shaders extends Option
{
	public function new(desc:String):Void
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.shaders = !FlxG.save.data.shaders;

		acceptValues = FlxG.save.data.shaders;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Shaders';
}

class DebugDisplayOP extends Option
{
	public function new(desc:String):Void
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) 
		{
			FlxG.save.data.debugDisplay = !FlxG.save.data.debugDisplay;

			Main.toggleFPS(FlxG.save.data.debugDisplay);
			Main.debugDisplay.set_backgroundOpacity(FlxG.save.data.debugDisplayBGOpacity / 100);
			Main.debugDisplay.set_backgroundOpacityVisible(FlxG.save.data.debugDisplay);
		}

		acceptValues = FlxG.save.data.debugDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Debug Display';
}

class DebugDisplayBGOP extends Option
{
	public function new(desc:String):Void
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function pressLeftKey():Bool
	{
		// If the value is greater than 0, decrease it by 50%.
		if (FlxG.save.data.debugDisplayBGOpacity > 0)
		{
			FlxG.save.data.debugDisplayBGOpacity -= 50;

			// If the value is less than 0, return it.
			if (FlxG.save.data.debugDisplayBGOpacity < 0) return false;
			FlxG.save.data.debugDisplayBGOpacity = FlxMath.roundDecimal(FlxG.save.data.debugDisplayBGOpacity, 2);
		}
		Main.debugDisplay.backgroundOpacity = FlxG.save.data.debugDisplayBGOpacity / 100;

		FlxG.save.flush();
		display = updateDisplay();
		return true;
	}

	public override function pressRightKey():Bool
	{
		// If the value is less than 100, increase it by 50%.
		if (FlxG.save.data.debugDisplayBGOpacity < 100) FlxG.save.data.debugDisplayBGOpacity += 50;
		FlxG.save.data.debugDisplayBGOpacity = FlxMath.roundDecimal(FlxG.save.data.debugDisplayBGOpacity, 2);
		Main.debugDisplay.backgroundOpacity = FlxG.save.data.debugDisplayBGOpacity / 100;

		FlxG.save.flush();
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return '<${FlxG.save.data.debugDisplayBGOpacity}> Debug Display BG';
}

class FPSCap extends Option
{
	public function new(desc:String):Void
	{
		super();
		description = desc;
		withoutCheckboxes = true;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function pressLeftKey():Bool
	{
		// If shift is pressed, decrease the framerate by 10, otherwise decrease it by 1.
		if (FlxG.drawFramerate > 60) FlxG.drawFramerate -= 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.fpsCap = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;

		FlxG.save.flush();
		display = updateDisplay();

		trace('[SETTINGS] Decrease FPS Cap to ${FlxG.save.data.fpsCap}.');
		return true;
	}

	public override function pressRightKey():Bool
	{
		// If shift is pressed, increase the framerate by 10, otherwise increase it by 1.
		if (FlxG.drawFramerate < 280) FlxG.drawFramerate += 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.fpsCap = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;

		FlxG.save.flush();
		display = updateDisplay();

		trace('[SETTINGS] Increase FPS Cap to ${FlxG.save.data.fpsCap}.');
		return true;
	}

	private override function updateDisplay():String
		return '<${FlxG.drawFramerate}> FPS Cap';
}

class LaunchInFullscreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value)
		{
			// If you close the game and relaunch it, the game will launch in fullscreen.
			FlxG.save.data.launchInFullscreen = !FlxG.save.data.launchInFullscreen;
			FlxG.save.flush();
		}

		acceptValues = FlxG.save.data.launchInFullscreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Launch in Fullscreen';
}

// * ---------------------------------------	* \\
// * UI SETTINGS                       		* \\
// * --------------------------------------- * \\
class AccuracyDisplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;

		acceptValues = FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Accuracy Display';
}

class JudgementDisplay extends Option 
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.judgementDisplay = !FlxG.save.data.judgementDisplay;

		acceptValues = FlxG.save.data.judgementDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Judgemnt Display';
}

class StrumLineBG extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		withoutCheckboxes = true;
	}

	public override function pressKey(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function pressLeftKey():Bool
	{
		// If the value is greater than 0, decrease it by 10%.
		if (FlxG.save.data.strumLineBG > 0)
		{
			FlxG.save.data.strumLineBG -= 10;

			// If the value is less than 0, return it.
			if (FlxG.save.data.strumLineBG < 0) FlxG.save.data.strumLineBG = 0;
			FlxG.save.data.strumLineBG = FlxMath.roundDecimal(FlxG.save.data.strumLineBG, 2);
		}

		FlxG.save.flush();
		display = updateDisplay();

		trace('[SETTINGS] Decrease strumline background to ${FlxG.save.data.strumLineBG}.');
		return true;
	}

	public override function pressRightKey():Bool
	{
		// If the value is greater than 0, decrease it by 10%.
		if (FlxG.save.data.strumLineBG < 100)
		{
			FlxG.save.data.strumLineBG += 10;
			FlxG.save.data.strumLineBG = FlxMath.roundDecimal(FlxG.save.data.strumLineBG, 2);
		}

		FlxG.save.flush();
		display = updateDisplay();

		trace('[SETTINGS] Increase strumline background to ${FlxG.save.data.strumLineBG}.');
		return true;
	}

	private override function updateDisplay():String
		return '<${FlxG.save.data.strumLineBG}> Strumline BG';
}

class HideHUD extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(changeData:Bool):Bool
	{
		if (changeData) FlxG.save.data.hideHUD = !FlxG.save.data.hideHUD;

		acceptValues = FlxG.save.data.hideHUD;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'Hide HUD';
}

class NoteSplashOP extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(changeData:Bool):Bool
	{
		if (changeData) FlxG.save.data.noteSplash  = !FlxG.save.data.noteSplash;

		acceptValues = FlxG.save.data.noteSplash;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'NoteSplashes';
}

class CPUStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function pressKey(changeData:Bool):Bool
	{
		if (changeData) FlxG.save.data.cpuStrums  = !FlxG.save.data.cpuStrums;

		acceptValues = FlxG.save.data.cpuStrums;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return 'CPU Strums';
}

class FDEWatermark extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.fdeWatermark = !FlxG.save.data.fdeWatermark;

		acceptValues = FlxG.save.data.fdeWatermark;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'FDE Watermark';
}

// * ---------------------------------------	* \\
// * GAMEPLAY SETTINGS                       * \\
// * --------------------------------------- * \\
class Naughtyness extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.naughtyness = !FlxG.save.data.naughtyness;

		acceptValues = FlxG.save.data.naughtyness;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Naughtyness';
}

class Downscroll extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.downscroll = !FlxG.save.data.downscroll;

		acceptValues = FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Downscroll';
}

class Middlescroll extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;

		acceptValues = FlxG.save.data.middlescroll;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Middlescroll';
}

class FlashingLights extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.flashingLights = !FlxG.save.data.flashingLights;

		acceptValues = FlxG.save.data.flashingLights;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Flashing Lights';
}

class CameraZooms extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.cameraZooms = !FlxG.save.data.cameraZooms;

		acceptValues = FlxG.save.data.cameraZooms;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Camera Zooms';
}

class AutoPause extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value)
	 	{
			FlxG.save.data.autoPause = !FlxG.save.data.autoPause;
			FlxG.autoPause = FlxG.save.data.autoPause;
	 	}

		acceptValues = FlxG.save.data.autoPause;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Pause on Unfocus';
}

class GhostTapping extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function pressKey(value:Bool):Bool
	{
		if (value) FlxG.save.data.ghostTapping = !FlxG.save.data.ghostTapping;	

		acceptValues = FlxG.save.data.ghostTapping;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return 'Ghost Tapping';
}

class ScrollSpeed extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		withoutCheckboxes = true;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function pressLeftKey():Bool
	{
		// If the value is greater than 0, decrease it by 10%.
		if (FlxG.save.data.scrollSpeed > 1) FlxG.save.data.scrollSpeed -= 0.1;
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();

		trace('[SETTINGS] Decrease scroll speed to ${FlxG.save.data.scrollSpeed}.');
		return true;

	}

	public override function pressRightKey():Bool
	{
		// If the value is less than 10, increase it by 10%.
		if (FlxG.save.data.scrollSpeed < 9.9) FlxG.save.data.scrollSpeed += 0.1;
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();

		trace('[SETTINGS] Increase scroll speed to ${FlxG.save.data.scrollSpeed}.');
		return true;
	}

	public override function updateDisplay():String
		return '<${FlxG.save.data.scrollSpeed}> Scroll Speed';
}

// * ---------------------------------------	* \\
// * SAVE DATA                       		* \\
// * --------------------------------------- * \\
class WeekUnlocked extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;

		if (OptionsMenuState.fromFreeplay) return false;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		// If you actually press `ENTER` then reset all settings.
		if (!value) 
		{
			confirm = false;
			display = updateDisplay();
			return true;
		}

		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		trace('[OPTIONS] Reset Story Progress. Weeks Unlocked ${FlxG.save.data.weekUnlocked}');

		acceptValues = FlxG.save.data.weekUnlocked;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return confirm ? "Confirm Story Reset" : "Reset Story Progress";
}

class ResetHighscore extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;

		if (OptionsMenuState.fromFreeplay) return false;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		// If you actually press `ENTER` then reset all settings.
		if (!value) 
		{
			confirm = false;
			display = updateDisplay();
			return true;
		}

		for (key in Highscore.songScores.keys()) Highscore.songScores[key] = 0;
		
		FlxG.save.data.songScores = null;
		FlxG.save.data.songCombos = null;
		trace('[OPTIONS] Reset all Highscores.');

		acceptValues = FlxG.save.data.resetHighscore;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return confirm ? "Confirm Score Reset" : "Reset Score";
}

class ResetALLSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function pressKey(value:Bool):Bool
	{
		withoutCheckboxes = true;

		if (OptionsMenuState.fromFreeplay) return false;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		// If you actually press `ENTER` then reset all settings.
		if (!value) 
		{
			confirm = false;
			display = updateDisplay();
			return true;
		}

		FlxG.save.data.lowQuality = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.shaders = null;
		FlxG.save.data.debugDisplay = null;
		FlxG.save.data.debugDisplayBGOpacity = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.launchInFullscreen = null;

		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.JudgementDisplay = null;
		FlxG.save.data.hideHUD = null;
		FlxG.save.data.strumLineBG = null;
		FlxG.save.data.noteSplash = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.fdeWatermark = null;

		FlxG.save.data.naughtyness = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.middlescroll = null;
		FlxG.save.data.flashingLights = null;
		FlxG.save.data.cameraZooms = null;
		FlxG.save.data.autoPause = null;
		FlxG.save.data.ghostTapping = null;
		FlxG.save.data.scrollSpeed = null;

		FlxG.save.data.resetHighscore = null;
		FlxG.save.data.resetSettings = null;

		DefinitiveData.initialize();
		trace('[OPTIONS] Reset all settings data.');

		acceptValues = FlxG.save.data.resetSettings;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
}