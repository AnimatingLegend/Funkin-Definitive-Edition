package;

import animate.FlxAnimate;
import haxe.macro.Expr.Case;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import shaderslmao.BuildingShaders.BuildingShader;
import shaderslmao.BuildingShaders;
import shaderslmao.ColorSwap;
import Conductor.Ratings;
import TankCutscene.CutsceneCharacter;
import Boyfriend.Pico;

#if discord_rpc
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState 
{
	public static var curStage:String = '';
	public static var stageCheck:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var seenCutscene:Bool = false;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public var ratingFC:String;

	public var noteData:Int = 0;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var pico:Pico;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var opponentStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	
	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;
	public var timerText:FlxText;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	public var endingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var halloweenLevel:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var lightFadeShader:BuildingShaders;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var judgementCounter:FlxText;
	var songName:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	// Ratings shit
	public static var sicks:Int = 0;
	public static var goods:Int = 0;
	public static var bads:Int = 0;
	public static var shits:Int = 0;
	public static var misses:Int= 0;

	// Accuracy shit
	public static var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalRatingsHit:Float = 0;
	private var totalRatingsHitDefault:Float = 0;
	private var totalRatings:Int = 0;
	private var totalPlayed:Int = 0;

	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create() {
		Paths.clearStoredMemory();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		sicks = 0;
		goods = 0;
		bads = 0;
		shits = 0;

		misses = 0;
		accuracy = 0.00;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash0);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase()) {
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				if (FlxG.save.data.explicitContent)
					dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogueCensored'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if discord_rpc
		initDiscord();
		#end

		if (SONG.stage == null || SONG.stage.length < 1) 
		{
			switch (storyWeek) 
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.song.toLowerCase() == 'winter-horrorland') {
						stageCheck = 'mallEvil';
					} else {
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.song.toLowerCase() == 'thorns') {
						stageCheck = 'schoolEvil';
					} else {
						stageCheck = 'school';
					}
				case 7:
					stageCheck = 'tank';
				default:
					stageCheck = 'stage';
			}
		} else {
			SONG.stage = stageCheck;
			trace("CUR STAGE " + stageCheck);
		}

		switch (stageCheck) 
		{
			case 'stage': // Week 1
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/stageback', 'shared'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stage/stagefront', 'shared'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					if (FlxG.save.data.lowData) 
					{
						var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage/stage_light', 'shared'));
						stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						stageLight.antialiasing = FlxG.save.data.antialiasing;
						stageLight.updateHitbox();
						add(stageLight);

						var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage/stage_light', 'shared'));
						stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						stageLight.antialiasing = FlxG.save.data.antialiasing;
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stage/stagecurtains', 'shared'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
						add(stageCurtains);
					}
				}
			case 'halloween': // Week 2
				{
					curStage = 'spooky';
					halloweenLevel = true;
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'philly': // Week 3
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = FlxG.save.data.antialiasing;
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					city.antialiasing = FlxG.save.data.antialiasing;
					add(city);

					lightFadeShader = new BuildingShaders();
					phillyCityLights = new FlxTypedGroup<FlxSprite>();

					if (FlxG.save.data.lowData)
						add(phillyCityLights);

					for (i in 0...5) 
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						light.shader = lightFadeShader.shader;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					streetBehind.antialiasing = FlxG.save.data.antialiasing;
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					phillyTrain.antialiasing = FlxG.save.data.antialiasing;
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					street.antialiasing = FlxG.save.data.antialiasing;
					add(street);
				}
			case 'limo': // Week 4
				{
					curStage = 'limo';
					defaultCamZoom = 0.9;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					add(bgLimo);

					if (FlxG.save.data.lowData)
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);
		
						for (i in 0...5) {
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}
					}
						
					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');
					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;
				}
			case 'mall': // Week 5 - Cocoa, Eggnog
				{
					curStage = 'mall';

					defaultCamZoom = 0.8;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.lowData)
						add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.lowData)
						add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					if (FlxG.save.data.lowData)
						add(santa);
				}
			case 'mallEvil': // Week 5 - Winter Horrorland
				{
					curStage = 'mallEvil';

					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					add(evilSnow);
				}
			case 'school': // Week 6 - Senpai, Roses
				{
					curStage = 'school';

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var widShit = Std.int(bgSky.width * 6);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);


					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					if (FlxG.save.data.lowData)
					{
						var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						treeLeaves.setGraphicSize(widShit);
						treeLeaves.updateHitbox();
						add(treeLeaves);
					}

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));

					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();


					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.lowData)
						add(bgGirls);

					if (SONG.song.toLowerCase() == 'roses') 
					{
						if (FlxG.save.data.lowData)
							bgGirls.getScared();
					}
				}
			case 'schoolEvil': // Week 6 - Thorns
				{
					defaultCamZoom = 0.9;

					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.85, 0.85);
					bg.scale.set(7, 7);
					add(bg);
				}
			case 'tank': // Week 7 -  Ugh, Guns, Stress
				{
					defaultCamZoom = 0.9;

					curStage = 'tank';

					// im only using BGSprite for this stage and this stage only. too lazy to use/change it for the other stages.
					var sky:BGSprite = new BGSprite('tank/tankSky', -400, -400, 0, 0);
					add(sky);

					if (FlxG.save.data.lowData)
					{
						var clouds:BGSprite = new BGSprite('tank/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
						clouds.active = true;
						clouds.velocity.x = FlxG.random.float(5, 15);
						add(clouds);
	
						var mountains:BGSprite = new BGSprite('tank/tankMountains', -300, -20, 0.2, 0.2);
						mountains.setGraphicSize(Std.int(mountains.width * 1.2));
						mountains.updateHitbox();
						add(mountains);
	
						var buildings:BGSprite = new BGSprite('tank/tankBuildings', -200, 0, 0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						add(buildings);
					}

					var ruins:BGSprite = new BGSprite('tank/tankRuins', -200, 0, 0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					add(ruins);

					if (FlxG.save.data.lowData)
					{
						var smokeL:BGSprite = new BGSprite('tank/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
						add(smokeL);
	
						var smokeR:BGSprite = new BGSprite('tank/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
						add(smokeR);
	
						tankWatchtower = new BGSprite('tank/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
						add(tankWatchtower);
					}

					tankGround = new BGSprite('tank/tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
					add(tankGround);

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);

					var ground:BGSprite = new BGSprite('tank/tankGround', -420, -150);
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.updateHitbox();
					add(ground);
					moveTank();

					foregroundSprites = new FlxTypedGroup<BGSprite>();
					foregroundSprites.add(new BGSprite('tank/tank0', -500, 650, 1.7, 1.5, ['fg']));
					if (FlxG.save.data.lowData)
						foregroundSprites.add(new BGSprite('tank/tank1', -300, 750, 2, 0.2, ['fg']));
					foregroundSprites.add(new BGSprite('tank/tank2', 450, 940, 1.5, 1.5, ['foreground']));
					if (FlxG.save.data.lowData)
						foregroundSprites.add(new BGSprite('tank/tank4', 1300, 900, 1.5, 1.5, ['fg']));
					foregroundSprites.add(new BGSprite('tank/tank5', 1620, 700, 1.5, 1.5, ['fg']));
					if (FlxG.save.data.lowData)
						foregroundSprites.add(new BGSprite('tank/tank3', 1300, 1200, 3.5, 2.5, ['fg']));
				}
		}

		var gfVersion:String = 'gf';
		switch (curStage) {
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (gfVersion) {
			case 'pico-speaker':
				gf.x -= 50;
				gf.y -= 200;

				if (FlxG.save.data.lowData)
				{
					var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
					tempTankman.strumTime = 10;
					tempTankman.resetShit(20, 600, true);
					tankmanRun.add(tempTankman);
	
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

		dad = new Character(100, 100, SONG.player2);

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2) {
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode) {
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 180;
			case 'bf-pixel-opponent':
				dad.x -= 80;
				dad.y += 460;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		pico = new Pico(100, 100, SONG.player1);

		if (boyfriend.curCharacter.startsWith('pico-player')) {
			camPos.x += 600;
		}

		// REPOSITIONING PER STAGE
		switch (curStage) {
			case 'spooky':
				pico.x += 100;
				pico.y -= 60;

			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;

			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;

				if (gfVersion != 'pico-speaker') {
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxGroup();
		add(gfCutsceneLayer);

		bfTankCutsceneLayer = new FlxGroup();
		add(bfTankCutsceneLayer);

		// Week 4 shit
		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		// Week 7 shit
		if (curStage == 'tank')
			add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.cameras = [camHUD];
		laneunderlayOpponent.alpha = FlxG.save.data.laneUnderlay;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.cameras = [camHUD];
		laneunderlay.alpha = FlxG.save.data.laneUnderlay;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
		if (FlxG.save.data.middlescroll) {
			add(laneunderlay);
		} else {
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		opponentStrums = new FlxTypedGroup<FlxSprite>();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 150;

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		#if desktop
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / FlxG.save.data.framerateDraw));
		#else
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		#end

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (FlxG.save.data.downscroll) 
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 
		'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		add(healthBar);

		healthBar.createFilledBar(dad.barColor, boyfriend.barColor);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.20;
		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}\nSussy';
		if (FlxG.save.data.judgementCounter) {
			add(judgementCounter);
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		if (isStoryMode)
			doof.cameras = [camHUD];

		startingSong = true;

		if (isStoryMode && !seenCutscene) {
			seenCutscene = true;
			switch (curSong.toLowerCase()) {
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					camHUD.visible = false;
					cameraMovement();

					new FlxTimer().start(0.1, function(tmr:FlxTimer) 
					{
						FlxTween.tween(whiteScreen, {alpha: 0}, 1, 
						{
							startDelay: 0.1,
							ease: FlxEase.linear,
						});

						FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
						if (gf != null) gf.playAnim('scared', true);
						boyfriend.playAnim('scared', true);
						
						if (boyfriend.curCharacter.startsWith('pico-player')) {
							pico.playAnim('idle', true);
						}


						new FlxTimer().start(0.6, function(tmr:FlxTimer) 
						{
							remove(whiteScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, 
							{
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) 
								{
									startCountdown();
									camHUD.visible = true;
								}
							});
						});
					});

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer) {
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									startCountdown();
									camHUD.visible = true;
								}
							});
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(SONG.song == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'ugh' | 'guns' | 'stress':
					tankIntro();
				default:
					startCountdown();
			}
		} else {
			switch (curSong.toLowerCase()) {
				default:
					startCountdown();
			}
		}

		Paths.clearUnusedMemory();

		super.create();
	}

	// Week 6 Cutscene bullshit
	function schoolIntro(?dialogueBox:DialogueBox):Void 
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns') 
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns') 
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer) 
		{
			black.alpha -= 0.15;

			if (black.alpha > 0) 
			{
				tmr.reset(0.3);
			} 
			else 
			{
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
							if (senpaiEvil.alpha < 1) 
							{
								swagTimer.reset();
							}
							else 
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() 
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() 
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer) 
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					} 
					else 
					{
						add(dialogueBox);
					}
				} 
				else
					startCountdown();

				remove(black);
			}
		});
	}

	public var tankIntroEnd:Bool = false;
	function tankIntro():Void
	{
		dad.visible = false;
		caching('DISTORTO', 'music', 'week7');
		caching('cutscenes/', 'image', 'week7');

		var tankManEnd:Void->Void = function()
		{
			tankIntroEnd = true;
			cameraMovement();
			startCountdown();
			
			var timeForStuff:Float = Conductor.crochet / 1000 * 5;
			Paths.clearUnusedMemory();
			camHUD.visible = true;
			FlxG.sound.music.stop();

			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			dad.visible = true;
			gf.dance();
		}

		switch (SONG.song.toLowerCase()) 
		{
			case 'ugh':
				inCutscene = true;
				camHUD.visible = false;
				caching('wellWellWell', 'sound', 'week7');
				caching('killYou', 'sound', 'week7');
				caching('bfBeep', 'sound', 'week7');

				FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'));
				FlxG.sound.music.fadeIn(5, 0, 0.5);

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell', 'week7'));
				FlxG.sound.list.add(wellWellWell);
		
				dad.visible = false;
				var tankCutscene:TankCutscene = new TankCutscene(-20, 320);
				tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong1');
				tankCutscene.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankCutscene.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankCutscene.animation.play('wellWell');
				tankCutscene.antialiasing = FlxG.save.data.antialiasing;
				gfCutsceneLayer.add(tankCutscene);

				FlxG.camera.zoom *= 1.2;
				camFollow.x = 436.5;
				camFollow.y = 534.5;
		
				// Well well well, what do we got here?
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					camFollow.x += 700;
					camFollow.y += 90;
					
					// Beep!
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP', true);
						FlxG.sound.play(Paths.sound('bfBeep'), function()
						{
							boyfriend.playAnim('idle', false);
						});
					});

					// Move camera to Tankman
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						camFollow.x = 436.5;
						camFollow.y = 534.5;
						boyfriend.dance();
						tankCutscene.animation.play('killYou');
						FlxG.sound.play(Paths.sound('killYou'));

						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						new FlxTimer().start(6.1, function(tmr:FlxTimer)
						{
							tankManEnd();
							gfCutsceneLayer.remove(tankCutscene);
						});
					});
				});
			
			case 'guns':
				inCutscene = true;

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxTween.tween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
						}
					});
				});

				FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0, false);
				FlxG.sound.music.fadeIn(5, 0, 0.5);

				camFollow.setPosition(camPos.x, camPos.y);
				caching('tankSong2', 'sound', 'week7');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2', 'week7'));
				FlxG.sound.list.add(tightBars);

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					tightBars.play(true);
				});

				camFollow.y += 100;
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 4, {ease: FlxEase.quadInOut});
		
				dad.visible = false;
				var tankCutscene:TankCutscene = new TankCutscene(20, 320);
				tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong2');
				tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 2', 24, false);
				tankCutscene.animation.play('tankyguy');
				tankCutscene.antialiasing = FlxG.save.data.antialiasing;
				gfCutsceneLayer.add(tankCutscene);
				boyfriend.animation.curAnim.finish();
		

				new FlxTimer().start(4.1, function(tmr:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});

					if (gf != null)
					{
						gf.playAnim('sad', true);
						gf.animation.finishCallback = function(name:String)
						{
							gf.playAnim('sad', true);
						};
					}
				});

				new FlxTimer().start(11.6, function(tmr:FlxTimer)
				{
					camFollow.x = 440;
					camFollow.y = 534.5;
					tankManEnd();

					if (gf != null)
					{
						gf.dance();
						gf.animation.finishCallback = null;
					}

					gfCutsceneLayer.remove(tankCutscene);
				});

			case 'stress': // "optimized" this to an extent, sorry to the ppl with toaster computers lol..
				inCutscene = true;
				caching('stressCutscene', 'sound', 'week7');
				caching('song3censor', 'sound', 'week7');

				dad.alpha = 0.0001;
				gf.alpha = 0.0001;

				var dummyGF:FlxSprite = new FlxSprite(210, 70);
				dummyGF.frames = Paths.getSparrowAtlas('characters/gfTankmen');
				dummyGF.animation.addByPrefix('loop', 'GF Dancing at Gunpoint', 24, true);
				dummyGF.animation.play('loop');
				dummyGF.antialiasing = FlxG.save.data.antialiasing;
				gfCutsceneLayer.add(dummyGF);

				boyfriend.visible = false;
				var dummyBF:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
				dummyBF.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				dummyBF.animation.addByPrefix('loop', 'BF idle dance', 24, false);
				dummyBF.animation.play('loop');
				dummyBF.antialiasing = FlxG.save.data.antialiasing;
				bfTankCutsceneLayer.add(dummyBF);
				
				var dummyLoaderShit:FlxGroup = new FlxGroup();
				add(dummyLoaderShit);
		
				for (i in 0...7)
				{
					var dummyLoader:FlxSprite = new FlxSprite();
					dummyLoader.loadGraphic(Paths.image('cutscenes/gfHoldup-' + i));
					dummyLoader.antialiasing = FlxG.save.data.antialiasing;
					dummyLoaderShit.add(dummyLoader);
					dummyLoader.alpha = 0.01;
					dummyLoader.y = FlxG.height - 20;
				}

				var bfCatchGf:FlxSprite = new FlxSprite(boyfriend.x - 10, boyfriend.y - 90);
				bfCatchGf.frames = Paths.getSparrowAtlas('cutscenes/bfCatchesGF');
				bfCatchGf.animation.addByPrefix('catch', 'BF catches GF', 24, false);
				bfCatchGf.antialiasing = FlxG.save.data.antialiasing;
				add(bfCatchGf);
				bfCatchGf.visible = false;

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxTween.tween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
						}
					});
				});

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					camFollow.x = 436.5;
					camFollow.y = 534.5;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				});

				var stressCutscene:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(stressCutscene);

				var stressCutsceneCensored:FlxSound = new FlxSound().loadEmbedded(Paths.sound('song3censor'));
				FlxG.sound.list.add(stressCutsceneCensored);

				dad.visible = false;
				var tankCutscene:TankCutscene = new TankCutscene(-70, 320);
				tankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong3-pt1');
				tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 3 P1 UNCUT', 24, false);
				tankCutscene.animation.play('tankyguy');
				tankCutscene.antialiasing = FlxG.save.data.antialiasing;
				bfTankCutsceneLayer.add(tankCutscene);

				var alsoTankCutscene:FlxSprite = new FlxSprite(20, 320);
				alsoTankCutscene.frames = Paths.getSparrowAtlas('cutscenes/tankTalkSong3-pt2');
				alsoTankCutscene.animation.addByPrefix('swagTank', 'TANK TALK 3 P2 UNCUT', 24, false);
				alsoTankCutscene.antialiasing = FlxG.save.data.antialiasing;
				bfTankCutsceneLayer.add(alsoTankCutscene);
				alsoTankCutscene.y = FlxG.height + 100;
				alsoTankCutscene.visible = false;

				new FlxTimer().start(0.01, function(tmr:FlxTimer) // fixes audio syncing
				{
					if (FlxG.save.data.explicitContent) {
						stressCutscene.play(true);
					} else {
						stressCutsceneCensored.play(true);

						var censor:FlxSprite = new FlxSprite();
						censor.frames = Paths.getSparrowAtlas('cutscenes/censor');
						censor.animation.addByPrefix('censor', 'mouth censor', 24);
						censor.antialiasing = FlxG.save.data.antialiasing;
						censor.animation.play('censor');
						add(censor);
						censor.visible = false;

						new FlxTimer().start(4.6, function(censorTimer:FlxTimer)
						{
							censor.visible = true;
							censor.setPosition(dad.x + 160, dad.y + 180);
		
							new FlxTimer().start(0.2, function(endThing:FlxTimer)
							{
								censor.visible = false;
							});
						});

						new FlxTimer().start(25.1, function(censorTimer:FlxTimer)
						{
							censor.visible = true;
							censor.setPosition(dad.x + 120, dad.y + 170);
		
							new FlxTimer().start(0.9, function(endThing:FlxTimer)
							{
								censor.visible = false;
							});
						});

						new FlxTimer().start(30.7, function(censorTimer:FlxTimer)
						{
							censor.visible = true;
							censor.setPosition(dad.x + 210, dad.y + 190);
		
							new FlxTimer().start(0.4, function(endThing:FlxTimer)
							{
								censor.visible = false;
							});
						});

						new FlxTimer().start(33.8, function(censorTimer:FlxTimer)
						{
							censor.visible = true;
							censor.setPosition(dad.x + 180, dad.y + 170);
		
							new FlxTimer().start(0.6, function(endThing:FlxTimer)
							{
								censor.visible = false;
							});
						});
					}
				});

				new FlxTimer().start(15.1, function(tmr:FlxTimer)
				{
					camFollow.y -= 170;
					camFollow.x += 200;
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.3}, 2.1, {
						ease: FlxEase.quadInOut
					});
			
					new FlxTimer().start(2.2, function(swagTimer:FlxTimer)
					{
						FlxG.camera.zoom = 0.8;
						boyfriend.visible = false;

						bfCatchGf.visible = true;
						bfCatchGf.animation.play('catch');
			
						bfTankCutsceneLayer.remove(dummyBF);
						bfCatchGf.animation.finishCallback = function(anim:String)
						{
							bfCatchGf.visible = false;
							boyfriend.visible = true;
						};
			
						new FlxTimer().start(3, function(weedShitBaby:FlxTimer)
						{
							camFollow.y += 180;
							camFollow.x -= 80;
						});
			
						new FlxTimer().start(2.3, function(gayLol:FlxTimer)
						{
							bfTankCutsceneLayer.remove(tankCutscene);
							
							alsoTankCutscene.visible = true;
							alsoTankCutscene.y = 320;
							alsoTankCutscene.animation.play('swagTank');
						});
					});

					gf.visible = false;
					dad.visible = false;
					var cutsceneShit:CutsceneCharacter = new CutsceneCharacter(210, 70, 'gfHoldup');
					gfCutsceneLayer.add(cutsceneShit);
					gfCutsceneLayer.remove(dummyGF);

					cutsceneShit.onFinish = function()
					{
						gf.alpha = 1;
						gf.visible = true;
						dad.visible = true;
					};

					new FlxTimer().start(20, function(alsoTmr:FlxTimer)
					{
						tankManEnd();

						remove(dummyLoaderShit);
						dummyLoaderShit.destroy();
						dummyLoaderShit = null;

						gfCutsceneLayer.remove(cutsceneShit);
						bfTankCutsceneLayer.remove(alsoTankCutscene);

						dad.alpha = 1;
					});
				});

				new FlxTimer().start(31.2, function(tmr:FlxTimer)
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
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						camFollow.x -= 400;
						camFollow.y -= 150;
						FlxG.camera.zoom /= 1.4;
						FlxG.camera.focusOn(camFollow.getPosition());
					});
				});
		}

	}

	function initDiscord():Void
	{
		#if discord_rpc
		storyDifficultyText = CoolUtil.difficultyString();
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void 
	{
		inCutscene = false;
		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = opponentStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) 
		{
			if (swagCounter % gfSpeed == 0) {
				gf.dance();
			}

			if (swagCounter % 2 == 0) {
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle');

				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
			} 
			
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing')) {
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys()) {
				if (value == curStage) {
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter) {
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();
					go.cameras = [camHUD];
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;

		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public var bar:FlxSprite;

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void {
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData) {
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3) {
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress) {
						sustainNote.x += FlxG.width / 2; // general offset
					} else if (!swagNote.mustPress && FlxG.save.data.middlescroll) {
						sustainNote.alpha = 0; // general offset
					}

					if (sustainNote.mustPress && FlxG.save.data.middlescroll) {
						sustainNote.x += -270; // general offset
					}

					if (sustainNote.mustPress && !FlxG.save.data.middlescroll) {
						sustainNote.x += 40; // cuz yes
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else if (!swagNote.mustPress && FlxG.save.data.middlescroll) {
					swagNote.alpha = 0; // general offset
				}

				if (swagNote.mustPress && FlxG.save.data.middlescroll) {
					swagNote.x += -270; // general offset
				}

				if (swagNote.mustPress && !FlxG.save.data.middlescroll) {
					swagNote.x += 40; // cuz yes
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note) {
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage) {
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}	

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
	
				if (!FlxG.save.data.middlescroll || player != 0)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player) {
				case 0:
					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			if (!FlxG.save.data.middlescroll && player == 1) {
				babyArrow.x += 40;
			}

			if (FlxG.save.data.middlescroll && player == 1) {
				babyArrow.x -= 270;
			} else if (FlxG.save.data.middlescroll && player == 0) {
				babyArrow.x -= 2000;
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			opponentStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if discord_rpc
			if (startTimer != null && startTimer.finished) {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void {
		#if discord_rpc
		if (health > 0 && !paused) {
			if (Conductor.songPosition > 0.0) {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void {
		#if discord_rpc
		if (health > 0 && !paused) {
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	override public function update(elapsed:Float) {

		#if html5
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);
		#end

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE) {
			iconP1.swapOldIcon();
		}

		switch (curStage) {
			case 'philly':
				if (trainMoving) {
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

				lightFadeShader.update((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
			case 'tank':
				moveTank();
		}

		super.update(elapsed);

		if (FlxG.save.data.accuracy) {
			scoreTxt.text = "Score: "
				+ songScore
				+ ' | Misses: '
				+ 	misses
				+ ' | Accuracy: '
				+ '(${truncateFloat(accuracy, 2)}%)'
				+ ' - '
				+ ratingFC;
		} else {
			scoreTxt.text = "Score:" + songScore;
		}

		// Rating FC
		ratingFC = "N/A";
		if (sicks > 0)
			ratingFC = "MFC";
		if (goods > 0)
			ratingFC = "GFC";
		if (bads > 0 || shits > 0)
			ratingFC = "FC";
		if (misses > 0 && misses < 10)
			ratingFC = "SDCB";
		else if (misses >= 10)
			ratingFC = "Clear";

		if (controls.PAUSE && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1)) {
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			} else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(145, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(145, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		opponentStrums.forEach(function(spr:FlxSprite) {
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else
				spr.centerOffsets();
		});

		if (FlxG.keys.justPressed.EIGHT) {
			FlxG.switchState(new AnimationDebug(SONG.player2));

			#if discord_rpc
			DiscordClient.changePresence("Sprite Offset Editor", null, null, true);
			#end
		}	
		
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
			if (curBeat % 4 == 0) {
				cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
				cameraMovement();
			}
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

		if (curSong == 'Fresh') {
			switch (curBeat) {
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong == 'Bopeebo') {
			switch (curBeat) {
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET) {
			health = 0;
			trace("RESET = True");
		}

		if (health <= 0 && !practiceMode) {
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			deathCounter += 1;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if discord_rpc
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if ((FlxG.save.data.downscroll && daNote.y < -daNote.height) 
					|| (!FlxG.save.data.downscroll && daNote.y > FlxG.height)) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}
	
				var center = strumLine.y + (Note.swagWidth / 2);
				var speedValue:Float = 1;
	
				if (FlxG.save.data.scrollSpeed != 1) {
					speedValue = FlxG.save.data.scrollSpeed;
				} else if (FlxG.save.data.scrollSpeed == 1) {
					speedValue = SONG.speed;
				}
	
				// i am so fucking sorry for these if conditions
				if (FlxG.save.data.downscroll) {
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(speedValue, 2)));
	
					if (daNote.isSustainNote){
						if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;
	
						if ((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							// clipRect is applied to graphic itself so use frame Heights
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
	
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(speedValue, 2)));
	
					if (daNote.isSustainNote
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center)
					{
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);

						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}
	
				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
	
					if (SONG.notes[Math.floor(curStep / 16)] != null) {
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
	
					if (daNote.altNote)
						altAnim = '-alt';
	
					switch (Math.abs(daNote.noteData)) {
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					if (FlxG.save.data.glowStrums) {
						opponentStrums.forEach(function(spr:FlxSprite) {
							if (Math.abs(daNote.noteData) == spr.ID) {
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) {
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							} else
								spr.centerOffsets();
						});
					}
					
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit) {
					if ((FlxG.save.data.downscroll && daNote.y < -daNote.height) 
						|| (FlxG.save.data.downscroll && daNote.y > FlxG.height)) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				} else if (daNote.tooLate || daNote.wasGoodHit) {
					
					if (daNote.tooLate) {
						health -= 0.0475;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
	
				var missNote:Bool = daNote.y < -daNote.height;
				if (FlxG.save.data.downscroll) {
					missNote = daNote.y > FlxG.height;
				}

				if (missNote && daNote.mustPress) {
					if (daNote.tooLate || !daNote.wasGoodHit) {
						noteMiss(daNote.noteData);
						vocals.volume = 0;
					}
				}
			});
		}

		if (FlxG.save.data.glowStrums) {
			opponentStrums.forEach(function(spr:FlxSprite) {
				if (spr.animation.finished) {
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void {
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		
		if (SONG.validScore) {
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode) {
			campaignScore += songScore;
			campaignMisses += misses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore) {
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog') {
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function() {
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				} else {
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset;

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		if (FlxG.save.data.ratingHUD) 
		{
			coolText.x = FlxG.width * 0.35;
		} 
		else 
		{
			coolText.x = FlxG.width * 0.55;
		}
		coolText.screenCenter();

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

	  	var daRating = Ratings.judgeNote(noteDiff);
		var doSplash:Bool = false;

		switch (daRating) {
			case 'shit':
				score = -300;
				health -= 0.1;
				shits++;
				totalRatingsHit -= 1;
				doSplash = false;
				updateStatistic();

			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				bads++;
				totalRatingsHit += 0.50;
				doSplash = false;
				updateStatistic();

			case 'good':
				daRating = 'good';
				score = 200;
				goods++;
				totalRatingsHit += 0.75;
				doSplash = false;
				updateStatistic();

			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.notesplash)
					doSplash = true;
				sicks++;
				totalRatingsHit += 1;
				updateStatistic();
		}

		if (doSplash) {
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode)
			songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school')) {
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		if (FlxG.save.data.ratingHUD) 
		{
			rating.y -= 25;
			rating.screenCenter();
			rating.scrollFactor.set(0.7);

			var scaleX = rating.scale.x;
			var scaleY = rating.scale.y;

			rating.scale.scale(1.2);
		}
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x += FlxG.random.int(0, 10);
		add(rating);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		if (FlxG.save.data.ratingHUD) 
		{
			comboSpr.y += 90;
			comboSpr.screenCenter();
			comboSpr.scrollFactor.set(0.7);

			var scaleX = rating.scale.x;
			var scaleY = rating.scale.y;

			comboSpr.scale.scale(1.2);
		}
		comboSpr.screenCenter();
		comboSpr.x = coolText.x + 55;
		comboSpr.y += 50;
		comboSpr.acceleration.y = 550;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		if (!curStage.startsWith('school')) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = FlxG.save.data.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = FlxG.save.data.antialiasing;
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.75));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.75));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			if (FlxG.save.data.ratingHUD) 
			{
				numScore.y += 50;
				numScore.x -= 50;
				numScore.screenCenter();
				numScore.scrollFactor.set(0.7);

				var scaleX = numScore.scale.x;
				var scaleY = numScore.scale.y;
			}
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school')) {
				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			} else {
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			if (combo >= 10 || combo == 0)
				add(comboSpr);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				comboSpr.destroy();
				coolText.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function cameraMovement():Void {
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide) {
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter) {
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial') {
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100) {
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage) {
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial') {
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void {
		var holdingArray:Array<Bool> = [
			controls.NOTE_LEFT, 
			controls.NOTE_DOWN, 
			controls.NOTE_UP, 
			controls.NOTE_RIGHT
		];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];

		if (holdingArray.contains(true) && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (controlArray.contains(true) && generatedMusic) {
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = []; // Notes that can be hit
			var ignoreList:Array<Int> = []; // Directions that can be hit
			var removeList:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note) 
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) 
				{
					if (ignoreList.contains(daNote.noteData)) 
					{
						for (possibleNote in possibleNotes) 
						{
							if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime) 
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					} 
					else 
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList) {
				FlxG.log.add("killing dumb ass note at " + badNote.strumTime);
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note) {
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (perfectMode) {
				goodNoteHit(possibleNotes[0]);
			} else if (possibleNotes.length > 0) {
				for (i in 0...controlArray.length) {
					if (controlArray[i] && !ignoreList.contains(i)) {
						noteMiss(i);
					}
				}

				for (possibleNote in possibleNotes) {
					if (controlArray[possibleNote.noteData]) {
						goodNoteHit(possibleNote);
					}
				}
			} else { 
				// the better solution to all of our problems
				if (!FlxG.save.data.ghostTapping) {
					for (i in 0...controlArray.length) {
						if (controlArray[i]) {
							noteMiss(i);
							health -= 0.04;
						}
					}
				}
			}
		}

		if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet
			&& !holdingArray.contains(true)
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss')) {
			boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdingArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
				spr.centerOffsets();
			else {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	function noteMiss(direction:Int = 1):Void {
		if (!boyfriend.stunned) {
			health -= 0.04;
			if (combo > 10 && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad', true);
			}

			var pixelShitPart1:String = ""; // pixel prefixes
			var pixelShitPart2:String = '';
			var comboBreak:FlxSprite = new FlxSprite();

			if (curStage.startsWith('school')) {
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			if (!practiceMode)
				songScore -= 10;

			comboBreak.loadGraphic(Paths.image(pixelShitPart1 + 'comboBreak' + pixelShitPart2));
			comboBreak.screenCenter();
			if(FlxG.save.data.ratingHUD)
			{
				comboBreak.y -= 25;
				comboBreak.screenCenter();
				comboBreak.scrollFactor.set(0.7);

				var scaleX = comboBreak.scale.x;
				var scaleY = comboBreak.scale.y;

				comboBreak.scale.scale(1.2);
			}	
			comboBreak.screenCenter();
			comboBreak.x -= 40;
			comboBreak.y -= 60;
			comboBreak.acceleration.y = 550;
			comboBreak.velocity.y -= FlxG.random.int(140, 175);
			comboBreak.velocity.x += FlxG.random.int(0, 10);
		//	add(comboBreak);
	
			if (!curStage.startsWith('school')) {
				comboBreak.setGraphicSize(Std.int(comboBreak.width * 0.7));
				comboBreak.antialiasing = FlxG.save.data.lowData;
			} else {
				comboBreak.setGraphicSize(Std.int(comboBreak.width * daPixelZoom * 0.02));
			}

			if (combo > 10)
				add(comboBreak);

			FlxTween.tween(comboBreak, {alpha: 0.001}, 0.1, {
				startDelay: Conductor.crochet * 0.001
			});

			combo = 0;

			songScore -= 10;
			misses++;

			vocals.volume = 0;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				boyfriend.stunned = false;
			});

			switch (direction) {
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
			updateStatistic();
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				combo += 1;
				popUpScore(note.strumTime, note);
			} else
				totalRatingsHit += 1;

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData) {
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID) {
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			updateAccuracy();
		}
	}

	function updateStatistic() {
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}\nSussy';
	}

	function updateAccuracy() {
		totalRatings += 1;
		accuracy = Math.max(0, totalRatingsHit / totalRatings * 100);
		accuracyDefault = Math.max(0, totalRatingsHitDefault / totalRatings * 100);
	}

	public static function truncateFloat(number:Float, precision:Int):Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function caching(target:String, type:String, ?library:String = null)
	{
		switch (type)
		{
			case 'image':
				Paths.image(target, library);
			case 'sound':
				Paths.sound(target, library);
			case 'music':
				Paths.music(target, library);
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void {
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive() {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer) {
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

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

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void {
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void {
		if (trainSound.time >= 4700) {
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
			}
			camera.shake(0.002, 0.1, null, true, X);
		}

		if (startedMoving) {
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing) {
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void {
		if(gf != null)
		{
			gf.dance(); // Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;

		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.curCharacter.startsWith('pico-player')) {
			boyfriend.playAnim('idle', true);
		} else {
			if (boyfriend.curCharacter.startsWith('bf')) {
				boyfriend.playAnim('scared', true);
			}
		}

		gf.playAnim('scared', true);

		// taken from psych engine teehee
		if (FlxG.save.data.camhudZoom) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if (!camZooming) { // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note ~ Shadow Mario
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}
	}

	override function stepHit() {
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) {
			resyncVocals();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit() {
		super.beatHit();

		if (generatedMusic) {
			notes.members.sort(function(Obj1:Note, Obj2:Note) {
				return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM) {
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camhudZoom) {
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		// Dont mind this
		if (curBeat % gfSpeed == 0) {
			gf.dance();
		}

		if (curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing")) {
				boyfriend.playAnim('idle');
			}
	
			if (!dad.animation.curAnim.name.startsWith("sing")) {
				dad.dance();
			}
		}
		else if (dad.curCharacter == 'spooky') {
			if (!dad.animation.curAnim.name.startsWith("sing")) {
				dad.dance();
			}
		}

		switch(SONG.song.toLowerCase()) 
		{ 
			case "tutorial":
				if (dad.curCharacter == 'gf') 
				{
					if (curBeat % 16 == 15 && curBeat > 16 && curBeat < 48) 
					{
						dad.playAnim('cheer', true);

						if (boyfriend.curCharacter.startsWith('pico-player')) 
						{
							boyfriend.playAnim('idle', true);
						} 
						else 
						{
							if (boyfriend.curCharacter.startsWith('bf')) 
							{
								boyfriend.playAnim('hey', true);
							}
						}
					}
				}

			case "bopeebo":
				if (curBeat % 8 == 7) 
				{
					gf.playAnim('cheer');
		
					if (boyfriend.curCharacter.startsWith('pico-player'))
						boyfriend.playAnim('idle', true);
					else 
					{
						if (boyfriend.curCharacter.startsWith('bf')) 
						{
							boyfriend.playAnim('hey', true);
						}
					}
				}

			case "philly":
				if (curBeat < 250) 
				{
					if (curBeat != 184 && curBeat != 216) 
					{
						if (curBeat % 16 == 8) 
						{
							if (boyfriend.curCharacter.startsWith('pico-player')) 
							{
								boyfriend.playAnim('idle', true);
							} 
							else 
							{
								if (boyfriend.curCharacter.startsWith('bf')) {
									boyfriend.playAnim('hey', true);
								}
							}
						}
					}
				}

			case "blammed":
				if (curBeat > 30 && curBeat < 190) 
				{
					if (curBeat < 90 || curBeat > 128) 
					{
						if (curBeat % 4 == 2)
							gf.playAnim('cheer', true);
					}
				}
				
			case 'cocoa':
				if (curBeat < 65 || curBeat > 130 && curBeat < 145) 
				{
					if (curBeat % 16 == 15)
						gf.playAnim('cheer', true);
				}
	
			case 'eggnog':
				if (curBeat > 10 && curBeat != 111 && curBeat < 220) 
				{
					if (curBeat % 8 == 7)
						gf.playAnim('cheer', true);
				}	
		}

		switch (curStage) 
		{
			case 'tank':
				if (FlxG.save.data.lowData)
					tankWatchtower.dance();
				
				foregroundSprites.forEach(function(spr:BGSprite) {
					spr.dance();
				});

			case 'school':
				if (FlxG.save.data.lowData)
					bgGirls.dance();

			case 'mall':
				if (FlxG.save.data.lowData)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if (FlxG.save.data.lowData)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}

			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					lightFadeShader.reset();
					phillyCityLights.forEach(function(light:FlxSprite) {
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);
					phillyCityLights.members[curLight].visible = true;
				//	phillyCityLights.members[curLight].alpha = 0.5;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
