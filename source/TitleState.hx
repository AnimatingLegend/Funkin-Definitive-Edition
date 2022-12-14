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

	var mustUpdate:Bool;

	var http = new haxe.Http("https://raw.githubusercontent.com/LegendLOL/Funkin-Definitive-Edition/master/gitVersion.txt");
	var returnedData:Array<String> = [];

	public static var updateVersion:String = '';
	public static var closedState:Bool = false;

	#if web
	var video:Video;
	var netStream:NetStream;
	var overlay:Sprite;
	#end

	override public function create():Void
	{
		getBuildVer();

		#if desktop
		FlxG.game.focusLostFramerate = 60;
		#end

		/*#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod'], framework: OPENFL});
		#end*/

		swagShader = new ColorSwap();

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
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end

		#if desktop
		if(FlxG.save.data.framerateDraw != null)
		{
			FlxG.updateFramerate = FlxG.save.data.framerateDraw;
			FlxG.drawFramerate = FlxG.save.data.framerateDraw;
		}
		#end
	}

	#if web
	function client_onMetaData(e)
	{
		video.attachNetStream(netStream);
		video.width = video.videoWidth;
		video.height = video.videoHeight;
	}

	function netStream_onAsyncError(e)
	{
		trace("Error loading video");
	}

	function netConnection_onNetStatus(e)
	{
		if (e.info.code == 'NetStream.Play.Complete')
		{
			startIntro();
		}
		trace(e.toString());
	}

	function overlay_onMouseDown(e)
	{
		netStream.soundTransform.volume = 0.2;
		netStream.soundTransform.pan = -1;
		Lib.current.stage.removeChild(overlay);
	}
	#end

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
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
		}

		Conductor.changeBPM(102);
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
			initialized = true;

		#if debug
		initialized = true;
		#end

		/*if (FlxG.sound.music != null)
		{
			FlxG.sound.music.onComplete = function()
			{
				FlxG.switchState(new VideoState());
			}
		}*/
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

		if (FlxG.keys.justPressed.F)
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
				if (MainMenuState.updateShit) 
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
		http.request();
	
		http.onData = function(data:String)
		{
			returnedData[0] = data.substring(0, data.indexOf(';'));
			returnedData[1] = data.substring(data.indexOf('-'), data.length);

			if (!MainMenuState.definitiveVersion.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
			{
				trace('New version detected: ' + returnedData[0]);
				MainMenuState.updateShit = true;
				trace('outdated lmao! ' + returnedData[0] + ' != ' + Application.current.meta.get('version'));
				OutdatedSubState.needVer = returnedData[0];
			}
			else
			{
				trace('Build is up to date !!! - ' + MainMenuState.definitiveVersion);
			}
		}
	
		http.onError = function(error)
		{
			trace('error: $error');
		}
	
		http.request();
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
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

		FlxG.log.add(curBeat);
	
		if (curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1:
						createCoolText(['ninjamuffin', 'phantomArcade', 'kawaisprite', 'evilsker']);
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
			if (FlxG.save.data.flashingLights) {
				FlxG.camera.flash(FlxColor.WHITE, 4);
			} else {
				FlxG.camera.flash(FlxColor.BLACK, 4);
			}	
			skippedIntro = true;
		}
	}
}