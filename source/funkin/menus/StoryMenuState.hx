package funkin.menus;

import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import funkin.menus.objects.storyMenu.StoryMenuItem;
import funkin.menus.objects.storyMenu.MenuCharacter;

using StringTools;

/**
 * Data structure for a single week, 
 * 	loaded from `assets/data/weeks/<name>.json`.
 */
typedef WeekData = {
	var name:String;
	var displayName:String;
	var songs:Array<String>;
	var characters:Array<String>;
	var backgroundColor:Null<String>;
}

class StoryMenuState extends MusicBeatState
{
	/**
	 * Get the entire instance for the story menu.
	 */
	public static var instance:StoryMenuState = null;

	/**
	 * Parallel arrays to loaded weeks.
	 * @default true - if that week is accessible.
	 */
	public static var weekUnlocked:Array<Bool> = [];

	//
	// WEEK DATA (Loaded from JSON)
	//

	/**
	 * Ordered list of week file names.
	 */
	private static final WEEK_FILES:Array<String> = [
		'tutorial',
		'week1', 'week2', 'week3',
		'week4', 'week5', 'week6',
		'week7'
	];

	/**
	 * All week definitions, loaded from `assets/data/weeks/<name>.json`.
	 */
	private var weekDatas:Array<WeekData> = [];

	//
	// UI ELEMENTS
	//

	var scoreText:FlxText;
	var weekTitleText:FlxText;
	var trackListText:FlxText;

	var weekTextGroup:FlxTypedGroup<MenuItem>;
	var weekCharacterGroup:FlxTypedGroup<MenuCharacter>;
	var lockGroup:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var difficultySprites:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	//
	// MENU STATE
	//

	var currentWeek:Int = 0;
	var currentDifficulty:Int = 1;
	var difficultyMap:Array<String> = [];

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	
	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopSpamming:Bool = false;

	var tweenDifficulty:FlxTween;

	override function create() 
	{
		instance = this;

		loadWeekData();
		weekUnlocked = buildUnlockedArray();
		trace('STORY MENU: Loaded ${weekDatas.length} weeks.');

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu/freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, 'LEVEL SCORE: 0');
		scoreText.setFormat('VCR OSD Mono', 32);

