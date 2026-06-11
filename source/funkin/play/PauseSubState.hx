package funkin.play;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.input.Controls.Control;
import funkin.play.song.Song;
import funkin.play.PlayState;
import funkin.save.Highscore;

/**
 * PAUSE SUB-STATE CLASS (Substate for `PlayState.hx`)
 */
class PauseSubState extends MusicBeatSubstate
{
	/**
	 * The instance of the pause substate.
	 */
	public static var instance:PauseSubState = null;

	/**
	 * The default entries for the pause menu.
	 * 
	 * `Resume`: Continue the game.
	 * `Restart Song`: Restart the song.
	 * `Gameplay Modifiers`: Change the game's modifiers.
	 * `Options`: Open the options menu.
	 * `Exit to menu`: Return to the main menu.
	 */
	static final DEFAULT_ENTRIES:Array<String> = [
		            'Resume', 'Restart Song', 'Change Difficulty',
		'Gameplay Modifiers',      'Options',      'Exit to Menu'
	];

	/**
	 * The modifier entries for the pause menu.
	 * 
	 * `Practice Mode`: Toggle practice mode.
	 * `InstaKill on Miss`: Toggle instaKill mode.
	 * `Healthdrain`: Toggle healthdrain mode.
	 * `Botplay`: Toggle botplay mode.
	 * `Back`: Return to the previous menu.
	 */
	static final GAMEPLAY_MODIFIERS_ENTRIES:Array<String> = ['Practice Mode', 'InstaKill on Miss', 'Healthdrain', 'Botplay', 'Back'];

	/**
	 * The difficulty entries for the pause menu.
	 * 
	 * `Easy`: Easy difficulty.
	 * `Normal`: Normal difficulty.
	 * `Hard`: Hard difficulty.
	 * `Back`: Return to the previous menu.
	 */
	static final DIFFICULTY_ENTRIES:Array<String> = [
		'Easy', 'Normal', 'Hard', 'Back'
	];

	//
	// SONG PROPERTIES / VALUES
	//

	/**
	 * The time it takes for the pause music to fade in,
	 *  and the final volume of the music.
	 */
	static final MUSIC_FADE_IN_TIME:Float = 5;

	static final MUSIC_FINAL_VOLUME:Float = 0.75;

	/**
	 * Get the pause music.
	 */
	var pauseMusic:FlxSound;

	/**
	 * Get the stage, and the stage suffix to correctly load the
	 *  pause music for the specified stage.
	 * 
	 * Suffix:
	 * `-pixel`: pixel suffix for week 6.
	 * `default`: no suffix
	 */
	var stageSuffix:String;

	var currentStage:String = PlayState.curStage;

	//
	// UI ELEMENTS
	//
	var levelInfo:FlxText;
	var currentlySelected:Int = 0;
	var menuItems:Array<String> = [];
	var menuItemGroup:FlxTypedGroup<Alphabet>;

	//
	// BOOLEAN VALUES
	//

	/**
	 * Whether the game has lost focus.
	 */
	var lostFocus:Bool;

	/**
	 * Whether the game went to the options menu.
	 */
	var goToOptions:Bool;

	/**
	 * Whether the substate allows keyboard inputs.
	 * Dis-allow input until the transition into this substate is complete.
	 */
	var allowInputs:Bool = true;

	/**
	 * Whether the substate has just opened.
	 * If this is true, it means we are frame 1 of our substate.
	 */
	var justOpened:Bool = true;

	public function new(x:Float, y:Float)
	{
		super();

		instance = this;
		menuItems = DEFAULT_ENTRIES;

		startPauseMusic();

		if (lostFocus && FlxG.save.data.autoPause)
			pauseMusic.pause();

		buildElements();
		regenerateMenu();
	}

	//
	// UI ELEMENTS
	//

