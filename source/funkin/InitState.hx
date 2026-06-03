package funkin;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import funkin.backend.system.PlayerSettings;
import funkin.backend.utils.DefinitiveData;
import funkin.backend.utils.Highscore;
import funkin.menus.CacheState;

/**
 * INITALIZE CLASS
 * 
 * This class is used to initialize certain elements of the game.
 * i.e. transitions, build flags, etc.
 */
class InitState extends FlxState
{
	static var _coreInitialized:Bool = false;
	static var _lostFocusVolume:Null<Float> = null;

	/**
	 * Quickly setup the game, and transition to the title screen.
	 */
	public override function create()
	{
		// Setup a bunch of important flixel elements.
		setupFlixel();

		// Load player options from save data.
		DefinitiveData.initialize();

		// Load player highscores.
		Highscore.load();

		// Load player controls from save data.
		PlayerSettings.init();

		// Where the magic happens :eyes:
		startGame();
	}

	/**
	 * Setup a bunch of important flixel elements.
	 */
	function setupFlixel()
	{
		if (!_coreInitialized)
		{
			// Setup auto pause.
			FlxG.autoPause = FlxG.save.data.autoPause;

			// Set the game to a lower frame rate while it is in the background.
			FlxG.game.focusLostFramerate = 30;

			// Makes Flixel use frame times instead of locked movements per frame for things like tweens.
			FlxG.fixedTimestep = false;

			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			// NOTE: tileData is ignored if TransitionData.type is FADE instead of TILES.
			var tileData:TransitionTileData = {asset: diamond, width: 32, height: 32};

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), tileData,
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), tileData,
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			// Try and keep the game transitions clean and consistent when resizing the window.
			FlxG.signals.gameResized.add(function(width:Int, height:Int)
			{
				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), tileData,
					new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), tileData,
					new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			});

			FlxG.signals.focusLost.add(onLostFocus);
			FlxG.signals.focusGained.add(onGainFocus);

			_coreInitialized = true;
			trace('SETUP: Flixel core initialized.');
		}
	}

	/**
	 * When the game loses focus, turn down the volume by 25%.
	 */
	function onLostFocus():Void
	{
		trace('WARNING: User lost focus of the game window. Turning down volume by 25%.');
		if (FlxG.sound.muted || FlxG.sound.volume <= 0 || FlxG.autoPause)
			return;
		_lostFocusVolume = FlxG.sound.volume;
		FlxG.sound.volume *= 0.25;
	}

	/**
	 * When the game regains focus, restore your framerate and volume.
	 */
	function onGainFocus():Void
	{
		trace('INFO: User regained focus of the game window. Restoring volume and framerate.');
		if (FlxG.save.data.fpsCap != null)
		{
			FlxG.updateFramerate = FlxG.save.data.fpsCap;
			FlxG.drawFramerate = FlxG.save.data.fpsCap;
		}
		else
		{
			FlxG.updateFramerate = 60;
			FlxG.drawFramerate = 60;
		}

		// Restore the volume.
		if (FlxG.autoPause)
			return;
		if (_lostFocusVolume != null)
		{
			FlxG.sound.volume = _lostFocusVolume;
			_lostFocusVolume = null;
		}
	}

	/**
	 * Start the game.
	 * 
	 * For quick accessibility to certain states, 
	 *   use the `#define` build flags below to change the startup state.
	 * 
	 * @default `TitleState.hx`: Default startup state.
	 */
	function startGame():Void
	{
		// Skip the next transition.
		FlxTransitionableState.skipNextTransIn = true;

		#if PREVIEW_ANIMATION_EDITOR
		// -DPREVIEW_ANIMATION_EDITOR
		FlxG.switchState(new funkin.editors.AnimationDebug());
		#elseif PREVIEW_CHART_EDITOR
		// -DPREVIEW_CHART_EDITOR
		FlxG.switchState(new funkin.editors.ChartingState());
		#elseif FREEPLAY_MENU
		// -DFREEPLAY_MENU
		FlxG.switchState(new funkin.menus.FreeplayState());
		#elseif (!debug || FEATURE_CACHE)
		// -DFEATURE_CACHE
		// Adding this here if you want to cache the game when debugging.
		FlxG.switchState(new funkin.menus.CacheState());
		#else
		FlxG.switchState(new funkin.menus.TitleState());
		#end
	}
}
