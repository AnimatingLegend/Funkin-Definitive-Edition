package funkin.play;

import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.play.PlayState;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.transition.LoadingState;

/**
 * GAMEOVER SUB-STATE (Substate for `PlayState.hx`)
 */
class GameOverSubstate extends MusicBeatSubstate
{
	/**
	 * The entire substate's instance.
	 */
	public static var instance:GameOverSubstate = null;

	/**
	 * Whether the substate is currently active.
	 * @default true
	 */
	static var isSubState:Bool = true;

	/**
	 * Which music track to play.
	 * 
	 * Current suffix:
	 * `-pixel`: week 6 Pixel UI assets
	 * `default`: Everything else
	 */
	public static var musicSuffix:String = '';

	/**
	 * Which alternate "blue ball" SFX to play.
	 * 
	 * Current suffix:
	 * `-pixel`: week 6 Pixel UI assets
	 * `default`: Everything else
	 */
	public static var blueBallSuffix:String = '';

	/**
	 * Whether the player has officially died or not.
	 */
	static var blueBalled:Bool = false;

	/**
	 * The boyfriend character.
	 */
	var boyfriend:Null<Boyfriend> = null;

	/**
	 * The camera that follows the boyfriend character.
	 */
	var cameraPoint:Null<FunkinCamera>;

	/**
	 * The invisible object that follows the camera.
	 */
	var cameraFollowPoint:FlxObject;

	/**
	 * The gameover music playing in the background of the substate.
	 */
	var gameOverMusic:Null<FlxSound> = null;

	/**
	 * Whether the death loop music has started playing.
	 */
	var isStarting:Bool = false;

	/**
	 * Whether the player has confirmed to restart the level, or go back to the menus.
	 */
	var isEnding:Bool = false;

	/**
	 * Random index for the week 7 `jeffGameover-` voice lines. (1-25)
	 */
	var tankGameOverLines:Int = 1;