	function buildElements():Void
	{
		var background:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0.0;
		background.scrollFactor.set(0, 0);
		add(background);

		levelInfo = new FlxText(0, 20);
		levelInfo.alignment = FlxTextAlign.RIGHT;
		levelInfo.setFormat(Paths.font('vcr.ttf'), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		FlxTween.tween(background, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		menuItemGroup = new FlxTypedGroup<Alphabet>();
		add(menuItemGroup);

		for (item in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * item) + 30, menuItems[item], true, false);
			songText.isMenuItem = true;
			songText.targetY = item;
			menuItemGroup.add(songText);
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		updateSongText();
	}

	/**
	 * Update the song text, such as the song name,
	 *  difficulty, and blue ball (death) count.
	 */
	function updateSongText():Void
	{
		levelInfo.text = PlayState.SONG.song;
		levelInfo.text += '\n Difficulty: ${CoolUtil.difficultyString()}';
		levelInfo.text += '\n ${PlayState.deathCounter} Blue Ball';
		if (PlayState.deathCounter != 1)
			levelInfo.text += 's';

		var activeModifiers:Array<String> = [];
		if (PlayState.practiceMode)
			activeModifiers.push('PRACTICE MODE');
		if (PlayState.instaKill)
			activeModifiers.push('INSTAKILL MODE');
		if (PlayState.healthDrain)
			activeModifiers.push('HEALTH DRAIN');
		if (PlayState.botplay)
			activeModifiers.push('BOTPLAY');

		switch (activeModifiers.length)
		{
			case 0:
				// Just add nothing.
				// Putting `return` here would fuck up the levelInfo text.
			case 1:
				levelInfo.text += '\n${activeModifiers[0]} ACTIVE';
			default:
				levelInfo.text += '\nMODIFIERS: ${activeModifiers.join(',')}';
		}

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
	}

	/**
	 * Initialize, and play the pause music.
	 */
	function startPauseMusic():Void
	{
		stageSuffix = switch (currentStage)
		{
			case 'school' | 'schoolEvil': '-pixel';
			default: '';
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pauseMusic/breakfast' + stageSuffix, 'shared'), true);
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(MUSIC_FADE_IN_TIME, 0, MUSIC_FINAL_VOLUME);

		FlxG.sound.list.add(pauseMusic);
	}

	//
	// HELPER EVENTS
	//

	/**
	 * Called to destroy certain elements of this substate
	 *  to prevent memory leaks.
	 */
	public override function destroy():Void
	{
		super.destroy();

		instance = null;

		pauseMusic.destroy();
		pauseMusic.fadeTween.cancel();
	}

	/**
	 * Called when the game loses focus.
	 */
	public override function onFocusLost():Void
	{
		super.onFocusLost();
		if (FlxG.save.data.autoPause)
			pauseMusic.pause();
	}

	/**
	 * Called when the game regains focus.
	 */
	public override function onFocus():Void
	{
		super.onFocus();
		if (FlxG.save.data.autoPause)
			pauseMusic.resume();
	}

	/**
	 * Called to update the menu elements for every frame.
	 * @param elapsed The time since the last frame.
	 */
	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		handleInputs();
	}

	/**
	 * Basic input handling when navigating the menu.
	 */
	function handleInputs():Void
	{
		if (!allowInputs)
			return;

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (justOpened)
		{
			justOpened = false;
			return;
		}

		if (controls.ACCEPT)
			selectEntry();
	}

	//
	// ENTRY SELECTION HANDLING
	//

	/**
	 * Called when a menu item is selected.
	 */
	function selectEntry():Void
	{
		switch (menuItems[currentlySelected])
		{
			// DEFAULT ENTRIES
			case 'Resume':
				close();
			case 'Restart Song':
				PlayState.instance.restartSong();
				close();
			case 'Change Difficulty':
				switchMenu(DIFFICULTY_ENTRIES);
			case 'Easy' | 'Normal' | 'Hard':
				changeDifficulty();
			case 'Gameplay Modifiers':
				switchMenu(GAMEPLAY_MODIFIERS_ENTRIES);
			case 'Back':
				switchMenu(DEFAULT_ENTRIES);
			case 'Options':
				exitToOptions();
			case 'Exit to Menu':
				exitToMenu();

			// GAMEPLAY MODIFIERS ENTRIES
			case 'Practice Mode':
				PlayState.practiceMode = !PlayState.practiceMode;
				updateSongText();
			case 'InstaKill on Miss':
				PlayState.instaKill = !PlayState.instaKill;
				updateSongText();
			case 'Healthdrain':
				PlayState.healthDrain = !PlayState.healthDrain;
				updateSongText();
			case 'Botplay':
				PlayState.botplay = !PlayState.botplay;
				updateSongText();
		}
	}

	function changeDifficulty():Void
	{
		var songName:String = PlayState.SONG.song.toLowerCase();
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong(songName, currentlySelected), songName);
		PlayState.storyDifficulty = currentlySelected;
		PlayState.instance.restartSong();
		close();
	}

	function exitToMenu():Void
	{
		PlayState.seenCutscene = false;
		PlayState.deathCounter = 0;

		if (PlayState.isStoryMode)
		{
			FlxG.switchState(new funkin.ui.story.StoryMenuState());
		}
		else
		{
			FlxG.switchState(new funkin.ui.freeplay.FreeplayState());
		}
	}

	function exitToOptions():Void
	{
		funkin.ui.options.OptionsMenuState.fromFreeplay = true;
		FlxG.switchState(new funkin.ui.options.OptionsMenuState());
	}

	function switchMenu(entries:Array<String>):Void
	{
		menuItems = entries;
		regenerateMenu();
	}

	//
	// MENU HANDLING
	//

	/**
	 * Change the currently selected menu item.
	 * @param change The change in the currently selected menu item.
	 */
	function changeSelection(change:Int = 0):Void
	{
		currentlySelected = (currentlySelected + change + menuItems.length) % menuItems.length;

		var nextIndex:Int = 0;
		for (item in menuItemGroup.members)
		{
			item.targetY = nextIndex - currentlySelected;
			item.alpha = (item.targetY == 0) ? 1.0 : 0.6;
			nextIndex++;
		}

		updateSongText();
	}

	/**
	 * Regenerate the menu.
	 */
	function regenerateMenu():Void
	{
		while (menuItemGroup.members.length > 0)
			menuItemGroup.remove(menuItemGroup.members[0], true);

		for (item in 0...menuItems.length)
		{
			var menuItem:Alphabet = new Alphabet(0, (70 * item) + 30, menuItems[item], true, false);
			menuItem.isMenuItem = true;
			menuItem.targetY = item;
			menuItemGroup.add(menuItem);
		}

		currentlySelected = 0;
		changeSelection(0);
	}
}
