package states;

import openfl.display.Sprite;
import openfl.net.NetStream;
import openfl.media.Video;
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
import flixel.input.keyboard.FlxKey;
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

import options.OptionsMenuState;

import states.FreeplayState;
import states.editors.ChartingState;

import shaderslmao.BuildingShaders.BuildingShader;
import shaderslmao.BuildingShaders;
import shaderslmao.ColorSwap;

#if discord_rpc
import backend.Discord.DiscordClient;
#end
import backend.DefinitiveData;
import backend.PlayerSettings;
import backend.Highscore;

#if desktop
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
 
	var lastBeat:Int = 0;
	
	var returnedData:Array<String> = [];

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';
	public static var closedState:Bool = false;

	override public function create():Void
	{
		Paths.clearStoredMemory();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys[TAB];

		swagShader = new ColorSwap();
		alphaShader = new BuildingShaders();

		curWacky = FlxG.random.getObject(getIntroTextShit());
		
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		#if desktop
		FlxG.game.focusLostFramerate = 60;
		#end

		DefinitiveData.loadSettings();
		PlayerSettings.init();
		Highscore.load();
		getBuildVer();


		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		FlxG.mouse.visible = false;
		
		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#elseif OPTIONS
		FlxG.switchState(new OptionsMenuState());
		#else
		if (!initialized) 
		{
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				startIntro();
			});
		} 
		else
			startIntro();
		#end

		#if discord_rpc
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
	}

	function getBuildVer()
    {
		#if !debug
		trace('checking for update');
		var http = new haxe.Http("https://raw.githubusercontent.com/AnimatingLegend/Funkin-Definitive-Edition/master/gitVersion.txt");
	
		http.onData = function (data:String)
		{
			updateVersion = data.split('\n')[0].trim();
			var curVersion:String = MainMenuState.definitiveVersion.trim();
	
			trace('version online: ' + updateVersion + ', your version: ' + curVersion);
			if(updateVersion != curVersion) 
			{
				trace('versions arent matching!');
				mustUpdate = true;
			}
		}
	
		http.onError = function (error) 
		{
			trace('error: $error');
		}
	
		http.request();
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;
	var alphaShader:BuildingShaders = null;

	function startIntro()
	{
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.antialiasing = DefinitiveData.antialiasing;
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = DefinitiveData.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		if(FlxG.save.data.shaders) swagShader = new ColorSwap();
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = DefinitiveData.antialiasing;
		add(gfDance);
		add(logoBl);

		if(swagShader != null)
		{
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = DefinitiveData.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = DefinitiveData.antialiasing;
		logo.screenCenter();

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();
	
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);
	
		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		
		ngSpr = new FlxSprite(0, FlxG.height * 0.55);
		if (FlxG.random.bool(0.09)) // 9% chance
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo_animated'), true, 600);
			ngSpr.animation.add('idle', [0, 1], 4);
			ngSpr.animation.play('idle');
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.4));
			ngSpr.y += 25;
		}
		else
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo'));
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		}
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = DefinitiveData.antialiasing;
		add(ngSpr);
		ngSpr.visible = false;

		if (initialized)
			skipIntro();
		else
		{
			credTextShit.visible = false;
			FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

			// im so sorry for this :sob:
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}

			Conductor.changeBPM(102);
			initialized = true;
		}

		Paths.clearUnusedMemory();
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

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

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

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				if (mustUpdate)
					FlxG.switchState(new substates.OutdatedSubState()); 
				else
					FlxG.switchState(new MainMenuState());

				closedState = true;
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		#if desktop
		if (FlxG.keys.justPressed.ESCAPE)
		{
			Sys.exit(0);

			trace("exiting game...");
		}
		#end

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
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

		if(logoBl != null && logoBl.animation != null) {
			logoBl.animation.play('bump', true);
		}

		danceLeft = !danceLeft;

		if(gfDance != null && gfDance.animation != null) 
		{
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if (curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1:
						createCoolText(['The', 'Funkin Inc Crew']);
					case 3:
						addMoreText('presents');
					case 4:
						deleteCoolText();
					case 5:
						if (FlxG.save.data.watermark)
							createCoolText(['FNF Definitive Edition', 'by']);
						else
							createCoolText(['In association', 'with']);

					case 7:
						if (FlxG.save.data.watermark)
							addMoreText('Legend :]');
						else
						{
							addMoreText('newgrounds');

							if (ngSpr != null) 
								ngSpr.visible = true;
						}
					case 8:
						deleteCoolText();
						if (ngSpr != null) ngSpr.visible = false;
					case 9:
						createCoolText([curWacky[0]]);
					case 11:
						addMoreText(curWacky[1]);
					case 12:
						deleteCoolText();
					case 13:
						addMoreText('Friday');
					case 14:
						addMoreText('Night');
					case 15:
						addMoreText('Funkin');
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
			trace('skipping intro...');

			remove(ngSpr);
			remove(credGroup);
			
			if (FlxG.save.data.flashingLights) {
				FlxG.camera.flash(FlxColor.WHITE, initialized ? 1 : 4);
			} else {
				FlxG.camera.flash(FlxColor.BLACK, initialized ? 1 : 4);
			}

			FlxG.sound.music.time = 9400; // 9.4 seconds
			skippedIntro = true;
		}
	}
}