	public function new(x:Float, y:Float)
	{
		super();

		instance = this;

		Paths.clearUnusedMemory();

		Conductor.songPosition = 0;
		Conductor.changeBPM(100);

		// Resolve suffix and character variants base on the current stage / song.
		var BF_VARIANTS:String = resolveBFVariants();

		boyfriend = new Boyfriend(x, y, BF_VARIANTS);
		add(boyfriend);
		boyfriend.playAnim('firstDeath');

		var boyfriendPos:FlxPoint = boyfriend.getGraphicMidpoint();
		
		// Create a camera that follows the boyfriend character.
		cameraPoint = new FunkinCamera(FlxG.camera, PlayState.instance.targetCamZoom);
		cameraPoint.followLerping = true;
		// Get the object that follows the camera.
		cameraFollowPoint = new FlxObject(boyfriendPos.x, boyfriendPos.y, 1, 1);
		add(cameraFollowPoint);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		// Blue ball SFX; play once, not looped.
		blueBalled = true;
		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + blueBallSuffix));

		// Exclude explicit voice lines if content filter is off.
		// 1=Cock, 3=Shitty, 8=Shit, 13=Fuck, 17=Shit/Asshole, 21=Fucking
		var exclude:Array<Int> = !FlxG.save.data.naughtyness ? [] : [1, 3, 8, 13, 17, 21];
		tankGameOverLines = FlxG.random.int(1, 25, exclude);
	}

	/**
	 * Resolves the correct BF death variant and sets
	 * 	`musicSuffix` / `blueBallSuffix` based on the current stage and song.
	 */
	function resolveBFVariants():String
	{
		switch (PlayState.curStage)
		{
			case 'school' | 'schoolEvil':
				musicSuffix = '-pixel';
				blueBallSuffix = '-pixel';
				return 'bf-pixel-dead';
			default:
				musicSuffix = '';
				blueBallSuffix = '';
				if (PlayState.SONG.song.toLowerCase() == 'stress')
				{
					return 'bf-holding-gf-dead';
				}
				return 'bf';
		}
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		cameraPoint.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		handleInput();
		handleDeathAnimations();
	}

	/**
	 * Handles restarting, and exiting inputs.
	 */
	function handleInput():Void
	{
		if (isEnding)
			return;
		if (controls.ACCEPT)
			confirmRestart();
		if (controls.BACK)
			exitToMenu();
	}

	/**
	 * Watches the `firstDeath` animation and triggers
	 * 	the camera follow and death music at the right frames.
	 */
	function handleDeathAnimations():Void
	{
		final deathAnim = boyfriend.animation.curAnim;
		if (deathAnim == null || deathAnim.name != 'firstDeath')
			return;

		// Start camera follow at frame 12.
		if (deathAnim.curFrame == 12)
		{
			cameraPoint.setFollow(cameraFollowPoint, false);
		}

		// Once `firstDeath` finishes, start the death loop music.
		if (deathAnim.finished && !isStarting)
		{
			isStarting = true;
			boyfriend.startedDeath = true;
			startGameOverMusic();
		}
	}

	/**
	 * Starts the gameover loop music.
	 * Week 7 plays the `jeffGameover-` voice lines first, then the `gameOver` music fades in.
	 */
	function startGameOverMusic(startingVolume:Float = 1):Void
	{
		switch (PlayState.storyWeek)
		{
			case 7:
				FlxG.sound.playMusic(Paths.music('gameOver/gameOver' + musicSuffix, 'shared'), 0.2);
				FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + tankGameOverLines, 'week7'), 1, false, null, true, function()
				{
					FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			default:
				FlxG.sound.playMusic(Paths.music('gameOver/gameOver' + musicSuffix, 'shared'), startingVolume);
		}
	}

	/**
	 * Triggered when the player confirms a restart.
	 * Plays the `deathConfirm` animation, and reloads to the `PlayState`.
	 */
	function confirmRestart():Void
	{
		isEnding = true;
		boyfriend.playAnim('deathConfirm', false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music('gameOver/gameOverEnd' + musicSuffix, 'shared'), false);

		// Confirm music length divided by 7,000
		// adding this refactor for future modding users.
		final FADE_TIMER:Float = FlxG.sound.music.length / 7000;

		// After the animation finishes, fade out the music.
		new FlxTimer().start(FADE_TIMER, function(tmr:FlxTimer)
		{
			// Callback for when the transition is finished.
			var finishTransition = function()
			{
				if (FlxG.state.subState == this)
				{
					close();
					trace('CAMERA: Transition to PlayState event triggered.');
				}
				else
				{
					LoadingState.loadAndSwitchState(new PlayState());
					trace('CAMERA: Transition to PlayState event failed. Restarting PlayState...');
				}
			};

			// Fade out the graphics, and smoothly transition back to the PlayState.
			if (musicSuffix.contains('-pixel'))
			{
				cameraPoint.pixelFade(FlxColor.BLACK, 2.8, 8, 22, false, function()
				{
					finishTransition();
					// Add a REALLY small delay before fading back in.
					// Removing this doesn't even transition properly for some reason.
					new FlxTimer().start(0, function(_)
					{
						cameraPoint.pixelFade(FlxColor.BLACK, 2.8, 8, 22, true, null);
					});
				}, this);
			}
			else
			{
				cameraPoint.fade(FlxColor.BLACK, 2.8, false, function()
				{
					finishTransition();
					cameraPoint.fade(FlxColor.BLACK, 2.8, true);
				});
			}
		});
	}

	/**
	 * Exits to the appropriate menu and resets the death counter.
	 */
	function exitToMenu():Void
	{
		isEnding = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;

		if (PlayState.isStoryMode)
		{
			FlxG.switchState(new StoryMenuState());
		}
		else
		{
			FlxG.switchState(new FreeplayState());
		}
	}

	override function beatHit():Void
	{
		super.beatHit();
	}

	override public function close():Void
	{
		super.close();

		// Reset the camera zoom, and snap it to the correct side.
		cameraPoint.resetZoom();
		cameraPoint.snapToTarget();

		PlayState.instance.restartSong();
	}

	override public function destroy():Void
	{
		instance = null;
		super.destroy();
	}
}
