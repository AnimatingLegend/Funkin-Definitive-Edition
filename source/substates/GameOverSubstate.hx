package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import objects.Character;
import objects.Boyfriend;

import states.PlayState;

class GameOverSubstate extends MusicBeatSubstate
{
	public var bf:Boyfriend;
	public var dad:Character;

	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var library:String = "";

	var randomGameover:Int = 1;
	var playingDeathSound:Bool = false;

	public function new(x:Float, y:Float)
	{
		Paths.clearUnusedMemory();

		var daStage = states.PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				library = 'shared';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
				library = 'shared';
		}

		if (PlayState.SONG.song.toLowerCase() == 'stress')
			daBf = 'bf-holding-gf-dead';

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude = [];

		if (FlxG.save.data.explicitContent)
			exclude = [1, 3, 8, 13, 17, 21];

		randomGameover = FlxG.random.int(1, 25, exclude);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new states.StoryMenuState());
			else
				FlxG.switchState(new states.FreeplayState());

			PlayState.deathCounter = 0;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			#if html5
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			#else
			FlxG.camera.follow(camFollow, LOCKON, 0.01 * (30 / FlxG.save.data.framerateDraw));
			#end
		}

		if (PlayState.storyWeek == 7)
		{
			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
			{
				playingDeathSound = true;
				bf.startedDeath = true;
				coolStartDeath(0.2);
				FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover, 'week7'), 1, false, null, true, function()
				{
					FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			}
		}
		else if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.startedDeath = true;
			coolStartDeath();
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		super.update(elapsed);
	}

	function coolStartDeath(startVol:Float = 1)
	{
		FlxG.sound.playMusic(Paths.music('gameOver/gameOver' + stageSuffix, library), startVol);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOver/gameOverEnd' + stageSuffix, library));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					states.LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
