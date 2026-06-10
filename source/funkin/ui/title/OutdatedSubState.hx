package funkin.ui.title;

import flixel.text.FlxText;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var warnText:FlxText = new FlxText(0, 0, FlxG.width, "HEY YOU! looks like you're running an
			\n outdated version of FNF: Definitive Edition. ("
			+ Main.DEFINITIVE_VERSION
			+ "),
			\n please update to "
			+ Main.updateVersion
			+ "!
			\n Press 'ESCAPE' to proceed anyway.", 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.openURL("https://github.com/AnimatingLegend/Funkin-Definitive-Edition/releases");
		}

		if (/*FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE*/ controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new funkin.ui.mainmenu.MainMenuState());
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		Paths.clearUnusedMemory();
		super.update(elapsed);
	}
}