		weekTitleText = new FlxText(FlxG.width * 0.7, 10, 0, '', 32);
		weekTitleText.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, RIGHT);
		weekTitleText.alpha = 0.8;

		var ui_tex = Paths.getSparrowAtlas('storymenu/ui/campaign_menu_UI_assets');
		var ui_yellowBG:FlxSprite = new FlxSprite(0, 56,).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		weekTextGroup = new FlxTypedGroup<MenuItem>();
		add(weekTextGroup);

		lockGroup = new FlxTypedGroup<FlxSprite>();
		add(lockGroup);

		var blackBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBar);

		weekCharacterGroup = new FlxTypedGroup<MenuCharacter>();

		for (index in 0...weekDatas.length)
		{
			var weekThing:MenuItem = new MenuItem(0, ui_yellowBG.y + ui_yellowBG.height + 10, index);
			weekThing.y += (weekThing.height + 20) * index;
			weekThing.targetY = index;
			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			weekTextGroup.add(weekThing);

			if (!weekUnlocked[index])
			{
				var lockSpr:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lockSpr.frames = ui_tex;
				lockSpr.animation.addByPrefix('lock', 'lock', 0, false);
				lockSpr.animation.play('lock');
				lockSpr.ID = index;
				lockSpr.antialiasing = FlxG.save.data.antialiasing;
				lockGroup.add(lockSpr);
			}
		}

		// Opponent (left)
		weekCharacterGroup.add(new MenuCharacter(0, 100, 0.5, false));
		// Boyfriend (center)
		weekCharacterGroup.add(new MenuCharacter(450, 25, 0.9, true));
		// Girlfriend (right)
		weekCharacterGroup.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(weekTextGroup.members[0].x + weekTextGroup.members[0].width + 10, weekTextGroup.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', 'arrow left', false);
		leftArrow.animation.addByPrefix('press', 'arrow push left', 24, false);
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		difficultySprites = new FlxSprite(0, leftArrow.y);
		difficultySprites.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(difficultySprites);

		rightArrow = new FlxSprite(leftArrow.x + difficultySprites.width + 68, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right', false);
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		add(ui_yellowBG);
		add(weekCharacterGroup);

		trackListText = new FlxText(FlxG.width * 0.05, ui_yellowBG.y + ui_yellowBG.height + 100, 0, 'Tracks', 32);
		trackListText.alignment = CENTER;
		trackListText.setFormat(Paths.font("vcr.ttf"), 32);
		trackListText.color = 0xFFe55777;
		add(trackListText);
		add(scoreText);
		add(weekTitleText);

		loadDifficulties();
		changeDifficulty();
		updateWeekDisplay();
		refreshWeek();

		super.create();

		Paths.clearUnusedMemory();
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));
		scoreText.text = 'LEVEL SCORE: ' + lerpScore;

		weekTitleText.text = weekDatas[currentWeek].displayName.toUpperCase();
		weekTitleText.x = FlxG.width - weekTitleText.width - 10;

		difficultySelectors.visible = weekUnlocked[currentWeek];

		lockGroup.forEach(function(lock:FlxSprite) lock.y = weekTextGroup.members[lock.ID].y);

		if (movedBack || selectedWeek) return;
		
		if (controls.UI_UP_P) changeWeek(-1);
		if (controls.UI_DOWN_P) changeWeek(1);

		if (controls.UI_RIGHT) rightArrow.animation.play('press');
		else rightArrow.animation.play('idle');
		if (controls.UI_LEFT) leftArrow.animation.play('press');
		else leftArrow.animation.play('idle');

		if (controls.UI_RIGHT_P) changeDifficulty(1);
		if (controls.UI_LEFT_P) changeDifficulty(-1);

		var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;
		if (FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
			changeWeek(-shiftMult * FlxG.mouse.wheel);
		}

		if (controls.ACCEPT) selectWeek();
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}
	}

	//
	// WEEK JSON LOADING
	//

	/**
	 * Loads all week data from `assets/data/weeks/<name>.json`.
	 * Files are loaded in the order defined in `WEEK_FILES`.
	 */
	function loadWeekData():Void
	{
		weekDatas = [];

		for (fileName in WEEK_FILES)
		{
			var path:String = Paths.json('weeks/' + fileName);
			var raw:String = openfl.utils.Assets.getText(path);

			if (raw == null || raw.trim() == '')
			{
				trace('STORY MENU: Missing / Empty week file: $path - Skipping.');
				continue;
			}

			try
			{
				var data:WeekData = haxe.Json.parse(raw);
				weekDatas.push(data);
			}
			catch (err)
			{
				trace('STORY MENU: Failed to parse $path: $err');
			}

			if (weekDatas.length == 0)
			{
				trace('STORY MENU (WARNING): No vaild week data loaded! Check "assets/data/weeks/" for issues.');
			}
		}
	}

	//
	// UNLOCKED WEEKS LOGIC
	//

	/**
	 * Builds the `weekUnlocked` array, which determines which weeks are accessible.
	 * Week 0 (Tutorial) should always be unlocked.
	 * Each subsequent week is unlocked if `FlxG.save.data.weekUnlocked` count covers it.
	 */
	function buildUnlockedArray():Array<Bool>
	{
		var result:Array<Bool> = [];

		#if debug
		// In debug mode, all weeks are unlocked.
		for (index in 0...weekDatas.length) result.push(true);
		return result;
		#end

		var unlockedCount:Int = (FlxG.save.data.weekUnlocked != null)
			? Std.int(FlxG.save.data.weekUnlocked)
			: 0;

		for (index in 0...weekDatas.length - 1) 
		{
			// Week 0 (Tutorial) is always unlocked. Rest depend on unlocked count.
			result.push(index == 0 || index <= unlockedCount);
		}

		return result;
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if (PlayState.botplay) 
		{
			trace('STORY MENU: Botplay detected! Skipping week unlock.');
			return;
		}

		// Week is the week just beaten (0-indexed.
    // Store how many non-tutorial weeks have been beaten.
		var currentlyUnlocked:Int = (FlxG.save.data.weekUnlocked != null)
			? Std.int(FlxG.save.data.weekUnlocked)
			: 0;

		if (week >= currentlyUnlocked)
		{
			FlxG.save.data.weekUnlocked = week + 1;
			FlxG.save.flush();

			trace('STORY MENU: Week $week beaten - Week ${week + 1} unlocked!');
		}
	}

	//
	// DIFFICULTY SELECTION
	//

	/**
	 * Loads the difficulty names for the current week from
	 * `assets/data/weeksDifficulties.text`.
	 * Falls back to `easy/normal/hard` if parsing fails.
	 */
	function loadDifficulties():Void
	{
		difficultyMap = [];

		try
		{
			var difficultyList:Array<String> = CoolUtil.coolTextFile(Paths.txt("weeksDifficulties"));
			if (currentWeek < difficultyList.length)
			{
				var splitDifficulties:Array<String> = difficultyList[currentWeek].split(':');
				difficultyMap = splitDifficulties.map(diffName -> {
					diffName = diffName.trim().toLowerCase();
					if (diffName == 'easy' || diffName == 'normal' || diffName == 'hard') return diffName;
					return null;
					
				}).filter(diffName -> diffName != null);
			}
		}
		catch (err)
		{
			FlxG.log.warn('STORY MENU: Failed to load weekDifficulties.txt: $err - Falling back to default difficulties.');
		}

		if (difficultyMap.length == 0) difficultyMap = ['easy', 'normal', 'hard'];
		// Clamp difficulty to valid range after reload.
		if (currentDifficulty >= difficultyMap.length) currentDifficulty = difficultyMap.length - 1;
	}

	function changeDifficulty(change:Int = 0):Void
	{
		currentDifficulty += change;

		if (currentDifficulty < 0)
			currentDifficulty = difficultyMap.length - 1;
		if (currentDifficulty >= difficultyMap.length)
			currentDifficulty = 0;

		var newDifficultyImage:FlxGraphic = Paths.loadImage('storymenu/difficulties/${difficultyMap[currentDifficulty]}');
		if (difficultySprites.graphic != newDifficultyImage)
		{
			difficultySprites.loadGraphic(newDifficultyImage);
		}

		// Center difficulty sprite between the two arrows.
		difficultySprites.x = leftArrow.x + leftArrow.width + 10;
    difficultySprites.y = leftArrow.y + (leftArrow.height - difficultySprites.height) / 2;

		// Pin right arrow flush after difficulty sprite
    rightArrow.x = difficultySprites.x + difficultySprites.width + 10;
    rightArrow.y = leftArrow.y;

		difficultySprites.alpha = 0;

		if (tweenDifficulty != null) tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(difficultySprites, {y: leftArrow.y + 15, alpha: 1}, 0.07, 
		{
			onComplete: function(_) tweenDifficulty = null
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(currentWeek, currentDifficulty);
		#end
	}

	//
	// WEEK NAVIGATION
	//

	/**
	 * Whenever the week is changed, 
	 * 	this function should be called to update all relevant UI and state.
	 * @param change - The amount to change the week by.
	 */
	function changeWeek(change:Int = 0):Void
	{
		currentWeek += change;

		if (currentWeek >= weekDatas.length) currentWeek = 0;
		if (currentWeek < 0) currentWeek = weekDatas.length - 1;

		updateWeekDisplay();
		refreshWeek();

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	/**
	 * Refreshes the week display text and colors based on the current week and unlocked weeks.
	 */
	function refreshWeek():Void
	{
		var index:Int = 0;
		for (item in weekTextGroup.members)
		{
			item.targetY = index - currentWeek;
			item.alpha = (item.targetY == 0 && weekUnlocked[index]) ? 1 : 0.5;
			index++;
		}
	}

	function selectWeek():Void
	{
		// If the week isn't unlocked, cancel the selection.
		if (!weekUnlocked[currentWeek])
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		if (!stopSpamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			weekTextGroup.members[currentWeek].startFlashing();
			weekCharacterGroup.members[1].animation.play('bfConfirm');
			stopSpamming = true;
		}

		selectedWeek = true;

		var difficultySuffix:String = switch(currentDifficulty)
		{
			case 0: '-easy';
			case 2: '-hard';
			default: '';
		}

		var playlist:Array<String> = weekDatas[currentWeek].songs;
		PlayState.storyPlaylist = playlist;
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = currentDifficulty;
		PlayState.storyWeek = currentWeek;
		PlayState.campaignScore = 0;
		PlayState.SONG = Song.loadFromJson(playlist[0].toLowerCase() + difficultySuffix, playlist[0].toLowerCase());

		new FlxTimer().start(1, function(_)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}

	function updateWeekDisplay():Void
	{
		var data:WeekData = weekDatas[currentWeek];
		var characters:Array<String> = data.characters;

		weekCharacterGroup.members[0].setCharacter(characters.length > 0 ? characters[0] : '');
		weekCharacterGroup.members[1].setCharacter(characters.length > 1 ? characters[1] : 'bf');
		weekCharacterGroup.members[2].setCharacter(characters.length > 2 ? characters[2] : 'gf');

		trackListText.text = "Tracks\n";
		for (song in data.songs) 
		{
			trackListText.text += "\n" + song;
		}
		trackListText.text += "\n";
		trackListText.screenCenter(X);
		trackListText.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(currentWeek, currentDifficulty);
		#end
	}
}
