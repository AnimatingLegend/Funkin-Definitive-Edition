package funkin.menus;

import flixel.text.FlxText;
import funkin.backend.chart.Song;
import funkin.backend.utils.Highscore;

using StringTools;

/**
 * Data structure for representing a song in the freeplay menu.
 */
typedef FreeplaySongData =
{
	var songName:String;
	var week:Int;
	var songCharacter:String;
	@:optional var color:Null<Int>;
}

/**
 * FREEPLAY STATE CLASS
 * 
 * Handles the freeplay menu, where you can select any song you've unlocked,
 * preview and play it with your best score and accuracy.
 */
class FreeplayState extends MusicBeatState
{
	/**
	 * The list of songs available in freeplay, loaded from a JSON file.
	 */
	public static var songs:Array<SongMetadata> = [];

	/**
	 * The index of the last selected song, 
	 * used to remember the user's position in the menu when they return to it.
	 */
	public static var lastSelected:Int = 0;

	/**
	 * The difficulty level of the last selected song,
	 * used to remember the user's position in the menu when they return to it.
	 */
	public static var lastDifficulty:Int = 1;

	/**
	 * The index of the currently selected song in the freeplay menu.
	 */
	var currentlySelected:Int = 0;

	/**
	 * The difficulty level of the currently selected song.
	 */
	var currentDifficulty:Int = 1;

	/**
	 * Whether the game is in debug mode.
	 */
	var isDebug:Bool = false;

	//
	// UI Elements
	//
	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var selector:FlxText;

	var lerpScore:Float = 0;
	var lerpRating:Float = 0;
	var diffText:FlxText;
	var comboText:FlxText;
	var ratingText:FlxText;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var intendedCombo:String;

	private var iconArray:Array<HealthIcon> = [];
	private var songGrps:FlxTypedGroup<Alphabet>;
	private var weekColors = [
		0xE1790135, // TUTORIAL
		0xFF9271FD, // WEEK 1
		0xFF223344, // WEEK 2
		0xFF941653, // WEEK 3
		0xFFFC96D7, // WEEK 4
		0xFFA0D1FF, // WEEK 5
		0xFFFF78BF, // WEEK 6
		0xFFF6B604, // WEEK 7
	];

	override function create()
	{
		Paths.clearStoredMemory();
		songs = [];

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		loadSongsFromJSON();

		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.updateHitbox();
		add(bg);

		songGrps = new FlxTypedGroup<Alphabet>();
		add(songGrps);

		for (index in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * index) + 30, songs[index].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = index;

			// If the week is locked, gray out the text and disable it.
			if (!isSongUnlocked(index))
				songText.alpha = 0.3;
			songGrps.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[index].songCharacter);
			icon.sprTracker = songText;

