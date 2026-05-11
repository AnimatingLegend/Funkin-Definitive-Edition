package funkin.gameplay;

import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

import lime.utils.Assets;

import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

import funkin.backend.chart.Conductor;
import funkin.backend.chart.Song.SwagSong;
import funkin.backend.chart.Song;
import funkin.backend.chart.Section.SwagSection;
import funkin.backend.utils.Highscore;

import funkin.menus.FreeplayState;
import funkin.menus.StoryMenuState;
import funkin.menus.LoadingState;

import funkin.editors.ChartingState;
import funkin.editors.AnimationDebug;

import funkin.gameplay.GitarooPause;
import funkin.gameplay.PauseSubState;
import funkin.gameplay.objects.note.Note;
import funkin.gameplay.objects.note.NoteSplash;
import funkin.gameplay.objects.note.NoteSplash.NoteSplashPixel;
import funkin.gameplay.objects.Character;
import funkin.gameplay.shaders.BuildingShaders;
import funkin.gameplay.shaders.WiggleEffect;

import haxe.Json;
import haxe.macro.Expr.Case;

using StringTools;

/**
 * PLAYSTATE CLASS
 * 
 * This is where all the gameplay logic is stored, and handled.
 * [!NOTE] This class is a work in progress. Please expect some bugs if you run into any.
 */
class PlayState extends MusicBeatState 
{
	/** 
	 * The entire game's instance.
	 */
	public static var instance:PlayState = null;

	/** 
	 * Whether the game is currently in Story Mode. 
	 */
	public static var isStoryMode:Bool = false;

	/** 
	 * The current story week index. 
	 */
	public static var storyWeek:Int = 0;

	/** 
	 * The ordered list of songs remaining in the story playlist. 
	 */
	public static var storyPlaylist:Array<String> = [];

	/** 
	 * Story difficulty: 0 = easy, 1 = normal, 2 = hard. 
	 */
	public static var storyDifficulty:Int = 1;

	/** 
	 * How many times the player has died this session. 
	 */
	public static var deathCounter:Int = 0;

	/** 
	 * Whether the intro cutscene has already played this session. 
	 */
	public static var seenCutscene:Bool = false;

	/** 
	 * The full-combo rank string (e.g. "FC", "GFC", "MFC"). 
	 */
	public static var ratingFC:String;

	/** 
	 * The internal name of the current stage. 
	 */
	public static var curStage:String = '';

	/** 
	 * The loaded song data for the current track. 
	 */
	public static var SONG:SwagSong;

	//
	//  Gameplay modifiers 
	//

	/** 
	 * If true, misses deal no health damage and the song cannot be failed.
	 * @default false
	 */
	public static var practiceMode:Bool = false;

	/** 
	 * If true, any miss instantly kills the player.
	 * @default false
	 */
	public static var instaKill:Bool = false;

	/** 
	 * If true, health slowly drains over time.
	 * @default false 
	 */
	public static var healthDrain:Bool = false;

	/** 
	 * If true, the CPU plays for the player automatically. 
	 */
	public static var botplay:Bool = false;

	//
	// Story campaign totals 
	//

	/** 
	 * Accumulated score across all songs played in the current story run. 
	 */
	public static var campaignScore:Int = 0;

	/** 
	 * Accumulated misses across all songs played in the current story run. 
	 */
	public static var campaignMisses:Int = 0;

	//
	// Cameras
	//

	/** 
	 * The main game-world camera. 
	 */
	public var camGame:FlxCamera;

	/** 
	 * The HUD overlay camera (UI elements). 
	 */
	public var camHUD:FlxCamera;

	/** 
	 * Cutscene-exclusive camera layer. 
	 */
	public var camCutscene:FlxCamera;

	/** 
	 * Whether the camera should zoom-in on beats. 
	 */
	public static var camZooming:Bool = false;

	/** 
	 * The world position the camera is currently targeting. 
	 */
	public static var camPos:FlxPoint;

	//
	// Strumlines
	//

	/** 
	 * All strum arrows (both players combined). 
	 */
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;

	/** 
	 * Player 1 (BF) strum arrows. 
	 */
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;

	/** 
	 * Player 2 (Opponent) strum arrows. 
	 */
	public static var opponentStrums:FlxTypedGroup<FlxSprite> = null;

	//
	// Characters
	//

	/** 
	 * The opponent character. 
	 */
	public static var dad:Character;

	/** 
	 * The girlfriend/background character. 
	 */
	public static var gf:Character;

	/** 
	 * The player character (Boyfriend). 
	 */
	public static var boyfriend:Boyfriend;

	//
	// Rating counters
	// 

	/**
	 * Number of `SICK` judgements a user gets in a song. 
	 */
	public static var sicks:Int = 0;

	/** 
	 * Number of `GOOD` judgements a user gets in a song. 
	 */
	public static var goods:Int = 0;

	/** 
	 * Number of `BAD` judgements a user gets in a song. 
	 */
	public static var bads:Int = 0;

	/** 
	 * Number of `SHIT` judgements a user gets in a song. 
	 */
	public static var shits:Int = 0;

	/** 
	 * Total misses a user gets in a song. 
	 */
	public static var misses:Int = 0;

	/** 
	 * The highest combo reached in a song. 
	 */
	public static var highestCombo:Int = 0;

	/**
	 * Total combo breaks a player gets in a song.
	 */
	public static var comboBreaks:Int = 0;

	/** 
	 * The current accuracy percentage (0–100). 
	 */
	public static var accuracy:Float = 0.00;

	//
	// Pixel art scale 
	//

	/** 
	 * Upscale multiplier applied to pixel-art (Week 6) assets. 
	 */
	public static var daPixelZoom:Float = 6;

	/** 
	 * Whether a cutscene is currently active (disables input). 
	 */
	public static var inCutscene:Bool = false;

	//
	// INSTANCE FIELDS
	// NOTE / NOTE SPLASH GROUPS
	//

	/** 
	 * Unused noteData slot index — kept for API parity. 
	 */
	public var noteData:Int = 0;

	/** 
	 * Pool of default note-splash particles. 
	 */
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	/** 
	 * Pool of pixel-art note-splash particles (Week 6). 
	 */
	public var grpNoteSplashPixel:FlxTypedGroup<NoteSplashPixel>;

	/** 
	 * Active notes currently on screen. 
	 */
	private var notes:FlxTypedGroup<Note>;

	/** Notes that haven't scrolled on-screen yet. */
	private var unspawnNotes:Array<Note> = [];

	//
	// Lane underlay sprites
	//

	/** 
	 * Semi-transparent black bar behind the player's lane. 
	 */
	public var laneunderlay:FlxSprite;

	/** 
	 * Semi-transparent black bar behind the opponent's lane. 
	 */
	public var laneunderlayOpponent:FlxSprite;

	//
	// Audio
	//

	/** 
	 * The vocal track for the current song. 
	 */
	private var vocals:FlxSound;

	//
	// Strum / scroll
	//

	/** 
	 * Invisible guide line that determines the "hit" Y position. 
	 */
	private var strumLine:FlxSprite;

	/** 
	 * Current note-scroll speed (may be overridden by users save data). 
	 */
	public var scrollSpeed:Float = 1.0;

	/** 
	 * Distance (px) past the strum line before a note is destroyed. 
	 */
	public var noteKillOffset:Float = 350;

	//
	// Health bar
	//

	/** 
	 * Smoothed health value used by the health bar (lerped toward `health`). 
	 */
	public var healthLerp:Float = 1;

	/** 
	 * Background graphic for the health bar. 
	 */
	public var healthBarBG:FlxSprite;

	/** 
	 * The actual health bar widget. 
	 */
	public var healthBar:FlxBar;

	/** 
	 * Player 1 health icon. 
	 */
	public var iconP1:HealthIcon;

	/** 
	 * Player 2 health icon. 
	 */
	public var iconP2:HealthIcon;

	//
	// Score / HUD text
	//

	/** 
	 * Current song score (this attempt only). 
	 */
	var songScore:Int = 0;

	/**
	 * Smoothed score value used by the score text (lerped toward `songScore`).
	 */
	var songScoreLerp:Float = 0;

	/** 
	 * Text element showing score / accuracy. 
	 */
	var scoreTxt:FlxText;

	/** 
	 * Text showing per-judgement breakdown (sicks/goods/bads/shits/misses). 
	 */
	var judgementCounter:FlxText;

	/**
	 *  Debug/display label for the song name. 
	 */
	var songName:FlxText;

	/**
	 *  Watermark text element. 
	 */
	var watermark:FlxText;

	//
	// Song state flags
	//

	/** 
	 * True while the countdown is ticking before the song starts. 
	 */
	private var startingSong:Bool = false;

	/** 
	 * True once the song audio has started playing. 
	 */
	public var songStarted:Bool = false;

	/** 
	 * True once the song has ended and we're transitioning out. 
	 */
	public var endingSong:Bool = false;

	/** 
	 * True once note data has been fully generated. 
	 */
	private var generatedMusic:Bool = false;

	/** 
	 * True once the countdown has started. 
	 */
	var startedCountdown:Bool = false;

	/** 
	 * Whether the player can press pause right now.
	 */
	var canPause:Bool = true;

	/**
	 * Whether the game is currently paused.
	 */
	private var paused:Bool = false;

	/**
	 * Whether the game has been restarted.
	 */
	var hasRestarted:Bool = false;

	/** 
	 * True if the camera is currently looking at BF's side. 
	 */
	var cameraRightSide:Bool = false;

	//
	// Accuracy internals
	//

	/** 
	 * Default accuracy score (weighted differently from main accuracy). 
	 */
	private var accuracyDefault:Float = 0.00;

	/** 
	 * Weighted hit total used for accuracy calculation. 
	 */
	private var totalRatingsHit:Float = 0;

	/** 
	 * Unweighted hit total (default accuracy denominator). 
	 */
	private var totalRatingsHitDefault:Float = 0;

	/** 
	 * Total number of accuracy-affecting events. 
	 */
	private var totalRatings:Int = 0;

	/** 
	 * Total notes played (attempted). 
	 */
	private var totalPlayed:Int = 0;

	/** 
	 * Set to true when accuracy was recalculated this frame. 
	 */
	public var updatedAcc:Bool = false;

	//
	// Song Timing Internals
	//

	/** 
	 * Timestamp (ticks) of the previous rendered frame. 
	 */
	var previousFrameTime:Int = 0;

	/** 
	 * Last synced playhead position (ms). 
	 */
	var lastReportedPlayheadPosition:Int = 0;

	/** 
	 * Running song time used for interpolation. 
	 */
	var songTime:Float = 0;

	//
	// Misc Values
	//

	/** 
	 * The current song name string (mirrors `SONG.song`). 
	 */
	private var curSong:String = "";

	/** 
	 * Section index counter used to track which section is active. 
	 */
	private var curSection:Int = 0;

	/** 
	 * How many steps GF waits between dances (e.g. 1 = every beat). 
	 */
	private var gfSpeed:Int = 1;

	/** 
	 * Player health value. Clamped to [0, 2] where 1 = center. 
	 */
	private var health:Float = 1;

	/** 
	 * Current combo count. 
	 */
	private var combo:Int = 0;

	/** 
	 * Whether dialogue is currently showing. 
	 */
	var talking:Bool = true;

	/** 
	 * Default camera zoom for this stage. 
	 */
	var defaultCamZoom:Float = 1.05;

	/** 
	 * The invisible object the camera follows. 
	 */
	var camFollow:FlxObject;

	/** 
	 * Persisted camera follow from the previous song (story mode). 
	 */
	private static var prevCamFollow:FlxObject;

	/** 
	 * GF dialogue lines loaded from text file. 
	 */
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	/** 
	 * Timer that drives the countdown sequence. 
	 */
	var startTimer:FlxTimer;

