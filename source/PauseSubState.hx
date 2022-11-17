package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	public static var goToOptions:Bool = false;

	var pauseOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Modifiers', 'Exit to menu'];
	var modifiersChoices:Array<String> = ["Toggle Practice Mode", "Options Menu", "Back"];
	var difficultyChoices:Array<String> = ['Easy', 'Normal', 'Hard', 'Back'];

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	var practiceText:FlxText;
	var botplayText:FlxText;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeathCounter:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDeathCounter.text += "Blueballed: " + PlayState.deathCounter;
		levelDeathCounter.scrollFactor.set();
		levelDeathCounter.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeathCounter.updateHitbox();
		add(levelDeathCounter);

		practiceText = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeathCounter.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeathCounter.x = FlxG.width - (levelDeathCounter.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeathCounter, {alpha: 1, y: levelDeathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();

				case "Restart Song":
					FlxG.resetState();

				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();

				case "Modifiers":
					menuItems = modifiersChoices;
					regenMenu();	

				case "Toggle Practice Mode":
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;

				case "Options Menu":
					OptionsMenuState.fromFreeplay = true;
					FlxG.switchState(new OptionsMenuState());

				case "Exit to menu":
					PlayState.seenCutscene = false;
					PlayState.deathCounter = 0;
					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else
						FlxG.switchState(new FreeplayState());
				
				case "Easy" | "Normal" | "Hard":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected), PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();

				case "Back":
					menuItems = pauseOG;
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	private function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}
	
		for (i in 0...menuItems.length)
		{
			var menuItem:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			menuItem.isMenuItem = true;
			menuItem.targetY = i;
			grpMenuShit.add(menuItem);
		}
	
		curSelected = 0;
	
		changeSelection();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
