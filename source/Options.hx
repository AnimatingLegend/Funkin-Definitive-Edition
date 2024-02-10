package;

import openfl.text.FontType;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

class OptionCatagory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Catagory";

	public final function getName()
	{
		return _name;
	}

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var display:String;
	private var description:String = "";
	private var acceptValues:Bool = false;

	public var withoutCheckboxes:Bool = false;
	public var boldDisplay:Bool = true;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	// Returns whether the label is to be updated.
	public function press(changeData:Bool):Bool
	{
		return false;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
		{
			FlxG.save.data.fps = !FlxG.save.data.fps;
			(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		}

		acceptValues = FlxG.save.data.fps;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter ";
	}
}

class FramerateOption extends Option
{
	public function new(desc:String)
	{
		withoutCheckboxes = true;
		boldDisplay = false;
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.drawFramerate > 60)
			FlxG.drawFramerate -= 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.framerateDraw = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.drawFramerate < 240)
			FlxG.drawFramerate += 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.framerateDraw = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap " + FlxG.drawFramerate;
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		acceptValues = FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Downscroll ";
	}
}

class MiddlescrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
		acceptValues = FlxG.save.data.middlescroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middlescroll ";
	}
}

class NotesplashOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.notesplash = !FlxG.save.data.notesplash;
		acceptValues = FlxG.save.data.notesplash;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Notesplashes ";
	}
}

class GhostTappingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.ghostTapping = !FlxG.save.data.ghostTapping;
		acceptValues = FlxG.save.data.ghostTapping;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ghost tapping ";
	}
}

class NaughtyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.explicitContent = !FlxG.save.data.explicitContent;
		acceptValues = FlxG.save.data.explicitContent;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Naughtyness";
	}
}

class CameraZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.camhudZoom = !FlxG.save.data.camhudZoom;
		acceptValues = FlxG.save.data.camhudZoom;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera zooming on beat";
	}
}

class RatingHudOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.ratingHUD = !FlxG.save.data.ratingHUD;
		acceptValues = FlxG.save.data.ratingHUD;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ratings to HUD";
	}
}

class OpponentLightStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.glowStrums = !FlxG.save.data.glowStrums;
		acceptValues = FlxG.save.data.glowStrums;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Light CPU Strums";
	}
}

class AntialiasingOption extends Option 
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		acceptValues = FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "AntiAliasing";
	}
}

class LowDataOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.lowData = !FlxG.save.data.lowData;
		acceptValues = FlxG.save.data.lowData;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Low Quality";
	}
}

class JudgemntOption extends Option 
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.judgementCounter = !FlxG.save.data.judgementCounter;
		acceptValues = FlxG.save.data.judgementCounter;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Judgemnt Counter ";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
		{
			FlxG.save.data.accuracy = !FlxG.save.data.accuracy;
		}
		acceptValues = FlxG.save.data.accuracy;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Accuracy Display";
	}
}

class FlashingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
		{
			FlxG.save.data.flashingLights = !FlxG.save.data.flashingLights;
		}
		acceptValues = FlxG.save.data.flashingLights;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Flashing Menu";
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		withoutCheckboxes = true;
		super();
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.save.data.scrollSpeed > 1)
			FlxG.save.data.scrollSpeed -= 0.1;
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.save.data.scrollSpeed < 9.9)
			FlxG.save.data.scrollSpeed += 0.1;
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed " + FlxG.save.data.scrollSpeed;
	}
}

class LaneTransOption extends Option
{
	public function new(desc:String)
	{
		withoutCheckboxes = true;
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.save.data.laneUnderlay > 0.0)
		{
			FlxG.save.data.laneUnderlay -= 0.1;
			if(FlxG.save.data.laneUnderlay < 0.0)
			{
				FlxG.save.data.laneUnderlay = 0.0;
			}
			FlxG.save.data.laneUnderlay = FlxMath.roundDecimal(FlxG.save.data.laneUnderlay, 2);
		}
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.save.data.laneUnderlay < 1)
			FlxG.save.data.laneUnderlay += 0.1;
		FlxG.save.data.laneUnderlay = FlxMath.roundDecimal(FlxG.save.data.laneUnderlay, 2);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Lane underlay " + FlxG.save.data.laneUnderlay;
	}
}

class ShaderOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.shaders = !FlxG.save.data.shaders;
		acceptValues = FlxG.save.data.shaders;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Shaders";
	}
}

class PracticeOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.practiceMode = !FlxG.save.data.practiceMode;
		acceptValues = FlxG.save.data.practiceMode;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Toggle Practice Mode";
	}
}

class InstaKillOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.instaKill = !FlxG.save.data.instaKill;
		acceptValues = FlxG.save.data.instaKill;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "InstaKill on Miss";
	}
}

class BotPlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press(changeData:Bool):Bool
	{
		if (changeData)
			FlxG.save.data.botplay = !FlxG.save.data.botplay;
		acceptValues = FlxG.save.data.botplay;
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
	{
		return "Botplay";
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		if (changeData)
			FlxG.save.data.weekUnlocked = !FlxG.save.data.weekUnlocked;

		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		trace('Weeks Locked');

		acceptValues = FlxG.save.data.weekUnlocked;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Story Reset" : "Reset Story Progress";
	}
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

	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		if (changeData)
			FlxG.save.data.resetHighscore = !FlxG.save.data.resetHighscore;

		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}

		FlxG.save.data.songCombos = null;
		trace('Highscores Wiped');

		acceptValues = FlxG.save.data.resetHighscore;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Score Reset" : "Reset Score";
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		withoutCheckboxes = true;
		description = desc;
	}

	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;

		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		if (changeData)
			FlxG.save.data.resetSettings = !FlxG.save.data.resetSettings;

		FlxG.save.data.judgementCounter = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.middlescroll = null;
		FlxG.save.data.fullscreen = null;
		FlxG.save.data.laneUnderlay = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.framerateDraw = null;
		FlxG.save.data.ghostTapping = null;
		FlxG.save.data.flashingLights = null;
		FlxG.save.data.explicitContent = null;
		FlxG.save.data.glowStrums = null;
		FlxG.save.data.accuracy = null;
		FlxG.save.data.ratingHUD = null;
		FlxG.save.data.notesplash = null;
		FlxG.save.data.camhudZoom = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.lowData = null;
		FlxG.save.data.timerOption = null;
	//	FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.shaders = null;
		FlxG.save.data.practiceMode = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.instaKill = null;

		DefinitiveData.settings();
		trace('All settings have been reset');

		acceptValues = FlxG.save.data.resetSettings;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}