			if (!isSongUnlocked(index))
				icon.alpha = 0.3;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 2, 0xFF000000);
		scoreBG.alpha = 0.5;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);
		add(scoreText);

		// Restore the user's position in the menu.
		currentlySelected = FreeplayState.lastSelected;
		currentDifficulty = FreeplayState.lastDifficulty;

		// Set the currently selected song to the first unlocked song.
		if (currentlySelected >= songs.length)
			currentlySelected = 0;

		changeSelection();
		changeDifficulty();

		selector = new FlxText();
		selector.size = 40;
		selector.text = ">";

		super.create();

		Paths.clearUnusedMemory();
	}

	/**
	 * Loads the list of songs for freeplay from a JSON file located at `assets/data/freeplaySonglist.json`.
	 */
	function loadSongsFromJSON():Void
	{
		#if debug
		addSong('test', 5, 'bf-pixel');
		#end

		var rawData:String = openfl.utils.Assets.getText(Paths.json('freeplaySonglist'));
		if (rawData == null || rawData.trim() == "")
		{
			trace('SONG METADATA: No song metadata found in freeplaySonglist.json. Please check your JSON file.');
			return;
		}

		var parsedData:Array<FreeplaySongData> = haxe.Json.parse(rawData);
		for (entry in parsedData)
		{
			songs.push(new SongMetadata(entry.songName, entry.week, entry.songCharacter));
		}
	}

	/**
	 * Returns whether a song is unlocked based on its index in the songs array.
	 * Week 0 (Tutorial), & week 1 is always unlocked, 
	 * 	and the rest depend on the player's progress (`FlxG.save.data.weekUnlocked`).
	 */
	function isSongUnlocked(songIndex:Int):Bool
	{
		// Unlock all songs in debug mode.
		if (isDebug)
			return true;
		var week = songs[songIndex].week;
		// Tutorial and week 1 should always be unlocked.
		if (week == 0 || week == 1)
			return true;
		// No weeks unlocked at all.
		if (!FlxG.save.data.weekUnlocked)
			return false;
		// Check if the specific week is unlocked.
		return FlxG.save.data.weekUnlocked >= week;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String):Void
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>):Void
	{
		if (songCharacters == null)
			songCharacters = ["bf"];

		var songCount:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[songCount]);
			if (songCharacters.length != 1)
				songCount++;
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		lerpRating = CoolUtil.coolLerp(lerpRating, intendedRating, 0.4);
		bg.color = FlxColor.interpolate(bg.color, weekColors[songs[currentlySelected].week % weekColors.length], CoolUtil.camLerpShit(0.045));

		updateScoreText();
		highscorePosition();

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		if (controls.UI_LEFT_P)
			changeDifficulty(-1);
		if (controls.UI_RIGHT_P)
			changeDifficulty(1);

		if (controls.BACK /*|| FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE*/)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			// Block selection of locked songs
			if (!isSongUnlocked(currentlySelected))
			{
				FlxG.sound.play(Paths.sound("cancelMenu"));
				return;
			}

			// Remember the last selected song for when we return to the menu.
			// + get the last selected difficulty for that song as well.
			FreeplayState.lastSelected = currentlySelected;
			FreeplayState.lastDifficulty = currentDifficulty;

			var selectedMetadata:String = Highscore.formatSong(songs[currentlySelected].songName.toLowerCase(), currentDifficulty);
			PlayState.SONG = Song.loadFromJson(selectedMetadata, songs[currentlySelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = currentDifficulty;
			PlayState.storyWeek = songs[currentlySelected].week;
			trace('FREEPLAY MENU: Starting song: ${songs[currentlySelected].songName}, Week: ${songs[currentlySelected].week}, Difficulty: ${CoolUtil.difficultyString()}');
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function updateScoreText()
	{
		var accuracyStr:String = lerpRating > 0 ? ' (' + (Math.round(lerpRating * 100) / 100) + '%)' : ' (0.00%)';
		scoreText.text = 'PERSONAL BEST: ' + Math.round(lerpScore) + accuracyStr;
	}

	function changeDifficulty(change:Int = 0)
	{
		currentDifficulty += change;

		if (currentDifficulty < 0)
			currentDifficulty = 2;
		if (currentDifficulty > 2)
			currentDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[currentlySelected].songName, currentDifficulty);
		intendedCombo = Highscore.getCombo(songs[currentlySelected].songName, currentDifficulty);
		intendedRating = Highscore.getRating(songs[currentlySelected].songName, currentDifficulty);
		#end

		PlayState.storyDifficulty = currentDifficulty;

		var comboStr:String = (intendedCombo != null && intendedCombo != '') ? intendedCombo : ' N/A';
		diffText.text = 'RANK: ' + comboStr + ' < ' + CoolUtil.difficultyString() + ' >';
		highscorePosition();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentlySelected += change;

		if (currentlySelected < 0)
			currentlySelected = songs.length - 1;
		if (currentlySelected >= songs.length)
			currentlySelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[currentlySelected].songName, currentDifficulty);
		intendedCombo = Highscore.getCombo(songs[currentlySelected].songName, currentDifficulty);
		intendedRating = Highscore.getRating(songs[currentlySelected].songName, currentDifficulty);
		#end

		var bullShit:Int = 0;
		for (i in 0...iconArray.length)
			iconArray[i].alpha = isSongUnlocked(i) ? 0.6 : 0.2;

		iconArray[currentlySelected].alpha = isSongUnlocked(currentlySelected) ? 1 : 0.3;

		for (item in songGrps.members)
		{
			item.targetY = bullShit - currentlySelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = isSongUnlocked(currentlySelected) ? 1 : 0.3;
		}

		changeDifficulty();
	}

	private function highscorePosition()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		scoreBG.scale.y = scoreText.height + diffText.height + 16;
		scoreBG.y = 0;

		diffText.y = scoreText.y + scoreText.height + 4;
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
