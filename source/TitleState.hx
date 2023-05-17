package;

import openfl.display.Sprite;
import openfl.net.NetStream;
import openfl.media.Video;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import shaderslmao.BuildingShaders.BuildingShader;
import shaderslmao.BuildingShaders;
import shaderslmao.ColorSwap;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
 
	var lastBeat:Int = 0;
	
	var swagShader:ColorSwap;
	var alphaShader:BuildingShaders;


	var returnedData:Array<String> = [];

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';
	public static var closedState:Bool = false;

	override public function create():Void
	{
		getBuildVer();
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();


		#if desktop
		FlxG.game.focusLostFramerate = 60;
		#end

		swagShader = new ColorSwap();
		alphaShader = new BuildingShaders();

		FlxG.sound.muteKeys = [ZERO];

		curWacky = FlxG.random.getObject(getIntroTextShit());
		
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();
		Main.setupSaveData();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		if (FlxG.save.data.seenVideo != null)
		{
			VideoState.seenVideo = FlxG.save.data.seenVideo;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		startIntro();
		#end
		#end

		#if Desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In TitleState.hx", null);
		#end

		#if desktop
		if(FlxG.save.data.framerateDraw != null)
		{
			FlxG.updateFramerate = FlxG.save.data.framerateDraw;
			FlxG.drawFramerate = FlxG.save.data.framerateDraw;
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = FlxG.save.data.lowData;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.shader = swagShader.shader;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.lowData;
		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.lowData;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = FlxG.save.data.lowData;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", false);
		credTextShit.screenCenter();
		credTextShit.visible = true;

		ngSpr = new FlxSprite(0, FlxG.height * 0.55).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = FlxG.save.data.lowData;
		add(ngSpr);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
			initialized = true;
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var isRainbow:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.onComplete = null;
			}

			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				if (mustUpdate)
					FlxG.switchState(new OutdatedSubState()); 
				else
					FlxG.switchState(new MainMenuState());

				closedState = true;
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function getBuildVer():Void
	{
		trace('checking for update');
		var http = new haxe.Http("https://raw.githubusercontent.com/AnimatingLegend/Funkin-Definitive-Edition/master/gitVersion.txt");

		http.onData = function (data:String)
		{
			updateVersion = data.split('\n')[0].trim();
			var curVersion:String = MainMenuState.definitiveVersion.trim();
			trace('version online: ' + updateVersion + ', your version: ' + curVersion);
			if(updateVersion != curVersion) {
				trace('versions arent matching!');
				mustUpdate = true;
			}
		}

		http.onError = function (error) {
			trace('error: $error');
		}

		http.request();
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200 + offset;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) {
			logoBl.animation.play('bump', true);
		}

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft) {
				gfDance.animation.play('danceRight');
			} else {
				gfDance.animation.play('danceLeft');
			}
		}

		if (curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1:
						createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
						// credTextShit.visible = true;
					case 3:
						addMoreText('present');
						// credTextShit.text += '\npresent...';
						// credTextShit.addText();
					case 4:
						deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = 'In association \nwith';
						// credTextShit.screenCenter();
					case 5:
						createCoolText(['In association', 'with']);
					case 7:
						addMoreText('newgrounds');
						ngSpr.visible = true;
						// credTextShit.text += '\nNewgrounds';
					case 8:
						deleteCoolText();
						ngSpr.visible = false;
						// credTextShit.visible = false;
				
						// credTextShit.text = 'Shoutouts Tom Fulp';
						// credTextShit.screenCenter();
					case 9:
						createCoolText([curWacky[0]]);
						// credTextShit.visible = true;
					case 11:
						addMoreText(curWacky[1]);
						// credTextShit.text += '\nlmao';
					case 12:
						deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = "Friday";
						// credTextShit.screenCenter();
					case 13:
						addMoreText('Friday');
						// credTextShit.visible = true;
					case 14:
						addMoreText('Night');
						// credTextShit.text += '\nNight';
					case 15:
						addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				
					case 16:
						skipIntro();
				}
			}
		}	
		lastBeat = curBeat;
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			
			if (FlxG.save.data.flashingLights) 
				FlxG.camera.flash(FlxColor.WHITE, 4);
			else
				FlxG.camera.flash(FlxColor.BLACK, 4);

			FlxG.sound.music.time = 9400; // if you skip the intro the song skips to 9.4 seconds

			skippedIntro = true;
		}
	}
}