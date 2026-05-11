package funkin.menus;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import funkin.backend.utils.Paths;

import funkin.menus.OutdatedSubState;
import funkin.menus.objects.Alphabet;
import funkin.menus.shaders.ColorSwap;

import funkin.editors.ChartingState;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.net.NetStream;
import openfl.media.Video;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

using StringTools;

/**
 * TITLE STATE CLASS
 * 
 * This is the title screen of the game.
 */
class TitleState extends MusicBeatState
{
	/**
	 * Whether or not the title screen has been initialized.
	 * [!NOTE] Only play the credits once per game session.
	 */
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var legSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var lastBeat:Int = 0;
	var swagShader:ColorSwap;

	override public function create():Void
	{
          Paths.clearStoredMemory();

          swagShader = new ColorSwap();
		curWacky = FlxG.random.getObject(getIntroTextShit());

          super.create();

		Main.getBuildVersion();

		if (FlxG.save.data.launchInFullscreen) FlxG.fullscreen = true;

          FlxG.mouse.visible = false;

		// If the game isn't initialized yet, wait a second before starting the intro.
          // Otherwise, start the intro normally.
		if (!initialized)
          {
               new FlxTimer().start(1, function(tmr:FlxTimer) 
               { 
                    startIntro(); 
               });
          }
		else startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized || FlxG.sound.music == null) playMenuMusic();

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		if (FlxG.save.data.shaders && swagShader != null) 
               logoBl.shader = swagShader.shader;
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		if (FlxG.save.data.shaders && swagShader != null) 
               gfDance.shader = swagShader.shader;

		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();
	
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);
	
		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		
		ngSpr = new FlxSprite(0, FlxG.height * 0.55);
		if (FlxG.random.bool(1))
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
		ngSpr.antialiasing = FlxG.save.data.antialiasing;
		add(ngSpr);
		ngSpr.visible = false;

		legSpr = new FlxSprite(0, FlxG.height * 0.6);
		legSpr.loadGraphic(Paths.image('leg'));
		legSpr.setGraphicSize(Std.int(legSpr.width * 0.4));
		legSpr.updateHitbox();
		legSpr.screenCenter(X);
		legSpr.antialiasing = FlxG.save.data.antialiasing;
		add(legSpr);
		legSpr.visible = false;

		if (initialized) skipIntro();
		else
		{
			credTextShit.visible = false;
			FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

               playMenuMusic();
			Conductor.changeBPM(102);
			initialized = true;
		}
	}

     function playMenuMusic():Void
     {
          var shouldFadeIn:Bool = (FlxG.sound.music == null);
          FlxG.sound.playMusic(Paths.music('freakyMenu'), 0, true);

          if (shouldFadeIn) FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		// If you spam `ENTER`, skip the transition.
		if (pressedEnter && transitioning && skippedIntro) moveToMainMenu();
		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.onComplete = null;

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				moveToMainMenu();
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			trace('[INFO] Just Pressed ${if (FlxG.keys.justPressed.ENTER) "ENTER" else "SPACE"} Skipping Intro...');
			skipIntro();
		}

		#if desktop
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			trace('[EXITING] Game is closing. Cleaning up resources...');
			Paths.clearStoredMemory();
			Sys.exit(0);
		}
		#end

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function moveToMainMenu():Void
	{
		Paths.clearUnusedMemory();

		// Only show update screen if you're not on a debug build.
		#if !debug
		if (Main.mustUpdate) FlxG.switchState(new OutdatedSubState());
		else FlxG.switchState(new MainMenuState());
		#else
		FlxG.switchState(new MainMenuState());
		#end
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
          if (credGroup == null || textGroup == null) return;

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
          if (credGroup == null || textGroup == null) return;

		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200 + offset;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		if (credGroup == null || textGroup == null) return;
		for (member in textGroup.members) credGroup.remove(member, true);
		textGroup.clear();
	}

	override function beatHit()
	{
		super.beatHit();

		if (!skippedIntro && curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1: createCoolText(['The', 'Funkin Inc Crew']);
					case 3: addMoreText('presents');
					case 4: deleteCoolText();
					case 5:
						if (FlxG.save.data.fdeWatermark)
                              {
                                  createCoolText(['FNF Definitive Edition', 'by']); 
                              }
						else
                              {
                                 createCoolText(['In association', 'with']);  
                              }
					case 7:
						if (FlxG.save.data.fdeWatermark)
						{
							addMoreText('This guy lol');
							if (legSpr != null) legSpr.visible = true;
						}
						else
						{
							addMoreText('newgrounds');
							if (ngSpr != null) ngSpr.visible = true;
						}
					case 8:
						deleteCoolText();
						if (FlxG.save.data.fdeWatermark)
						{
							if (legSpr != null) legSpr.visible = false;
						}
						else
						{
							if (ngSpr != null) ngSpr.visible = false;
						}
					case 9:  createCoolText([curWacky[0]]);
					case 11: addMoreText(curWacky[1]);
					case 12: deleteCoolText();
					case 13: addMoreText('Friday');
					case 14: addMoreText('Night');
					case 15: addMoreText('Funkin');
					case 16: skipIntro();
				}
			}
		}	

		lastBeat = curBeat;

          if (skippedIntro)
          {
               if (logoBl != null && logoBl.animation != null) logoBl.animation.play('bump', true);

		     danceLeft = !danceLeft;

               if (gfDance != null && gfDance.animation != null) 
               {
                    if (danceLeft) gfDance.animation.play('danceRight');
                    else gfDance.animation.play('danceLeft');
               }
          }
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
               remove(legSpr);
			remove(ngSpr);
			
			if (FlxG.save.data.flashingLights) FlxG.camera.flash(FlxColor.WHITE, initialized ? 1 : 4);
			else FlxG.camera.flash(FlxColor.BLACK, initialized ? 1 : 4);

			// This intro skips the first 9.4 seconds of the song.
			FlxG.sound.music.time = 9400;

			if (credGroup != null) remove(credGroup);
			skippedIntro = true;
		}
	}
}