	/** 
	 * Whether perfect-mode is active (debug only). 
	 */
	var perfectMode:Bool = false;

	/** 
	 * Whether the Tank Week 7 intro has finished. 
	 */
	public var tankIntroEnd:Bool = false;

	/** 
	 * Spare FlxSprite slot used for debugging. 
	 */
	public var bar:FlxSprite;

	//
	// Stage Specific Fields
	// NOTE: This is subject to change!
	//

	// Week 2 - Spooky Mansion
	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	// Week 3 - Philly
	var phillyLightsColors:Array<FlxColor>;
	var lightFadeShader:BuildingShaders;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var trainSound:FlxSound;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;
	var curLight:Int = 0;

	// Week 4 - Limo
	var limo:BGSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var fastCarCanDrive:Bool = true;

	// Week 5 - Mall
	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;

	// Week 6 - School
	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	// Week 7 - Tank
	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var foregroundSprites:FlxTypedGroup<BGSprite>;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	// Week 2 lightning
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override public function create() 
	{
		instance = this;
		FlxG.mouse.visible = false;
		
		// Initial cleanup
		Paths.clearStoredMemory();
		Note.clearPool();

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		// Camera Setup
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		// Asset cache:
		// If the song changed since last time, flush the cache.
		if (curSong != SONG.song)
		{
			curSong = SONG.song;
			Main.dumpCache();
			Paths.clearStoredMemory();
		}

		// Restart per-song statistics.
		sicks = goods = bads = shits = 0;
		misses = highestCombo = comboBreaks = 0;
		accuracy = 0.00;

		// Pre-initialize noteSplash groups.
		grpNoteSplashPixel = new FlxTypedGroup<NoteSplashPixel>();
		grpNoteSplashPixel.add(new NoteSplashPixel(100, 100, 0));

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		grpNoteSplashes.add(new NoteSplash(100, 100, 0));

		persistentUpdate = true;
		persistentDraw = true;

		// Fallback song data
		if (SONG == null) SONG = Song.loadFromJson('charts/tutorial');

		// Scroll Speed:
		// Use the user's custom speed unless it's set to 1.
		scrollSpeed = (FlxG.save.data.scrollSpeed == 1) ? SONG.speed : FlxG.save.data.scrollSpeed;

		// Conductor Setup
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		// Initialize Dialogue
		loadDialogue();

		// Initialize Stages
		curStage = SONG.stage;
		StageData.songData();
		trace('[STAGE] Successfully Loaded in ${curStage} Stage.');
		buildStage();

		// Resolve Girlfriend variants
		resolveGFVersion();

		// Character Spawning
		StageData.charData();
		applyStageCharacterOffsets();

		add(gf);
		gfCutsceneLayer = new FlxGroup();
		add(gfCutsceneLayer);
		bfTankCutsceneLayer = new FlxGroup();
		add(bfTankCutsceneLayer);

		// Week 4:
		// Limo goes between GF and mom for layering purposes.
		if (curStage == 'limo') add(limo);
		add(dad);
		add(boyfriend);

		// Stage-specific post-character layers.
		switch (curStage) 
		{
			case 'spookyMansion':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		// Create dialogue box
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		// Create Strumline
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		// Create the Strumline Background.
		buildStrumLineBG();

		// Initialize note groups
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);
		add(grpNoteSplashPixel);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		opponentStrums = new FlxTypedGroup<FlxSprite>();

		if (FlxG.save.data.downscroll) strumLine.y = FlxG.height - 150;

		// Generate the song notes.
		generateSong(SONG.song);

		// Camera follow logic
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		// Restore camera follow from the previous song.
		if (prevCamFollow != null) 
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / FlxG.save.data.fpsCap));

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		// HUD ELEMENTS
		buildHUD(doof);

		startingSong = true;

		// Cutscene / Countdown dispatch.
		if (isStoryMode && !seenCutscene) 
		{
			seenCutscene = true;
			playSongCutscene(doof);
		}
		else
		{
			startCountdown();
		}

		super.create();
		cacheArea();
	}

	/**
	 * Loads dialogue lines from file for songs that need it.
	 */
	private function loadDialogue():Void
	{
		switch (SONG.song.toLowerCase()) 
		{
			case 'senpai' | 'roses' | 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('charts/${SONG.song.toLowerCase()}/${SONG.song.toLowerCase()}Dialogue'));
				// Override with censored version if needed.
				if (SONG.song.toLowerCase() == 'roses' && !FlxG.save.data.naughtyness)
				{
					dialogue = CoolUtil.coolTextFile(Paths.txt('charts/roses/rosesDialogueCensored'));
				}
		}
	}

	/**
	 * Constructs all background sprites for the current stage.
	 * [!NOTE] This is subject to change!
	 */
	private function buildStage():Void 
	{ 
		switch (curStage) 
		{
			case 'stage': // Week 1

				defaultCamZoom = 0.9;

				var bg:BGSprite = new BGSprite('stage/stageback', -600, -200, 0.9, 0.9, 'week1');
				add(bg);

				var stageFront:BGSprite = new BGSprite('stage/stagefront', -650, 600, 0.9, 0.9, 'week1');
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if (!FlxG.save.data.lowQuality) 
				{
					var stageLight:BGSprite = new BGSprite('stage/stage_light', -125, -100, 0.9, 0.9, 'week1');
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);

					var stageLightR:BGSprite = new BGSprite('stage/stage_light', 1225, -100, 0.9, 0.9, 'week1');
					stageLightR.setGraphicSize(Std.int(stageLightR.width * 1.1));
					stageLightR.updateHitbox();
					stageLightR.flipX = true;
					add(stageLightR);

					var stageCurtains:BGSprite = new BGSprite('stage/stagecurtains', -500, -300, 1.3, 1.3, 'week1');
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'spookyMansion': // Week 2
				if (!FlxG.save.data.lowQuality)
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike'], 'week2');
				else
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100, 'week2');
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				caching('thunder_1', 'sound');
				caching('thunder_2', 'sound');

			case 'philly': // Week 3
				if (!FlxG.save.data.lowQuality) add(new BGSprite('philly/sky', -100, 0, 0.1, 0.1, 'week3'));

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3, 'week3');
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				lightFadeShader = new BuildingShaders();
				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];

				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3, 'week3');
				if (FlxG.save.data.shaders) phillyWindow.shader = lightFadeShader.shader;
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.antialiasing = FlxG.save.data.antialiasing;
				phillyWindow.updateHitbox();
				phillyWindow.alpha = 0;
				add(phillyWindow);

				if (!FlxG.save.data.lowQuality) add(new BGSprite('philly/behindTrain', -40, 50, 'week3'));

				phillyTrain = new BGSprite('philly/train', 2000, 360, 'week3');
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50, 'week3');
				add(phillyStreet);

			case 'limo': // Week 4
				defaultCamZoom = 0.9;
				add(new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1, 'week4'));

				if (!FlxG.save.data.lowQuality) 
				{
					var bgLimo:BGSprite = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true, 'week4');
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5) 
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true, 'week4');
				fastCar = new BGSprite('limo/fastCarLol', -300, 160, 'week4');
				fastCar.active = true;

			case 'mall': // Week 5 - Cocoa / Eggnog
				defaultCamZoom = 0.8;

				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2, 'week5');
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if (!FlxG.save.data.lowQuality) 
				{
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob'], 'week5');
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3, 'week5');
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				add(new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40, 'week5'));

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers'], 'week5');
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				add(new BGSprite('christmas/fgSnow', -600, 700, 'week5'));

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear'], 'week5');
				add(santa);

				caching('Lights_Shut_off', 'sound');

			case 'mallEvil': // Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2, 'week5');
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				add(new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2, 'week5'));
				add(new BGSprite('christmas/evilSnow', -200, 700, 'week5'));

			case 'school': // Week 6 - Senpai / Roses
				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1, 'week6');
				bgSky.antialiasing = false;
				add(bgSky);

				var repoX:Int = -200;
				var widShit:Int = Std.int(bgSky.width * 6);

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repoX, 0, 0.6, 0.90, 'week6');
				bgSchool.antialiasing = false;
				add(bgSchool);

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repoX, 0, 0.95, 0.95, 'week6');
				bgStreet.antialiasing = false;
				add(bgStreet);

				if (!FlxG.save.data.lowQuality) 
				{
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repoX + 170, 130, 0.9, 0.9, 'week6');
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					fgTrees.antialiasing = false;
					add(fgTrees);
				}

				var bgTrees:FlxSprite = new FlxSprite(repoX - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				bgTrees.antialiasing = false;
				add(bgTrees);

				if (!FlxG.save.data.lowQuality) 
				{
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repoX, -40, 0.85, 0.85, ['PETALS ALL'], true, 'week6');
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					treeLeaves.antialiasing = false;
					add(treeLeaves);
				}

				// Scale all background layers to the same pixel-perfect width
				bgSky.setGraphicSize(widShit);
				bgSky.updateHitbox();
				bgSchool.setGraphicSize(widShit);
				bgSchool.updateHitbox();
				bgStreet.setGraphicSize(widShit);
				bgStreet.updateHitbox();
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				bgTrees.updateHitbox();

				if (!FlxG.save.data.lowQuality) 
				{
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);
					add(bgGirls);

					if (SONG.song.toLowerCase() == 'roses') bgGirls.getScared();
				}

			case 'schoolEvil': // Week 6 - Thorns
				defaultCamZoom = 1;

				var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', 400, 200, 0.8, 0.9, ['background 2'], true, 'week6');
				bg.scale.set(7, 7);
				bg.antialiasing = false;
				add(bg);

			case 'tank': // Week 7
				defaultCamZoom = 0.9;

				add(new BGSprite('tank/tankSky', -400, -400, 0, 0, 'week7'));

				if (!FlxG.save.data.lowQuality) 
				{
					var clouds:BGSprite = new BGSprite('tank/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1, 'week7');
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tank/tankMountains', -300, -20, 0.2, 0.2, 'week7');
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tank/tankBuildings', -200, 0, 0.3, 0.3, 'week7');
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tank/tankRuins', -200, 0, 0.35, 0.35, 'week7');
				ruins.setGraphicSize(Std.int(ruins.width * 1.1));
				ruins.updateHitbox();
				add(ruins);

				if (!FlxG.save.data.lowQuality) 
				{
					add(new BGSprite('tank/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true, 'week7'));
					add(new BGSprite('tank/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true, 'week7'));

					tankWatchtower = new BGSprite('tank/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color'], 'week7');
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tank/tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true, 'week7');
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tank/tankGround', -420, -150, 'week7');
				ground.setGraphicSize(Std.int(ground.width * 1.15));
				ground.updateHitbox();
				add(ground);
				moveTank();

				// Foreground tank sprites layered over characters
				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank/tank0', -500, 650, 1.7, 1.5, ['fg'], 'week7'));
				if (!FlxG.save.data.lowQuality)
					foregroundSprites.add(new BGSprite('tank/tank1', -300, 750, 2, 0.2, ['fg'], 'week7'));
				foregroundSprites.add(new BGSprite('tank/tank2', 450, 940, 1.5, 1.5, ['foreground'], 'week7'));
				if (!FlxG.save.data.lowQuality)
					foregroundSprites.add(new BGSprite('tank/tank4', 1300, 900, 1.5, 1.5, ['fg'], 'week7'));
				foregroundSprites.add(new BGSprite('tank/tank5', 1620, 700, 1.5, 1.5, ['fg'], 'week7'));
				if (!FlxG.save.data.lowQuality)
					foregroundSprites.add(new BGSprite('tank/tank3', 1300, 1200, 3.5, 2.5, ['fg'], 'week7'));
		}
	}

	/**
	 * Resolves which variant of the Girlfriend to use.
	 * Fallback to default if not found.
	 * [!NOTE] This is subject to change!
	 */
	private function resolveGFVersion():Void
	{
		var gfVersionCheck:String = SONG.gfVersion;
		if (SONG.gfVersion == null || gfVersionCheck.length < 1)
		{
			switch(storyWeek)
			{
				case 4: gfVersionCheck = 'gf-car';
				case 5: gfVersionCheck = 'gf-christmas';
				case 6: gfVersionCheck = 'gf-pixel';
				case 7: gfVersionCheck = 'gf-tankmen';
				default: gfVersionCheck = 'gf';
			}

			SONG.gfVersion = gfVersionCheck;
		}

		gf = new Character(400, 130, gfVersionCheck);
		gf.scrollFactor.set(0.95, 0.95);

		// pico-speaker (Stress) spawns crowd tankmen.
		if (gfVersionCheck == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;

			if (!FlxG.save.data.lowQuality)
			{
				// NOTE: Always add at least one visible tankman as a test.
				var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
				tempTankman.strumTime = 10;
				tempTankman.resetShit(20, 600, true);
				tankmanRun.add(tempTankman);

				// Randomly populate the crowd based on note data
				for (i in 0...TankmenBG.animationNotes.length) 
				{
					if (FlxG.random.bool(16)) 
					{
						var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
						tankman.strumTime = TankmenBG.animationNotes[i][0];
						tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(tankman);
					}
				}
			}
		}

		if (!isStoryMode) tankIntroEnd = true;
	}

	/**
	 * Applies offsets to characters based on the current song.
	 * [!NOTE] This is subject to change!
	 */
	private function applyStageCharacterOffsets():Void
	{
		switch (curStage) 
		{
			case 'limo':
				resetFastCar();
				add(fastCar);
			case 'schoolEvil':
				// Afterimage trail on the dad character.
				add(new FlxTrail(dad, null, 4, 24, 0.3, 0.069));
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				dad.y += 60;
				dad.x -= 80;
				if (SONG.gfVersion != 'pico-speaker') 
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}
	}

	/**
	 * Creates and positions the strumline background onto the HUD.
	 */
	private function buildStrumLineBG():Void
	{
		final laneWidth:Int = 110 * 4 + 50;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(laneWidth, FlxG.height * 2);
		laneunderlayOpponent.cameras = [camHUD];
		laneunderlayOpponent.alpha = FlxG.save.data.strumLineBG / 100.0;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(laneWidth, FlxG.height * 2);
		laneunderlay.cameras = [camHUD];
		laneunderlay.alpha = FlxG.save.data.strumLineBG / 100.0;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
		// Only shows one background. (player side only)
		if (FlxG.save.data.middleScroll || !FlxG.save.data.hideCPUStrums) 
		{
			add(laneunderlay);
		}
		else
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}
	}

	/**
	 * Builds all HUD elements and assigns them to camHUD.
	 */
	private function buildHUD(doof:DialogueBox):Void 
	{
		//
		// HEALTH BAR
		//

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !FlxG.save.data.hideHUD;
		add(healthBarBG);
		if (FlxG.save.data.downscroll) healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(
			healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, 
			Std.int(healthBarBG.width - 8), 
			Std.int(healthBarBG.height - 8), this, 'healthLerp', 0, 2
		);
		healthBar.scrollFactor.set();
		healthBar.visible = !FlxG.save.data.hideHUD;
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		//
		// ICONS
		//

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !FlxG.save.data.hideHUD;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !FlxG.save.data.hideHUD;
		add(iconP2);

		//
		// SCORE TEXT / JUDGEMENT COUNTER
		//

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(
			Paths.font("vcr.ttf"), 18, 
			FlxColor.WHITE, CENTER, 
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK
		);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.2;
		add(scoreTxt);

		judgementCounter = new FlxText(20, 350, 0, "", 20);
		judgementCounter.setFormat(
			Paths.font("vcr.ttf"), 20, 
			FlxColor.WHITE, LEFT, 
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK
		);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.visible = !FlxG.save.data.hideHUD;
		judgementCounter.text = [
			'Sick: ${sicks}',
			'Good: ${goods}',
			'Bad: ${bads}',
			'Shit: ${shits}',
			'Combo Breaks: ${comboBreaks}',
			'Max Combo: ${highestCombo}'
		].join('\n');
		if (FlxG.save.data.judgementDisplay) add(judgementCounter);

		//
		// ASSIGN CAMERAS
		//

		judgementCounter.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		grpNoteSplashPixel.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		notes.cameras = [camHUD];

		if (isStoryMode) doof.cameras = [camHUD];
	}

	/**
	 * Dispatches the correct intro cutscene for the current song.
	 * Called only in Story Mode when the cutscene hasn't been seen yet.
	 */
	private function playSongCutscene(doof:DialogueBox):Void
	{
		switch (curSong.toLowerCase())
		{
			case 'monster': cutscene_monster();
			case 'winter-horrorland': cutscene_winterHorrorland();
			case 'senpai' | 'roses' | 'thorns': 
				if (curSong.toLowerCase() == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
				schoolIntro(doof);
			case 'ugh' | 'guns' | 'stress': tankIntro();
			default: startCountdown();
		}
	}

	private function cutscene_monster():Void
	{
		var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		whiteScreen.scrollFactor.set();
		add(whiteScreen);
		camHUD.visible = false;
		cameraMovement();

		new FlxTimer().start(0.1, function(_)
		{
			FlxTween.tween(whiteScreen, {alpha: 0}, 1, {startDelay: 0.1, ease: FlxEase.linear});
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'week2'));

			if (gf != null) gf.playAnim('scared', true);
			boyfriend.playAnim('scared', true);

			new FlxTimer().start(0.5, function(_)
			{
				remove(whiteScreen);
				FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2.5, 
				{
					ease: FlxEase.quadInOut,
					onComplete: function(_)
					{
						startCountdown();
						camHUD.visible = true;
						camHUD.alpha = 0;
						camHUD.alpha = 0;
						// HOLY FLXTWEEN WRAPPER
						FlxTween.tween(camHUD, {alpha: 1}, 1, { ease: FlxEase.quadInOut, onComplete: function(_) { camHUD.visible = true; camHUD.alpha = 1; } });
					}
				});
			});
		});
	}

	private function cutscene_winterHorrorland():Void
	{
		var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		add(blackScreen);
		camHUD.visible = false;

		new FlxTimer().start(0.1, function(_)
		{
			remove(blackScreen);
			FlxG.sound.play(Paths.sound('Lights_Turn_On', 'week5'));
			camFollow.y = -2050;
			camFollow.x += 200;
			FlxG.camera.focusOn(camFollow.getPosition());
			FlxG.camera.zoom = 1.5;

			new FlxTimer().start(0.8, function(_)
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, 
				{
					ease: FlxEase.quadInOut,
					onComplete: function(_) 
					{
						startCountdown();
						camHUD.alpha = 0;
						FlxTween.tween(camHUD, {alpha: 1}, 1, { ease: FlxEase.quadInOut, onComplete: function(_) 
							{
								camHUD.visible = true;
								camHUD.alpha = 1;
							}
						});
					}
				});
			});
		});
	}

	//
	// CUTSCENES
	//

	function schoolIntro(?dialogueBox:DialogueBox):Void 
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy', 'week6');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		// Roses: skip the black screen. Thorns: replace black with red.
		switch (SONG.song.toLowerCase()) {
			case 'roses':
				remove(black);
			case 'thorns':
				remove(black);
				add(red);
				camHUD.visible = false;
		}

		// Fade out black screen incrementally
		new FlxTimer().start(0.3, function(tmr:FlxTimer) 
		{
			black.alpha -= 0.15;
			if (black.alpha > 0) tmr.reset(0.3); // keep ticking until fully faded.
			else 
			{
				remove(black);
				if (dialogueBox != null) 
				{
					inCutscene = true;
					if (SONG.song.toLowerCase() == 'thorns') 
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;

						new FlxTimer().start(0.3, function(swagTimer:FlxTimer) 
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1) swagTimer.reset();
							else 
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies', 'week6'), 
								1, false, null, true, 
								function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, 
									function() 
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});

								// White camera fade out after 3.2 seconds
								new FlxTimer().start(3.2, function(_) 
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					} 
					else add(dialogueBox);
				} 
				else startCountdown();
			}
		});
	}

	/**
	 * Handles the week 7 cutscenes for Ugh, Guns, and Stress.
	 */
	function tankIntro():Void 
	{
		inCutscene = true;
		var dummyGF:FlxSprite = new FlxSprite(210, 70);
		dad.visible = false;

		/** Shared callback run at the end of every tank intro. */
		var tankManEnd:Void->Void = function() 
		{
			tankIntroEnd = true;
			cameraMovement();
			startCountdown();

			FlxG.sound.music.stop();
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			dad.visible = true;
			gf.dance();

			camHUD.alpha = 0;
			FlxTween.tween(camHUD, {alpha: 1}, 1.5, { ease: FlxEase.quadInOut, onComplete: function(_) { camHUD.visible = true; camHUD.alpha = 1; } });
		};

		switch (SONG.song.toLowerCase()) 
		{
			case 'ugh': tankIntroUgh(tankManEnd);
			case 'guns': tankIntroGuns(tankManEnd);
			case 'stress': tankIntroStress(tankManEnd, dummyGF);
		}
	}

	private function tankIntroUgh(tankManEnd:Void->Void):Void 
	{
		camHUD.visible = false;
		caching('wellWellWell', 'sound', 'week7');
		caching('killYou', 'sound', 'week7');
		caching('bfBeep', 'sound', 'week7');

		FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'));
		FlxG.sound.music.fadeIn(5, 0, 0.5);

		var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell', 'week7'));
		FlxG.sound.list.add(wellWellWell);

		var tankCutscene:FlxSprite = new FlxSprite(-20, 320);
		tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong1', 'week7');
		tankCutscene.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
		tankCutscene.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
		tankCutscene.animation.play('wellWell');
		tankCutscene.antialiasing = FlxG.save.data.antialiasing;
		gfCutsceneLayer.add(tankCutscene);

		FlxG.camera.zoom *= 1.2;
		camFollow.y += 100;

		// "Well well well..."
		new FlxTimer().start(0.1, function(_) { wellWellWell.play(true); });

		// Pan to BF
		new FlxTimer().start(3, function(_) 
		{
			camFollow.x += 800;
			camFollow.y += 100;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.27, {ease: FlxEase.quadInOut});

			// BF beeps
			new FlxTimer().start(1.5, function(_) 
			{
				boyfriend.playAnim('singUP', true);
				FlxG.sound.play(Paths.sound('bfBeep', 'week7'), function() 
				{
					boyfriend.playAnim('idle', false);
				});
			});

			// Pan back to tankman
			new FlxTimer().start(3, function(_) 
			{
				camFollow.x -= 800;
				camFollow.y -= 100;
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.5, {ease: FlxEase.quadInOut});

				boyfriend.dance();
				tankCutscene.animation.play('killYou');
				FlxG.sound.play(Paths.sound('killYou', 'week7'));

				// "Let's see what you've got!"
				new FlxTimer().start(6.1, function(_) 
				{
					tankManEnd();
					Paths.clearUnusedMemory();
					gfCutsceneLayer.remove(tankCutscene);
				});
			});
		});
	}

	private function tankIntroGuns(tankManEnd:Void->Void):Void 
	{
		new FlxTimer().start(0.5, function(_) 
		{
			FlxTween.tween(camHUD, {alpha: 0}, 1, { ease: FlxEase.quadInOut, onComplete: function(_) { camHUD.visible = false; camHUD.alpha = 1; } });
		});

		FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0, false);
		FlxG.sound.music.fadeIn(5, 0, 0.5);

		camFollow.setPosition(camPos.x, camPos.y);
		caching('tankSong2', 'sound', 'week7');

		var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2', 'week7'));
		FlxG.sound.list.add(tightBars);
		new FlxTimer().start(0.01, function(_) { tightBars.play(true); });

		camFollow.y += 100;
		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});

		var tankCutscene:FlxSprite = new FlxSprite(20, 320);
		tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong2', 'week7');
		tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 2', 24, false);
		tankCutscene.animation.play('tankyguy');
		tankCutscene.antialiasing = FlxG.save.data.antialiasing;
		gfCutsceneLayer.add(tankCutscene);
		boyfriend.animation.curAnim.finish();

		// GF gets sad partway through
		new FlxTimer().start(4.1, function(_) 
		{
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});

			if (gf != null) 
			{
				gf.playAnim('sad', true);
				gf.animation.finishCallback = function(_) { gf.playAnim('sad', true); };
			}
		});

		// End sequence
		new FlxTimer().start(11.6, function(_) 
		{
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet * 5) / 1000, {ease: FlxEase.quartIn});
			tankManEnd();

			if (gf != null) 
			{
				gf.dance();
				gf.animation.finishCallback = null;
			}

			gfCutsceneLayer.remove(tankCutscene);
			Paths.clearUnusedMemory();
		});
	}

	private function tankIntroStress(tankManEnd:Void->Void, dummyGF:FlxSprite):Void 
	{
		caching('stressCutscene', 'sound', 'week7');

		dad.alpha = 0.0001;
		gf.alpha = 0.0001;

		if (!FlxG.save.data.lowQuality) 
		{
			dummyGF.frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
			dummyGF.animation.addByPrefix('loop', 'GF Dancing at Gunpoint', 24, true);
			dummyGF.animation.play('loop');
			dummyGF.antialiasing = FlxG.save.data.antialiasing;
			gfCutsceneLayer.add(dummyGF);
		}

		boyfriend.visible = false;
		var dummyBF:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		dummyBF.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
		dummyBF.animation.addByPrefix('loop', 'BF idle dance', 24, false);
		dummyBF.animation.play('loop');
		dummyBF.antialiasing = FlxG.save.data.antialiasing;
		bfTankCutsceneLayer.add(dummyBF);

		// Pre-load hidden GF holdup frames (0–6)
		var dummyLoaderShit:FlxGroup = new FlxGroup();
		add(dummyLoaderShit);
		for (i in 0...7) 
		{
			var dummyLoader:FlxSprite = new FlxSprite();
			dummyLoader.loadGraphic(Paths.image('cutscenes/gfHoldup-' + i, 'week7'));
			dummyLoader.antialiasing = FlxG.save.data.antialiasing;
			dummyLoader.alpha = 0.01;
			dummyLoader.y = FlxG.height - 20;
			dummyLoaderShit.add(dummyLoader);
		}

		var bfCatchGf:FlxSprite = new FlxSprite(boyfriend.x - 10, boyfriend.y - 90);
		bfCatchGf.frames = Paths.getSparrowAtlas('characters/bfAndGF', 'shared');
		bfCatchGf.animation.addByPrefix('catch', 'BF catches GF', 24, false);
		bfCatchGf.antialiasing = FlxG.save.data.antialiasing;
		bfCatchGf.visible = false;
		add(bfCatchGf);

		// Fade out HUD
		new FlxTimer().start(0.5, function(_) 
		{
			FlxTween.tween(camHUD, {alpha: 0}, 1.5, { ease: FlxEase.quadInOut, onComplete: function(_) { camHUD.visible = false; camHUD.alpha = 1; } });
		});

		// Zoom into center stage
		new FlxTimer().start(1, function(_) 
		{
			camFollow.x = 436.5;
			camFollow.y = 534.5;
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
		});

		var stressCutscene:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene', 'week7'));
		FlxG.sound.list.add(stressCutscene);

		var stressCutsceneCensored:FlxSound = new FlxSound().loadEmbedded(Paths.sound('song3censor', 'week7'));
		FlxG.sound.list.add(stressCutsceneCensored);

		// Tank cutscene sprites
		var tankCutscene:FlxSprite = new FlxSprite(-70, 320);
		tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong3-pt1', 'week7');
		tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 3 P1 UNCUT', 24, false);
		tankCutscene.animation.play('tankyguy');
		tankCutscene.antialiasing = FlxG.save.data.antialiasing;
		bfTankCutsceneLayer.add(tankCutscene);

		var alsoTankCutscene:FlxSprite = new FlxSprite(20, 320);
		alsoTankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong3-pt2', 'week7');
		alsoTankCutscene.animation.addByPrefix('swagTank', 'TANK TALK 3 P2 UNCUT', 24, false);
		alsoTankCutscene.antialiasing = FlxG.save.data.antialiasing;
		alsoTankCutscene.y = FlxG.height + 100;
		alsoTankCutscene.visible = false;
		bfTankCutsceneLayer.add(alsoTankCutscene);

		// Play correct audio + handle optional mouth censor
		new FlxTimer().start(0.1, function(_) 
		{
			if (FlxG.save.data.naughtyness) stressCutscene.play(true);
			else 
			{
				stressCutsceneCensored.play(true);

				var censor:FlxSprite = new FlxSprite();
				censor.frames = Paths.getSparrowAtlas('cutscenes/censor', 'week7');
				censor.animation.addByPrefix('censor', 'mouth censor', 24);
				censor.antialiasing = FlxG.save.data.antialiasing;
				censor.animation.play('censor');
				censor.visible = false;
				add(censor);

				// Show/hide censor at timed intervals matching the audio
				inline function showCensor(delay:Float, duration:Float, ox:Float, oy:Float):Void 
				{
					new FlxTimer().start(delay, function(_) 
					{
						censor.visible = true;
						censor.setPosition(dad.x + ox, dad.y + oy);
						new FlxTimer().start(duration, function(_) { censor.visible = false; });
					});
				}

				showCensor(4.6, 0.2, 160, 180);
				showCensor(25.1, 0.9, 120, 170);
				showCensor(30.7, 0.4, 210, 190);
				showCensor(33.8, 0.6, 180, 170);
			}
		});

		// Mid-cutscene: GF holdup scene
		new FlxTimer().start(15.1, function(_) 
		{
			camFollow.y -= 170;
			camFollow.x += 200;
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.3}, 2.1, {ease: FlxEase.quadInOut});

			new FlxTimer().start(2.2, function(_) 
			{
				FlxG.camera.zoom = 0.8;
				boyfriend.visible = false;
				bfCatchGf.visible = true;
				bfCatchGf.animation.play('catch');
				bfTankCutsceneLayer.remove(dummyBF);

				bfCatchGf.animation.finishCallback = function(_) 
				{
					bfCatchGf.visible = false;
					boyfriend.visible = true;
				};

				new FlxTimer().start(3, function(_) 
				{
					camFollow.y += 180;
					camFollow.x -= 80;
				});
				new FlxTimer().start(2.3, function(_) 
				{
					bfTankCutsceneLayer.remove(tankCutscene);
					alsoTankCutscene.visible = true;
					alsoTankCutscene.y = 320;
					alsoTankCutscene.animation.play('swagTank');
				});
			});

			gf.visible = false;
			dad.visible = false;
			var cutsceneShit:FlxSprite = new FlxSprite(210, 70, 'gfHoldup');
			gfCutsceneLayer.add(cutsceneShit);
			gfCutsceneLayer.remove(dummyGF);

			new FlxTimer().start(0.1, function(_) 
			{
				gf.alpha = 1;
				gf.visible = true;
				dad.visible = true;
			});

			new FlxTimer().start(20, function(_) 
			{
				tankManEnd();
				remove(dummyLoaderShit);
				dummyLoaderShit.destroy();
				gfCutsceneLayer.remove(cutsceneShit);
				bfTankCutsceneLayer.remove(alsoTankCutscene);
				dad.alpha = 1;
				Paths.clearUnusedMemory();
			});
		});

		// BF miss animation near end
		new FlxTimer().start(31.2, function(_) 
		{
			boyfriend.playAnim('singUPmiss', true);
			boyfriend.animation.finishCallback = function(name:String) 
			{
				if (name == 'singUPmiss') 
				{
					boyfriend.playAnim('idle', true);
					boyfriend.animation.curAnim.finish();
				}
			};

			camFollow.x += 400;
			camFollow.y += 150;
			FlxG.camera.zoom = defaultCamZoom * 1.4;
			FlxG.camera.focusOn(camFollow.getPosition());
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});

			new FlxTimer().start(1, function(_) 
			{
				camFollow.x -= 400;
				camFollow.y -= 150;
				FlxG.camera.zoom /= 1.4;
				FlxG.camera.focusOn(camFollow.getPosition());
			});
		});
	}

	//
	// COUNTDOWN LOGIC
	//

	/**
	 * Preloads countdown image/sound assets into the cache.
	 */
	function cacheCountdown()
	{
		var introAlts = ['ready', 'set', 'go'];
		for (asset in introAlts) Paths.image(asset, 'shared');

		var altSuffix = "-pixel";
		Paths.sound('intro3' + altSuffix);
		Paths.sound('intro2' + altSuffix);
		Paths.sound('intro1' + altSuffix);
		Paths.sound('introGo' + altSuffix);
	}

	/**
	 * Starts the countdown sequence.
	 * Generates strums, positions lane underlays, and fires a beat-locked timer.
	 */
	function startCountdown():Void 
	{
		inCutscene = false;
		camHUD.visible = true;

		if (FlxG.save.data.downscroll) strumLine.y = FlxG.height - 150;

		// Only generate arrows if they haven't already been generated.
		if (strumLineNotes.length == 0)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
		}

		// Align lane underlays to match strum positions.
		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing) FlxG.sound.music.stop();

		// Determine whether we need pixel UI assets. (Week 6 stages)
		var introAssets:Map<String, Array<String>> = [
			'default' => [
				'ui/countdown/funkin/ready', 
				'ui/countdown/funkin/set', 
				'ui/countdown/funkin/go'
			],
			'school' => [
				'ui/countdown/pixel/ready-pixel', 
				'ui/countdown/pixel/set-pixel', 
				'ui/countdown/pixel/date-pixel'
			],
			'schoolEvil' => [
				'ui/countdown/pixel/ready-pixel', 
				'ui/countdown/pixel/set-pixel', 
				'ui/countdown/pixel/date-pixel'
			],
		];

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{	
			// Character idle dances during countdown.
			if (swagCounter % gfSpeed == 0)
			{
				if (gf != null) gf.dance();
			}

			if (swagCounter % 2 == 0)
			{
				if (boyfriend != null)
				{
					if (!boyfriend.animation.curAnim.name.startsWith("sing"))
						boyfriend.playAnim('idle');
				}

				if (dad != null)
				{
					if (!dad.animation.curAnim.name.startsWith("sing"))
						dad.dance();
				}
			}
			else if (dad.currentCharacter == 'spookyKids')
			{
				if (!dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();
			}

			callOnEvents();

			// Resolve which intro asset set to use.
			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var week6Lib:String = "shared";
			var aliasing:Bool = FlxG.save.data.antialiasing;

			for (key in introAssets.keys())
			{
				if (key == curStage)
				{
					introAlts = introAssets.get(key);
					altSuffix = '-pixel';
					aliasing = false;
				}
			}

			// Show countdown sprite for this beat.
			switch (swagCounter)
			{
				case 0: FlxG.sound.play(Paths.sound('gameplay/countdown/intro3' + altSuffix, 'shared'), 0.6);
				case 1 | 2 | 3:
					var index:Int = swagCounter - 1; // maps beat 1/2/3 to asset index 0/1/2.
					var introSound:String = [
						'intro2', 'intro1', 'introGo'
					][index];
					var image:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[index], week6Lib));
					image.scrollFactor.set();
					image.updateHitbox();
					if (curStage.startsWith('school'))
						image.setGraphicSize(Std.int(image.width * daPixelZoom));
					image.screenCenter();
					image.cameras = [camHUD];
					image.antialiasing = aliasing;
					add(image);
					// Add a tween to move the image up and fade out.
					FlxTween.tween(image, {y: image.y + 100, alpha: 0},
					Conductor.crochet / 1000, 
					{
						ease: FlxEase.cubeInOut,
						onComplete: function(_) { image.destroy(); }
					});
					FlxG.sound.play(Paths.sound('gameplay/countdown/$introSound' + altSuffix, 'shared'), 0.6);
			}
			swagCounter++;
		}, 5);
	}

	/**
	 * Begins audio playback after the countdown reaches zero.
	 */
	function startSong():Void 
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused) 
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	//
	// NOTE GENERATION
	//

	/**
	 * Parses song chart data and populates `unspawnNotes` with head and sustain notes.
	 * @param dataPath 
	 */
	private function generateSong(dataPath:String):Void 
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		// Load vocals (or an empty sound if not needed).
		vocals = SONG.needsVoices ? new FlxSound().loadEmbedded(Paths.voices(SONG.song)) : new FlxSound();
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		final noteSkin:NoteSkin = curStage.startsWith('school') ? PIXEL : DEFAULT;
		var daBeats:Int = 0;

		for (section in songData.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				final daStrumTime:Float = songNotes[0];
				final daNoteData:Int = Std.int(songNotes[1] % 4);

				// If note index > 3 it belongs to the opponent;
				// otherwise it belongs to the player.
				final gottaHitNote:Bool = (songNotes[1] > 3) ? !section.mustHitSection : section.mustHitSection;

				var oldNote:Note = unspawnNotes.length > 0 ? unspawnNotes[unspawnNotes.length - 1] : null;

				// Create the head of the note.
				var swagNote:Note = Note.pool();
				swagNote.setup({
					strumTime: daStrumTime,
					noteData: daNoteData,
					sustainLength: songNotes[2],
					isSustainNote: false,
					skin: noteSkin,
					prevNote: oldNote
				}, scrollSpeed);
				swagNote.altNote = songNotes[3];
				swagNote.mustPress = gottaHitNote;
				swagNote.scrollFactor.set(0, 0);
				applyMustPress(swagNote);
				unspawnNotes.push(swagNote);

				// Create the sustain trail of the note.
				final susLength:Int = Std.int(Math.floor(swagNote.sustainLength / Conductor.stepCrochet));
				for (susNote in 0...susLength)
				{
					oldNote = unspawnNotes[unspawnNotes.length - 1];

					var sustainNote:Note = Note.pool();
					sustainNote.setup({
						strumTime: daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
						noteData: daNoteData,
						sustainLength: 0,
						isSustainNote: true,
						skin: noteSkin,
						prevNote: oldNote
					}, scrollSpeed);
					sustainNote.mustPress = gottaHitNote;
					sustainNote.scrollFactor.set(0, 0);
					applyMustPress(sustainNote);
					unspawnNotes.push(sustainNote);
				}

				// Scale the PREVIOUS note's height to fill the gap. (original Psych formula)
				if (susLength > 1 && oldNote != null && oldNote.isSustainNote) 
				{
					final speed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2);
					oldNote.scale.y = 1.0;

					// Target height in pixels = how far a note travels in one step.
					final targetPixelHeight:Float = (0.45 * Conductor.stepCrochet * speed);
					// `scale.y = target` | original frame height
					oldNote.scale.y = targetPixelHeight / oldNote.frameHeight;
					oldNote.updateHitbox();
				}
			}
			daBeats++;
		}
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	/**
	 * Hides opponent notes when middlescroll or CPU strums is active.
	 * they still exist, just.. invisible... :)
	 */
	private inline function applyMustPress(note:Note):Void
	{
		if (!note.mustPress)
		{
			if (FlxG.save.data.middlescroll || !FlxG.save.data.hideCPUStrums)
				note.alpha = 0;
		}
	}

	/**
	 * Ascending sort comparator for notes by strum time.
	 */
	function sortByShit(Obj1:Note, Obj2:Note):Int 
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	/**
	 * Configurable sort comparator (used in beatHit for DESCENDING render order).
	 */
	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
	{
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	//
	// STATIC ARROWS
	//

	/**
	 * Generates the 4 strum arrows for the given player (0 = opponent, 1 = player).
	 */
	private function generateStaticArrows(player:Int):Void
	{
		final isPixel:Bool = curStage == 'school' || curStage == 'schoolEvil';

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			if (isPixel) 
				_setupPixelArrow(babyArrow, i);
			else
				_setupDefaultArrow(babyArrow, i);

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;

			// Base X position: left half for opponent, right half for player
			babyArrow.x += 50 + (FlxG.width / 2 * player) + (Note.SWAG_WIDTH * i);

			if (FlxG.save.data.middlescroll) 
			{
				// In middlescroll: center player arrows, push opponent arrows off-screen.
				if (player == 1) 
					babyArrow.x -= 270;
				else 
					babyArrow.x -= 2000;
			} 
			else if (player == 1) babyArrow.x += 40; // nudge player side slightly right.

			// Completely hide CPU strums.
			if (!FlxG.save.data.hideCPUStrums)
			{
				if (player == 1) 
					babyArrow.alpha = 0;
				else
					babyArrow.visible = false;
			}

			// Freeplay intro tween (arrows slide down and fade in).
			if (!isStoryMode) 
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;

				if (!FlxG.save.data.middlescroll || player != 0)
				{
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
			}

			babyArrow.animation.play('static');

			switch (player) 
			{
				case 0: opponentStrums.add(babyArrow);
				case 1: playerStrums.add(babyArrow);
			}
			strumLineNotes.add(babyArrow);
		}

		// Center offsets once after all arrows are placed
		opponentStrums.forEach(function(spr:FlxSprite) spr.centerOffsets());
	}

	/**
	 * Configures `PIXEL` variant strums for week 6.
	 */
	private function _setupPixelArrow(arrow:FlxSprite, col:Int):Void 
	{
		arrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
		arrow.setGraphicSize(Std.int(arrow.width * daPixelZoom));
		arrow.antialiasing = false;

		// static/pressed/confirm frame indices per column
		final staticFrames = [0, 1, 2, 3];
		final pressedFrames = [[4, 8], [5, 9], [6, 10], [7, 11]];
		final confirmFrames = [[12, 16], [13, 17], [14, 18], [15, 19]];

		arrow.animation.add('static', [staticFrames[col]]);
		arrow.animation.add('pressed', pressedFrames[col], 12, false);
		arrow.animation.add('confirm', confirmFrames[col], col == 2 ? 12 : 24, false);

		// Color aliases used elsewhere for note rendering reference
		arrow.animation.add('purplel', [4]);
		arrow.animation.add('blue', [5]);
		arrow.animation.add('green', [6]);
		arrow.animation.add('red', [7]);
	}

	/**
	 * Configures the `DEFAULT` strum arrows.
	 */
	private function _setupDefaultArrow(arrow:FlxSprite, col:Int):Void 
	{
		arrow.frames = Paths.getSparrowAtlas('NOTE_assets');
		arrow.antialiasing = FlxG.save.data.antialiasing;
		arrow.setGraphicSize(Std.int(arrow.width * 0.7));

		final staticAnims = [
			'arrow static instance 1',
			'arrow static instance 2',
			'arrow static instance 4',
			'arrow static instance 3'
		];
		final pressAnims = ['left press', 'down press', 'up press', 'right press'];
		final confirmAnims = ['left confirm', 'down confirm', 'up confirm', 'right confirm'];

		arrow.animation.addByPrefix('static', staticAnims[col]);
		arrow.animation.addByPrefix('pressed', pressAnims[col], 24, false);
		arrow.animation.addByPrefix('confirm', confirmAnims[col], 24, false);
	}

	//
	// UPDATE LOGIC
	//

	override public function update(elapsed:Float) 
	{
		// HTML5 requires per-frame lerp recalculation.
		#if html5
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);
		#end

		#if !debug 
		perfectMode = false; 
		#end

		if (FlxG.keys.justPressed.NINE) iconP1.swapOldIcon();

		// Stage-specific per-frame logic.
		updateStageLogic(elapsed);

		super.update(elapsed);

		updateScoreText();

		songScoreLerp = FlxMath.lerp(songScoreLerp, songScore, 0.45);
		healthLerp = FlxMath.lerp(healthLerp, health, 0.15);

		// Pause the game when needed.
		if (controls.PAUSE && startedCountdown && canPause) 
			pauseGame(true);

		// Debug menu shortcuts
		if (FlxG.keys.justPressed.SEVEN)
			FlxG.switchState(new ChartingState());
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		updateHealthIcons();
		updateSongPosition();
		updateCameraSection();

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

		updateSongEvents();

		if (controls.RESET)
		{
			health = 0;
			trace('[INFO] Pressed RESET, health set to 0.');
		}
		deathTransition();

		spawnNextNote();
		if (generatedMusic) processNotes();

		// Reset opponents strum arrows after confirm animation.
		opponentStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene) keyShit();

		// Debug playstate shortcuts
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.TWO)
			health += 0.1 * 2.0;
		if (FlxG.keys.justPressed.THREE)
			health -= 0.05 * 2.0;
		#end
	}

	/**
	 * Runs any per-frame logic that is specific to the active stage.
	 */
	private function updateStageLogic(elapsed:Float):Void 
	{
		switch (curStage) 
		{
			case 'philly':
				if (trainMoving) 
				{
					trainFrameTiming += elapsed;
					// Throttle train movement to 24fps to match its animation rate.
					if (trainFrameTiming >= 1 / 24) 
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				lightFadeShader.update((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
			case 'tank': moveTank();
		}
	}

	/**
	 * Updates the score text every frame.
	 */
	private function updateScoreText():Void
	{
		scoreTxt.color = FlxColor.WHITE;
		scoreTxt.clearFormats();
		Ratings.getComboRank();

		if (botplay) scoreTxt.text = 'Botplay Enabled';
		else
		{
			final SHOW_DECIMALS:Bool = false;
			final COMMA_SEPERATED:Bool = true;

			if (FlxG.save.data.accuracyDisplay)
			{
				scoreTxt.text = 'Score: ${FlxStringUtil.formatMoney(songScore, SHOW_DECIMALS, COMMA_SEPERATED)}'
				+ ' | Misses: ${misses}'
				+ ' | Accuracy: ${truncateFloat(accuracy, 2)}% - [${ratingFC}]';

				// Apply FlxColor ONLY to the combo ranks. (i.e. 'MFC', 'SDCB', etc.)
				final ratingStart = scoreTxt.text.length - ratingFC.length - 1;
				scoreTxt.addFormat(Ratings.getComboRankFormat(), ratingStart, ratingStart + ratingFC.length);
			}
			else
			{
				scoreTxt.text = 'Score: ${FlxStringUtil.formatMoney(songScore, SHOW_DECIMALS, COMMA_SEPERATED)}';
			}
		}
	}

	/**
	 * Size and position of the health icon, resting on the health bar.
	 */
	private function updateHealthIcons():Void
	{
		// Shrink toward default size each frame (creates the bounce effect on beat).
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(145, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(145, iconP2.width, 0.85)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		final iconOffset:Int = 26;

		// Remap icons to a 0-100 percentage of the health bar
		// followed by ratio along the bar.
		final percent:Float = FlxMath.remapToRange(healthBar.value, 0, 2, 100, 0) * 0.01;
		iconP1.x = healthBar.x + (healthBar.width * percent) - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * percent) - (iconP2.width - iconOffset);

		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (health > 2) health = 2;

		// Low-health icon frame
		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
		// High-health opponent icon frame
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;
	}

	/**
	 * Advances Conductor.songPosition each frame.
	 * During countdown: advances manually and triggers `startSong()` at the end.
	 * During song: interpolates between frame delta and the real playhead for sync.
	 */
	private function updateSongPosition():Void
	{
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0) startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Blend frame-delta time with real playhead to reduce drift.
				if (Conductor.lastSongPos != Conductor.songPosition) 
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
	}

	/**
	 * Checks whether the section has changed and updates cameraRightSide.
	 * Camera only switches on beat 0 of every 4-beat group.
	 */
	private function updateCameraSection():Void
	{
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) 
		{
			if (curBeat % 4 == 0) 
			{
				cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
				cameraMovement();
			}
		}
	}

	/**
	 * Handles song-specific timed events driven by `beatHit`.
	 * [!NOTE] this is subject to change!
	 */
	private function updateSongEvents():Void
	{
		if (curSong == 'Fresh') 
		{
			switch (curBeat) 
			{
				case 16: 
					camZooming = true;
					gfSpeed = 2;
				case 48: gfSpeed = 1;
				case 80: gfSpeed = 2;
				case 112: gfSpeed = 1;
			}
		}

		if (curSong == 'Bopeebo') 
		{
			switch (curBeat) 
			{
				case 128, 129, 130: vocals.volume = 0;
			}
		}
	}

	/**
	 * Triggers gameover instance if the health reaches 0.
	 * Does not trigger if `practiceMode` is on.
	 */
	private function deathTransition():Void
	{
		if (health <= 0 && !practiceMode)
		{
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();
			deathCounter++;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	/**
	 * Moves the next unspawned note into the active `notes` group when it's close enough.
	 */
	private function spawnNextNote():Void 
	{
		if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1500) 
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);
			unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
		}
	}

	/**
	 * Positions, clips, and processes every alive note each frame.
	 * Handles: X alignment, Y scrolling, sustain clipping, offscreen culling,
	 * 	opponent auto-hit, botplay auto-hit, and miss on scroll-past.
	 * 
	 * TODO: PUT THIS ENTIRE FUNCTION IN THE NOTE CLASS.
	 */
	private function processNotes():Void
	{
		notes.forEachAlive(function(daNote:Note) 
		{
			// Get the hold array for sustain clipping.
			final holdArray:Array<Bool> = [
				controls.NOTE_LEFT, 
				controls.NOTE_DOWN, 
				controls.NOTE_UP, 
				controls.NOTE_RIGHT
			];

			// Get the note's scroll speed
			final leSpeed:Float = scrollSpeed == 1 
			? SONG.speed 
			: scrollSpeed;

			// Strum line center Y (used for sustain clipping)
			final center:Float = strumLine.y + (Note.SWAG_WIDTH / 2);

			// X: Align to the correct strumline arrow.
			var strumGroup = daNote.mustPress ? playerStrums : opponentStrums;
			var strum = strumGroup.members[daNote.noteData];
			if (strum != null)
			{
				daNote.x = strum.x + strum.width / 2 - daNote.width / 2;
			}

			// Y: Scroll positioning
			if (FlxG.save.data.downscroll)
			{
				// Downscroll: Notes fall downward from above the strumline.
				daNote.y = strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * leSpeed);
					
				if (daNote.isSustainNote)
				{
					daNote.y -= daNote.height - (0.45 * Conductor.stepCrochet * leSpeed);
				}
			}
			else
			{
				// Upscroll: Notes rise upward towards the strumline.
				daNote.y = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * leSpeed);
			}

			// Sustain Trails
			if (daNote.isSustainNote)
			{
				// A sustain trail should be clipped once the player is holding it.
				// NOTE: This goes for opponents, and botplay mode also.
				final shouldClip:Bool = botplay 
					|| !daNote.mustPress 
					|| daNote.wasGoodHit
					|| holdArray[Math.floor(Math.abs(daNote.noteData))]
					|| (daNote.prevNote != null && daNote.prevNote.wasGoodHit && !daNote.canBeHit);

				if (FlxG.save.data.downscroll)
				{
					// Downscroll: clip the bottom portion above the strum center
					if (shouldClip && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
					{
						var rect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
						rect.height = Math.max(0, (center - daNote.y) / daNote.scale.y);
						rect.y = daNote.frameHeight - rect.height;
						daNote.clipRect = rect;
					}
					else
					{
						daNote.clipRect = null;
					}
				}
				else
				{
					// Upscroll: clip the top portion below the strum center
					if (shouldClip && daNote.y <= center)
					{
						var rect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
						rect.y = Math.max(0, (center - daNote.y) / daNote.scale.y);
						rect.height = Math.max(0, daNote.frameHeight - rect.y);
						daNote.clipRect = rect;
					}
					else
					{
						daNote.clipRect = null;
					}
				}
			}

			// Visibility Check: disable when completely offscreen.
			final offscreen:Bool = FlxG.save.data.downscroll 
				? daNote.y > FlxG.height + daNote.height 
				: daNote.y + daNote.height < -daNote.height;
			daNote.visible = !offscreen;
			daNote.active = !offscreen;

			// Opponent auto-hit
			if (!daNote.mustPress && daNote.wasGoodHit)
			{
				if (SONG.song != 'Tutorial') camZooming = true;

				var altAnim = "";
				if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) altAnim = '-alt';
				if (daNote.altNote) altAnim = '-alt';

				// If a sustain trail exists, only play the sing animation once.
				if (!daNote.isSustainNote)
				{
					switch (Math.abs(daNote.noteData))
					{
						case 0: dad.playAnim('singLEFT' + altAnim, true);
						case 1: dad.playAnim('singDOWN' + altAnim, true);
						case 2: dad.playAnim('singUP' + altAnim, true);
						case 3: dad.playAnim('singRIGHT' + altAnim, true);
					}
				}

				dad.holdTimer = 0;
				if (SONG.needsVoices) vocals.volume = 1;

				// Take away the same amount of health that the player would take -
				// but.. a tad bit more, for a challenge :)
				if (healthDrain)
				{
					if (health > 0.1)
					{
						health -= 0.030 * (daNote.isSustainNote ? 0.35 : 1);
					}
				}

				opponentStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(daNote.noteData) == spr.ID) spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else spr.centerOffsets();
				});
			
				notes.remove(daNote, true);
				daNote.recycle();
				return; // skip further processing on this note.
			}

			// Botplay Auto-Hit
			if (daNote.mustPress && botplay)
			{
				if (daNote.isSustainNote && daNote.canBeHit) 
				{
					goodNoteHit(daNote); 
				}
				else if (!daNote.isSustainNote && daNote.strumTime <= Conductor.songPosition)
				{
					goodNoteHit(daNote);
				}
			}

			// Offscreen Kill + Miss penalty
			if (offscreen)
			{
				if (daNote.mustPress && !botplay && !daNote.wasGoodHit && !daNote.isSustainNote)
				{
					comboBreak(daNote.noteData);
					vocals.volume = 0;
				}

				notes.remove(daNote, true);
				daNote.recycle();
			}
		});
	}

	override function openSubState(SubState:FlxSubState) 
	{
		if (paused) 
		{
			if (FlxG.sound.music != null) 
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished) startTimer.active = false;
			paused = true;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() 
	{
		if (paused) 
		{
			if (FlxG.sound.music != null && !startingSong) resyncVocals();
			if (!startTimer.finished) startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	override public function onFocus():Void
		super.onFocus();

	override public function onFocusLost():Void
	{
		super.onFocusLost();
		pauseGame();
	}

	/**
	 * Called when you want to pause the game.
	 * @param allowGitaroo Whether to allow the Gitaroo Man easter egg.
	 */
	public function pauseGame(allowGitaroo:Bool = false):Void
	{
		if (!startedCountdown || !canPause || paused) return;

		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 0.1% chance for Gitaroo Man easter egg.
		if (allowGitaroo && FlxG.random.bool(0.1))
		{
			FlxG.switchState(new GitarooPause());
			return;
		}

		var boyfriendPos = boyfriend.getScreenPosition();
		openSubState(new PauseSubState(boyfriendPos.x, boyfriendPos.y));
	}

	/**
	 * Called when you restart a song.
	 * 
	 * Classes required for this function:
	 * `GameOverSubState`: When a gameover occurs, make a smooth transition back to `PlayState`.
	 * `PauseSubState`: Apply the same when restarting a song in the pause menu.
	 */
	public function restartSong():Void
	{
		trace('[INFO] Song is restarting. Resetting values...');

		// Reset health immediately to prevent softlocking.
		health = 1;

		persistentUpdate = true;
    persistentDraw = true;

		// Pause audio immediately to prevent audio overlap.
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.pause();
      FlxG.sound.music.time = 0;
    }

    if (vocals != null) vocals.pause();

		// Stop the countdown timer if it's still running
    if (startTimer != null && !startTimer.finished)
    {
      startTimer.cancel();
      startTimer.destroy();
    }

		// Reset all song state flags.
		startingSong = true;
    songStarted = false;
    endingSong = false;
    generatedMusic = false;
    startedCountdown = false;
    paused = false;
    talking = false;
    inCutscene = false;
    canPause = true;
		hasRestarted = true;

		// Reset all song score data.
		songScore = 0;
    misses = 0;
    combo = 0;
    sicks = goods = bads = shits = 0;
    highestCombo = 0;
    accuracy = 0;
    totalRatingsHit = 0;
    totalRatingsHitDefault = 0;
    totalRatings = 0;
    totalPlayed = 0;
    updatedAcc = false;
		updateStatistic();

		// Vwoosh existing notes downward off-screen before clearing them.
		var noteVwooshDuration:Float = 0.5;
		notes.forEachAlive(function(note:Note)
		{
			FlxTween.tween(note, {y: FlxG.height + 100, alpha: 0}, noteVwooshDuration,
			{
				ease: FlxEase.expoIn,
				onComplete: function(_) { note.kill(); }
			});
		});

		// Wait for the vwoosh to finish before regenerating.
    new FlxTimer().start(noteVwooshDuration, function(_)
    {
			canPause = true;

      Conductor.mapBPMChanges(SONG);
      Conductor.changeBPM(SONG.bpm);
      Conductor.songPosition = -(Conductor.crochet * 5);

			notes.clear();
      unspawnNotes = [];
      Note.clearPool();
			remove(notes);

      generateSong(SONG.song);
			notes.cameras = [camHUD];

			trace('[INFO] Values reset. Starting song...');
      startCountdown();
    });
	}

	function resyncVocals():Void 
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		trace('Resynced vocals at ${Conductor.songPosition}.');
	}

	function endSong():Void 
	{
		Note.clearPool();

		seenCutscene = false;
		deathCounter = 0;
		canPause = false;

		// Stop and dispose of audio.
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
		}
		vocals.volume = 0;
		vocals.stop();
		vocals.destroy();
		
		#if !switch
		// Save highscore if you're not on switch.
		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			Highscore.saveCombo(SONG.song, Ratings.getComboRank(), storyDifficulty);
			Highscore.saveRating(SONG.song, truncateFloat(accuracy, 2), storyDifficulty);
		}
		#end

		if (isStoryMode) 
		{
			campaignScore += songScore;
			campaignMisses += misses;
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) 
			{
				// If the song is finished and you're in story mode, return back to the menu.
				FlxG.sound.playMusic(Paths.music('freakyMenu/freakyMenu'));
				FlxG.switchState(new StoryMenuState());

				if (!practiceMode && !botplay)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					StoryMenuState.unlockNextWeek(storyWeek);
				}
				FlxG.save.flush();
			} 
			else 
			{
				var difficulty:String = getDifficultySuffix();

				trace('[STORY MODE] Loading next song: ' + storyPlaylist[0].toLowerCase() + difficulty);
				if (SONG.song.toLowerCase() == 'eggnog')  
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off', 'week5'), 1, false, null, true, function() {
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
				
					prevCamFollow = camFollow;
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		} 
		else 
		{
			trace('Returning to freeplay menu...');
			FlxG.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu/freakyMenu'));
		}
	}

	/**
	 * Returns the difficulty suffix string used for JSON file loading.
	 * e.g. "" for normal, "-easy" for easy, "-hard" for hard.
	 */
	private function getDifficultySuffix():String
	{
		if (SONG.song.toLowerCase() == 'test')
			return 'normal';
		if (storyDifficulty == 0)
			return '-easy';
		if (storyDifficulty == 2)
			return '-hard';
		return "";
	}

	/**
	 * Preloads popup score assets into the asset cache.
	 */
	private function cachePopUpScore():Void
	{
		var prefix:String = curStage.startsWith('school') ? 'ui/popup/pixel/' : "ui/popup/funkin/";
		var suffix:String = curStage.startsWith('school') ? '-pixel' : "";
		var lib:String = curStage.startsWith('school') ? null : "preload";

		for (name in ['sick', 'good', 'bad', 'shit', 'combo']) 
			Paths.image(prefix + name + suffix, lib);
		for (i in 0...10) 
			Paths.image(prefix + 'num' + i + suffix, lib);
	}

	/**
	 * Determines the judgement for the given note, applies to score/health changes,
	 *  and spawns the rating pop-sprite + number assets.
	 * 
	 * @param daNote The note that was hit. Pass null to force a `SHIT` rating.
	 */
	private function popUpScore(daNote:Note):Void 
	{
		// noteDiff: positive = early, negative = late (clamped to safeZoneOffset for forced SHIT)
		var noteDiff:Float = (daNote != null) 
		? -(daNote.strumTime - Conductor.songPosition) 
		: Conductor.safeZoneOffset;
		
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var doSplash:Bool = false;
		var daRating:String = Ratings.judgeNote(noteDiff);

		// Apply judgement effects.
		switch (daRating) 
		{
			case 'shit':
				shits++;
				comboBreaks++;
				score = 0;
				combo = 0;
				health -= 0.06;
				totalRatingsHit += 0.50;
				updateStatistic();

			case 'bad':
				bads++;
				comboBreaks++;
				score = 0;
				combo = 0;
				health -= 0.06;
				totalRatingsHit += 0.50;
				updateStatistic();

			case 'good':
				goods++;
				score = 200;
				totalRatingsHit += 0.75;
				updateStatistic();

			case 'sick':
				sicks++;
				totalRatingsHit += 1;
				updateStatistic();
				if (health < 2) health += 0.01;
				if (FlxG.save.data.noteSplash) doSplash = true;
		}

		// NoteSplash Logic
		if (doSplash) 
		{
			switch (curStage) 
			{
				case "school" | "schoolEvil":
					var splashPixel:NoteSplashPixel = grpNoteSplashPixel.recycle(NoteSplashPixel);
					splashPixel.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
					grpNoteSplashPixel.add(splashPixel);
				default:
					var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
					splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
					grpNoteSplashes.add(splash);
			}
		}

		if (!practiceMode && !botplay) songScore += score;

		// Asset path helpers (PIXEL and DEFAULT variants)
		final prefix:String = curStage.startsWith('school') ? 'ui/popup/pixel/' : "ui/popup/funkin/";
		final suffix:String = curStage.startsWith('school') ? '-pixel' : "";
		final lib:String = curStage.startsWith('school') ? null : "preload";
		final isSchool:Bool = curStage.startsWith('school');

		// insert behind strumLineNotes to prevent overlapping with arrows.
		final strumLineIndex:Int = members.indexOf(strumLineNotes);

		// Rating Sprite
		rating.loadGraphic(Paths.image(prefix + daRating + suffix, lib));
		rating.scrollFactor.set(0, 0);
		rating.cameras = [camHUD];
		if (!isSchool)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.6));
			rating.antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			rating.antialiasing = false;
		}
		rating.updateHitbox();
		rating.x = (FlxG.width  * 0.474) - rating.width  / 2;
		rating.y = (FlxG.height * 0.45) - 60 - rating.height / 2;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !FlxG.save.data.hideHUD;
		insert(strumLineIndex, rating);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(prefix + 'combo' + suffix, lib));
		comboSpr.scrollFactor.set(0, 0);
		comboSpr.cameras = [camHUD];
		if (!isSchool)
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.55));
			comboSpr.antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.65));
			comboSpr.antialiasing = false;
		}
		comboSpr.updateHitbox();
		comboSpr.x = (FlxG.width * 0.507) - 65 + 10;
		comboSpr.y = (FlxG.height * 0.44);
		comboSpr.acceleration.y = 550;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.visible = !FlxG.save.data.hideHUD;

		// Only show combo sprite when your combo hits 0.
		if (combo == 0) 
		{
			insert(strumLineIndex, comboSpr);
		}
		else 
		{
			comboSpr.kill();
		}

		if (combo > highestCombo) highestCombo = combo;

		// Split combo into 3 digits: hundreds, tens, ones.
		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;
		while (tempCombo != 0)
		{
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}

		while (seperatedScore.length < 3) seperatedScore.push(0);

		// Create each digit of the combo.
		var daLoop:Int = 1;
		for (digit in seperatedScore) 
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(prefix + 'num' + digit + suffix, lib));
			numScore.scrollFactor.set(0, 0);
			numScore.cameras = [camHUD];
			if (!isSchool) 
			{
				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.45));
			} 
			else 
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * 0.8));
				numScore.antialiasing = false;
			}
			numScore.updateHitbox();
			numScore.x = (FlxG.width * 0.507) - (36 * daLoop) - 65;
			numScore.y = (FlxG.height * 0.44);
			numScore.acceleration.y = FlxG.random.int(250, 300);
			numScore.velocity.y -= FlxG.random.int(130, 150);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !FlxG.save.data.hideHUD;
			if (combo >= 10 || combo == 0)
			{
				insert(strumLineIndex, numScore);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, 
			{
				onComplete: function(_) { numScore.kill(); },
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		// Fade out ratng + combo
		FlxTween.tween(rating, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001});
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, 
		{
			onComplete: function(_) 
			{
				comboSpr.kill();
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection++;
	}

	/**
	 * Snaps the camera follow point to the active character's midpoint.
	 * Called every 4 beats when the section changes,
	 */
	private function cameraMovement():Void 
	{
		// Opponent side
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide) 
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			// Per-character camera offsets
			switch (dad.currentCharacter) 
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.currentCharacter == 'mom') vocals.volume = 1;
			if (SONG.song.toLowerCase() == 'tutorial') tweenCamIn();
		}

		// Player side
		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100) 
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			// Per-stage camera offsets
			switch (curStage) 
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	/**
	 * Tweens the camera zoom inward (used during Tutorial).
	 */
	public static function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	//
	// KEYBOARD INPUTS
	//

	/**
	 * Processes player key input each frame.
	 * 
	 * Handles: sustain holding, note press deduplication, ghost tapping penalty,
	 * BF idle-return timer, and strum arrow visual state.
	 */
	private function keyShit():Void 
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// Botplay disables all real input arrays.
		if (botplay)
		{
			controlArray = [false, false, false, false];
			holdingArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		// Sustain holding
		if (holdingArray.contains(true) && generatedMusic) 
		{
			notes.forEachAlive(function(daNote:Note) 
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
				{
					goodNoteHit(daNote);
				}
			});
		}

		// Press: find the best hittable note per direction.
		if (controlArray.contains(true) && generatedMusic)
		{
			var possibleNotes:Array<Note> = []; // Notes that can be hit
			var ignoreList:Array<Int> = []; // Directions that can be hit
			var removeList:Array<Note> = []; // notes to kill later
				
			boyfriend.holdTimer = 0;

			notes.forEachAlive(function(daNote:Note) 
			{
				// Skip notes that can't be hit
				if (!daNote.canBeHit || !daNote.mustPress || daNote.tooLate || daNote.wasGoodHit || daNote.isSustainNote) return;
				if (ignoreList.contains(daNote.noteData))
				{
					// This direction already has a note; pick the earlier note,
					// and ignore duplicates within 10ms.
					for (possibleNote in possibleNotes)
					{
						if (possibleNote.noteData == daNote.noteData) 
						{
							// Near-identical time: queue the duplicate for removal
							if (Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)  removeList.push(daNote);
							else if (daNote.strumTime < possibleNote.strumTime) 
							{
								// Earlier note wins
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
				}
				else
				{
					possibleNotes.push(daNote);
					ignoreList.push(daNote.noteData);
				}
			});
		
			// Remove stacked duplicates.
			for (badNote in removeList) 
			{
				FlxG.log.add("killing dumb ass note at " + badNote.strumTime);
				notes.remove(badNote, true);
    		badNote.recycle();
			}
		
			// Sort by time so earlier notes are hit first.
			possibleNotes.sort(function(note1:Note, note2:Note) { return Std.int(note1.strumTime - note2.strumTime); });

			if (possibleNotes.length > 0) 
			{
				for (possibleNote in possibleNotes) 
				{
					if (controlArray[possibleNote.noteData]) goodNoteHit(possibleNote);
				}
			} 
			else if (!FlxG.save.data.ghostTapping)
			{
				// No hittable notes; penalize if ghost tapping was disabled.
				for (index in 0...controlArray.length)
				{
					if (controlArray[index]) comboBreak(index);
				}
			}
		}

		// Boyfriend returning to idle after holding pose for 4+ steps.
		// TODO: find a better way to handle boyfriend idle-return for BOTH intstances.
		if (botplay)
		{
			// Botplay: return to idle after 4+ steps of holding with no input.
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4.1 * 0.001 && !holdingArray.contains(true))
			{
				final anim = boyfriend.animation.curAnim;
				if (anim.name.startsWith('sing') 
					&& !anim.name.endsWith('-loop') 
					&& !anim.name.endsWith('miss') 
					&& (anim.curFrame >= 10 || anim.finished)) 
				{
					boyfriend.playAnim('idle', true);
				}
			}
		}
		else
		{
			// Manual: return to idle once the player releases all keys.
			if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet
				&& !holdingArray.contains(true)
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')) 
			{
				boyfriend.playAnim('idle');
			}
		}

		// Player Strums - arrow visual state
		playerStrums.forEach(function(spr:FlxSprite) 
		{
			if (!botplay)
			{
				if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdingArray[spr.ID])
					spr.animation.play('static');
			}
			else
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.finished) spr.animation.play('static', true);
				});
			}

			// Offset confirm animations to account for the larger sprite frame.
			if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school')) spr.centerOffsets();
			else 
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});

		// Opponent strum arrow offset
		opponentStrums.forEach(function(spr:FlxSprite) 
		{
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) 
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} 
			else spr.centerOffsets();
		});
	}

	//
	// MISS / HIT DIRECTION
	//

	/**
	 * Called when the player misses a note (pressed wrong direction or note passed).
	 * Resets combo, takes health/score, and plays miss anim with a sound.
	 * @param direction The note column (0=Left, 1=Down, 2=Up, 3=Right).
	 */
	function comboBreak(direction:Int = 1):Void 
	{
		if (boyfriend.stunned) return;

		// GF reacts after a 10+ combo is broken.
		// Force GF to stay in her pose for a few instances.
		if (gf != null)
		{
			if (combo > 10 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.holdTimer = 0;
			}
		}

		if (combo != 0) 
		{
			combo = 0;
			popUpScore(null); // force a SHIT pop-up
		}

		health -= 0.04;
		songScore -= 10;
		vocals.volume = 0;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		boyfriend.stunned = true;
		new FlxTimer().start(5 / 60, function(_) 
		{
			boyfriend.stunned = false;
		});

		switch (direction) 
		{
			case 0: boyfriend.playAnim('singLEFTmiss', true);
			case 1: boyfriend.playAnim('singDOWNmiss', true);
			case 2: boyfriend.playAnim('singUPmiss', true);
			case 3: boyfriend.playAnim('singRIGHTmiss', true);
		}

		if (instaKill)
		{
			vocals.volume = 0;
			health = 0;
		}

		if (!practiceMode && !botplay) 
		{
			songScore -= 10;
			misses++;
			updateAccuracy();
			updateStatistic();
		}
	}

	/**
	 * Called when the player (or botplay) successfully hits a note.
	 * Increases combo, grants health, plays sing animation and confirm arrow anim.
	 */
	function goodNoteHit(note:Note):Void 
	{
		if (note.wasGoodHit) return;
		if (!note.isSustainNote)
		{
			combo += 1;
			if (combo > 9999) combo = 9999;
			popUpScore(note);
		}
		else totalRatingsHit += 1; // don't count good hits for sustain notes

		// Health gain (regular notes give more than zero-data notes).
		// Sustain trails give a tad more health.
		health += 0.020 * (note.isSustainNote ? 0.25 : 1);

		// GF cheers at combo milestones.
		// Force GF to stay in her pose for a few instances.
		if (gf != null)
		{
			if (combo == 50 && gf.animOffsets.exists('cheer'))
			{
				gf.playAnim('cheer');
				gf.holdTimer = 0;
			}
		}

		// If a sustain trail exists, only play the sing animation once.
		if (!note.isSustainNote)
		{
			switch (note.noteData) 
			{
				case 0: boyfriend.playAnim('singLEFT', true);
				case 1: boyfriend.playAnim('singDOWN', true);
				case 2: boyfriend.playAnim('singUP', true);
				case 3: boyfriend.playAnim('singRIGHT', true);
			}
		}

		playerStrums.forEach(function(spr:FlxSprite) 
		{
			if (Math.abs(note.noteData) == spr.ID)
			{
				spr.animation.play('confirm', true);
			}
		});

		if (FlxG.save.data.hitsoundVolume > 0 && !note.isSustainNote)
		{
			// Calculate the time until the note should be hit.
      // Clamp it afterwards so we never schedule in the past, or too far ahead.
			var msUntilHit = note.strumTime - Conductor.songPosition;
			var waitTime:Float = Math.max(0, msUntilHit) / 1000.0;

			// Give a minor delay before playing the note hitsound to prevent audio lag.
			new FlxTimer().start(waitTime, function(_)
			{
				var hitNoteSound:Null<FlxSound> = FlxG.sound.play(
					Paths.sound('hitsound', 'preload'), 
					FlxG.save.data.hitsoundVolume / 100.0
				);
				
				if (hitNoteSound != null) hitNoteSound.volume = FlxG.save.data.hitsoundVolume / 100.0; 
			});
		}

		// Remove head notes (sustains stay until they scroll off).
		if (!note.isSustainNote) 
		{
			notes.remove(note, true);
			note.recycle();
		}
		else
		{
			note.wasGoodHit = true;
		}

		updateAccuracy();

		if (!botplay || !practiceMode)
		{
			updateStatistic();
		}
	}

	//
	// STATISTICS
	//

	function updateStatistic() 
	{
		judgementCounter.text = [
			'Sick: ${sicks}',
			'Good: ${goods}',
			'Bad: ${bads}',
			'Shit: ${shits}',
			'Combo Breaks: ${comboBreaks}',
			'Max Combo: ${highestCombo}'
		].join('\n');
	}

	/**
	 * Recalculates accuracy from running totals and marks `updatedAcc`.
	 */
	function updateAccuracy() 
	{
		updatedAcc = true;
		totalRatings += 1;
		accuracy = Math.max(0, totalRatingsHit / totalRatings * 100);
		accuracyDefault = Math.max(0, totalRatingsHitDefault / totalRatings * 100);
	}

	/**
	 * Truncates a float to a given number of decimal places without rounding artifacts.
	 * 
	 * @param number 
	 * @param precision 
	 * @return `truncateFloat`
	 */
	public static function truncateFloat(number:Float, precision:Int):Float 
	{
		var factor:Float = Math.pow(10, precision);
		return Math.round(number * factor) / factor;
	}

	//
	// CACHING UTILS
	//

	/**
	 * Generic asset cache helper.
	 *
	 * @param target  Asset name (without path prefix).
	 * @param type One of 'image', 'sound', 'music'.
	 * @param library Optional library folder (e.g. 'week7').
	 */
	public static function caching(target:String, type:String, ?library:String = null)
	{
		switch (type)
		{
			case 'image': Paths.image(target, library);
			case 'sound': Paths.sound(target, library);
			case 'music': Paths.music(target, library);
		}
	}

	/**
	 * Pre caches all assets needed during gameplay for this song/stage.
	 */
	function cacheArea() 
	{
		Paths.clearUnusedMemory();
		cachePopUpScore();
		cacheCountdown();

		for (i in 1...4) caching('missnote', 'sound', 'shared');

		#if !cpp
		caching('breakfast', 'music', 'shared');
		#end
		caching('alphabet', 'image', null);
	}

	//
	// STAGE EVENTS (beatHit / stepHit driven)
	//

	function lightningStrikeShit():Void 
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'week2'));

		if (!FlxG.save.data.lowQuality)
		{
			halloweenBG.animation.play('halloweem bg lightning strike');
		}
		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.currentCharacter.startsWith('bf')) 
			boyfriend.playAnim('scared', true);
		if (gf != null)
			gf.playAnim('scared', true);

		if (FlxG.save.data.cameraZooms) 
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			// Tween back only if the normal beat-zoom isn't already running
			if (!camZooming) 
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if (!FlxG.save.data.flashingLights) 
		{
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	//
	// WEEK 3 STAGE EVENTS
	// Train logic
	//

	function trainStart():Void 
	{
		trainMoving = true;
		trainSound.play(true);
	}

	function updateTrainPos():Void 
	{
		if (trainSound.time >= 4700) 
		{
			startedMoving = true;

			if (gf != null) gf.playAnim('hairBlow');
			if (FlxG.save.data.cameraZooms)
			{
				camera.shake(0.002, 0.1, null, true, X);
				camHUD.shake(0.002, 0.1, null, true, X);
			}
		}

		if (startedMoving) 
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing) 
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0) trainFinishing = true;
			}
			if (phillyTrain.x < -4000 && trainFinishing) trainReset();
		}
	}

	function trainReset():Void 
	{
		if (gf != null)
		{
			gf.dance();
			gf.playAnim('hairFall');
		}

		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	//
	// WEEK 4 STAGE EVENTS
	// Fast Car logic
	//

	function resetFastCar():Void 
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'week4'), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;

		new FlxTimer().start(2, function(tmr:FlxTimer) 
		{
			resetFastCar();
		});
	}

	//
	// WEEK 5 STAGE EVENTS
	// Tank logic
	//

	function moveTank():Void
	{
		if (!inCutscene) 
		{
			var daAngleOffset:Float = 1;
			tankAngle += FlxG.elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
	
			tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
			tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
		}
	}
	
	//
	// BEAT / STEP HOOKS
	//

	override function stepHit() 
	{
		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();
	}

	override function beatHit() 
	{
		super.beatHit();

		// Sort active notes by descending strum time so earlier notes drow on top.
		if (generatedMusic) 
		{
			notes.members.sort(function(Obj1:Note, Obj2:Note) 
			{
				return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null) 
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM) 
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		wiggleShit.update(Conductor.crochet);

		// Camera zoom pulse (every 4 beats)
		if (FlxG.save.data.cameraZooms) 
		{
			// MILF has an intense zoom section between beats 168–200
			if (curSong.toLowerCase() == 'milf' 
				&& curBeat >= 168 && curBeat < 200 
				&& camZooming && FlxG.camera.zoom < 1.35) 
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) 
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		// Icons scale up a tad bit.
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		// Force characters to their dance poses.
		if (curBeat % gfSpeed == 0)
		{
			if (gf != null) gf.dance();
		}

		if (curBeat % 2 == 0) 
		{
			if (boyfriend != null)
			{
				if (!boyfriend.animation.curAnim.name.startsWith("sing"))
					boyfriend.playAnim('idle');
			}

			if (dad != null)
			{
				if (!dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();
			}
		}
		else if (dad.currentCharacter == 'spookyKids')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		callOnEvents();
	}

	/**
	 * Handles all song-specific and stage-specific beat events.
	 * Includes GF cheer timings, BF hey animations, train/car/lightning triggers, etc.
	 * 
	 * [!NOTE] This is subject to change!
	 */
	function callOnEvents()
	{
		// Song specific events
		switch(SONG.song.toLowerCase()) 
		{ 
			case "tutorial":
				if (dad.currentCharacter == 'gf') 
				{
					if (curBeat % 16 == 15 && curBeat > 16 && curBeat < 48) 
					{
						dad.playAnim('cheer', true);
						if (boyfriend.currentCharacter.startsWith('bf'))
							boyfriend.playAnim('hey!', true);
					}
				}
			case "bopeebo":
				if (curBeat % 8 == 7) 
				{
					gf.playAnim('cheer');
					if (boyfriend.currentCharacter.startsWith('bf'))
						boyfriend.playAnim('hey!', true);
				}
			case "spookeez":
				if (curBeat == 47 || curBeat == 111)
				{
					if (boyfriend.currentCharacter.startsWith('bf'))
						boyfriend.playAnim('hey!', true);
				}
			case "philly":
				if (curBeat < 250) 
				{
					if (curBeat != 184 && curBeat != 216 && curBeat % 16 == 8) 
					{
						if (boyfriend.currentCharacter.startsWith('bf'))
							boyfriend.playAnim('hey!', true);
					}
				}
			case "blammed":
				if (curBeat > 30 && curBeat < 190 && (curBeat < 90 || curBeat > 128) && curBeat % 4 == 2) 
				{
					gf.playAnim('cheer', true);
				}
			case 'cocoa':
				if ((curBeat < 65 || (curBeat > 130 && curBeat < 145)) && curBeat % 16 == 15)
				{
					gf.playAnim('cheer', true);
				}
			case 'eggnog':
				if (curBeat > 10 && curBeat != 111 && curBeat < 220 && curBeat % 8 == 7) 
				{
					gf.playAnim('cheer', true);
				}	
		}

		switch (curStage) 
		{
			case 'spookyMansion':
				if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
				{
					lightningStrikeShit();
				}
			case "philly":
				if (!trainMoving) trainCooldown += 1;

				if (curBeat % 4 == 0) 
				{
					// Cycle Philly window light color.
					lightFadeShader.reset();

					phillyWindow.forEach(function(light:BGSprite) {
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) 
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'limo':
				if (!FlxG.save.data.lowQuality)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer) 
					{
						if (dancer != null) dancer.dance();
					});
				}
				if (FlxG.random.bool(10) && fastCarCanDrive) fastCarDrive();
			case 'mall':
				if (!FlxG.save.data.lowQuality) upperBoppers.dance(true);
				bottomBoppers.dance(true);
				santa.dance(true);
			case 'school':
				if (bgGirls != null) bgGirls.dance();
			case 'tank':
				if (!FlxG.save.data.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite) 
				{
					spr.dance();
				});
		}
	}
}
