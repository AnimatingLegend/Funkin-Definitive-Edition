package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class OutdatedSubState extends MusicBeatState
{
	public static var needVer:String = "IDFK LOL";
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var ver = "v" + Application.current.meta.get('version');
		var warnText:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! looks like you're running an\n outdated version of Friday Night Funkin' (" + MainMenuState.definitiveVersion + "),\n
			please update to " + needVer + "!\n Press 'ESCAPE' to proceed anyway.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL("https://github.com/LegendLOL/Funkin-Definitive-Edition/releases");
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(FlxColor.WHITE, 4);
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		super.update(elapsed);
	}
}
