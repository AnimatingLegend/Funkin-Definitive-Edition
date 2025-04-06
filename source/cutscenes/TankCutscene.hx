package cutscenes;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxG;

using StringTools;

class TankCutscene extends FlxSprite
{
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []];
	public var swagBacks:Map<String, Dynamic> = [];

	public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}