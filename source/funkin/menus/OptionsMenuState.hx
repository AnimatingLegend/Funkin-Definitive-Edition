package funkin.menus;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import funkin.backend.settings.Options;
import funkin.menus.ControlsSubState;
import funkin.menus.MainMenuState;
import funkin.menus.objects.settingsMenu.CheckboxThingie;

class OptionsMenuState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	public static var fromFreeplay:Bool = false;
	public static var fromControlsMenu:Bool = false;
	public static var returnedfromOptions:Bool = false;

	public var options:Array<OptionCategory> = [
		new OptionCategory("Controls", []),
		new OptionCategory("Graphics", [
			new LowQuality('When enabled, certain assets will be hidden for better performance.'),
			new Antialiasing('Disables anti-aliasing, increasing performance at the cost of sharper / smoother visuals.'),
			new Shaders('Certain visual effects will not be displayed. (CPU insensitive)'),
			new DebugDisplayOP('When enabled, FPS and other debug stats are displayed.'),
			new DebugDisplayBGOP('Adjust the debug display\'s background opacity.'),
			new FPSCap('The maximum framerate the game targets. (60 - 280)'),
			new LaunchInFullscreen('When enabled, the game will automatically launch in fullscreen.'),
		]),
		new OptionCategory("Visuals and UI", [
			new AccuracyDisplay('When disabled, the miss / accuracy display will be hidden.'),
			new JudgementDisplay('When disabled, the judgement / ratings display will be hidden.'),
			new StrumLineBG('Show a semi-transparent background behind the strumline.'),
			new HideHUD('When enabled, most in-game UI elements will be hidden.'),
			new NoteSplashOP('When disabled, hitting "sick!" notes won\'t display firework-like particles over the strumline.'),
			new HideCPUStrums('When enabled, the CPU\'s strumline will be completely hidden.'),
			new FDEWatermark('When disabled, any mention of "Funkin Definitive Edition" will be hidden.'),
		]),
		new OptionCategory("Gameplay", [
			new Naughtyness('When enabled, rauchy content (such as swearing, etc.) is displayed.'),
			new Downscroll('When enabled, notes move downwards towards the strumline at the bottom of the screen.'),
			new Middlescroll('When enabled, the strumline will move to the center of the screen.'),
			new FlashingLights('When disabled, flashing effects are dampened. Useful for people with epilepsy.'),
			new CameraZooms('When enabled, the camera bounces during songs.'),
			new AutoPause('When enabled, the game will automatically pause when the game loses focus.'),
			new GhostTapping('when enabled, you wont\'t get penalized for ghost misses.'),
			new HitsoundVolume('When adjusted, a "tick" sound will play when a note is hit.'),
			new ScrollSpeed('Adjust the songs scroll speed.'),
		]),
		new OptionCategory("Save Data", [
			new WeekUnlocked('If pressed, all story progress will be reset.\n(WARNING: THIS CANNOT BE UNDONE)'),
			new ResetHighscore('If pressed, all highscore data will be reset.\n(WARNING: THIS CANNOT BE UNDONE)'),
			new ResetALLSettings('If pressed, ALL settings data will be reset.\n(WARNING: YOUR GAME WILL RESTART. THIS CANNOT BE UNDONE)'),
		]),
	];

	private var currentDescription:String;
	private var grpControls:FlxTypedGroup<Alphabet>;
	private var checkBoxesArray:Array<CheckboxThingie> = [];
	private var descTxt:FlxText;

	var currentSelectedCat:OptionCategory;
	var checkbox:CheckboxThingie;
	var camFollow:FlxObject;
	var menuBG:FlxSprite;
	var textBG:FlxSprite;

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('settingsMenu'), 0.5, true);

		menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFc4618c;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.18;
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		add(camFollow);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (100 * i) + 105, options[i].getName(), true, false);
			controlLabel.screenCenter();
			controlLabel.y += (100 * (i - (options.length / 2))) + 50;
			grpControls.add(controlLabel);
		}

		var boxWidth:Int = FlxG.width - 20;
		var boxHeight:Int = 70;
		var boxX:Int = 10;
		var boxY:Int = FlxG.height - boxHeight - 10;

		textBG = new FlxSprite(boxX, boxY).makeGraphic(boxWidth, boxHeight, 0xFF000000);
		textBG.alpha = 0.75;

		descTxt = new FlxText(boxX, boxY + 8, boxWidth, currentDescription, 20);
		descTxt.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER);
		descTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		descTxt.scrollFactor.set();

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection(0);

		super.create();
	}

	var isCat:Bool = false;

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		descTxt.text = currentDescription;

		Conductor.offset = FlxG.save.data.notesOffset;
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if (!isCat)
		{
			grpControls.forEach(function(controlLabel:Alphabet)
			{
				controlLabel.screenCenter(X);
			});
		}
		else
		{
			grpControls.forEach(function(controlLabel:Alphabet)
			{
				controlLabel.x = 120;
			});
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE && !isCat)
		{
			if (FlxG.sound != null)
				FlxG.sound.play(Paths.sound("cancelMenu"), false);
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(0.5, 0);

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();

				if (fromFreeplay)
				{
					fromFreeplay = false;
					FlxG.switchState(new PlayState());
				}
				else
					FlxG.switchState(new MainMenuState());
			});
		}
		else if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			isCat = false;

			// Reset confirm state on all options when exiting category.
			for (i in 0...currentSelectedCat.getOptions().length)
				currentSelectedCat.getOptions()[i].pressKey(false);

			grpControls.clear();
			for (i in 0...checkBoxesArray.length)
			{
				remove(checkBoxesArray[i]);
				checkBoxesArray[i].destroy();
			}

			checkBoxesArray = [];

			for (i in 0...options.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (100 * i) + 105, options[i].getName(), true, false);
				controlLabel.screenCenter();
				controlLabel.y += (100 * (i - (options.length / 2))) + 50;
				grpControls.add(controlLabel);
			}

			FlxG.sound.play(Paths.sound("cancelMenu"), false);

			remove(textBG);
			remove(descTxt);

			add(selectorLeft);
			add(selectorRight);

			curSelected = 0;
			changeSelection(0);
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (controls.UI_RIGHT_P)
						currentSelectedCat.getOptions()[curSelected].pressRightKey();
					if (controls.UI_LEFT_P)
						currentSelectedCat.getOptions()[curSelected].pressLeftKey();
				}
				else
				{
					if (controls.UI_RIGHT_P)
						currentSelectedCat.getOptions()[curSelected].pressRightKey();
					if (controls.UI_LEFT_P)
						currentSelectedCat.getOptions()[curSelected].pressLeftKey();
				}
			}
		}

		if (controls.ACCEPT)
		{
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].pressKey(true))
				{
					trace('OPTIONS MENU: "${currentSelectedCat.getOptions()[curSelected].getDisplay()}" has been ${currentSelectedCat.getOptions()[curSelected].getAccept() ? "enabled" : "disabled"}.');
					grpControls.remove(grpControls.members[curSelected]);

					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(),
						currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
					grpControls.add(ctrl);
					ctrl.isMenuItem = true;
					checkBoxesArray[curSelected].sprTracker = grpControls.members[curSelected];
					checkBoxesArray[curSelected].set_daValue(currentSelectedCat.getOptions()[curSelected].getAccept());
				}
			}
			else
			{
				if (options[curSelected].getName() == "Controls")
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new ControlsSubState());
				}
				else
				{
					currentSelectedCat = options[curSelected];
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(),
							currentSelectedCat.getOptions()[i].boldDisplay, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
					}
					curSelected = 0;
					currentDescription = currentSelectedCat.getOptions()[0].getDescription();
					updateCheckboxes();

					isCat = true;

					add(textBG);
					add(descTxt);
					remove(selectorLeft);
					remove(selectorRight);
				}
			}
		}
		else if (controls.UI_LEFT_P && isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].pressLeftKey())
			{
				grpControls.remove(grpControls.members[curSelected]);
				var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(),
					currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
				grpControls.add(ctrl);
				ctrl.isMenuItem = true;
			}
		}
		else if (controls.UI_RIGHT_P && isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].pressRightKey())
			{
				grpControls.remove(grpControls.members[curSelected]);
				var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(),
					currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
				grpControls.add(ctrl);
				ctrl.isMenuItem = true;
			}
		}

		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function updateCheckboxes()
	{
		for (i in 0...checkBoxesArray.length)
		{
			checkBoxesArray[i].destroy();
			remove(checkBoxesArray[i]);
		}
		checkBoxesArray = [];
		for (i in 0...currentSelectedCat.getOptions().length)
		{
			currentSelectedCat.getOptions()[i].pressKey(false); // Reset checkboxes
			var controlLabel = grpControls.members[i]; // Then use updated display.
			checkbox = new CheckboxThingie(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getAccept());
			checkbox.sprTracker = grpControls.members[i];

			checkBoxesArray.push(checkbox);
			if (!currentSelectedCat.getOptions()[i].withoutCheckboxes)
				add(checkbox);
		}
	}

	function changeSelection(change:Int = 0)
	{
		if (fromControlsMenu)
		{
			fromControlsMenu = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		else
		{
			if (change != 0)
				FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;
		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();

		camFollow.screenCenter();

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
	}
}
