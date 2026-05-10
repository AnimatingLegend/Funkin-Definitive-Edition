package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.text.FlxText.FlxTextBorderStyle;

import funkin.backend.system.monitor.DebugDisplay;
import funkin.backend.system.PlayerSettings;
import funkin.backend.utils.DefinitiveData;
import funkin.backend.utils.Highscore;

import funkin.menus.TitleState;
import funkin.menus.MainMenuState;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import lime.app.Application;
#end

using StringTools;

/**
 * MAIN GAME CLASS
 * 
 * This is where the game is initialized.
 * You can pretty much ignore everything from here on, your code should go in your states.
 */
class Main extends Sprite
{
	var gameWidth:Int = 1280; // The width of the game window in pixels.
	var gameHeight:Int = 720; // The height of the game window in pixels.
	var initialState:Class<FlxState> = TitleState; // The FlxState your game starts in.
	var zoom:Float = -1; //if zoom is set to -1, zoom will automatically calculate to fit the game window.
	var skipSplash:Bool = true; // Whether or not to skip the HaxeFlixel splash screen.

	/**
	 * Creates a new Main instance and adds it to the current stage.
	 */
	public static function main():Void 
		Lib.current.addChild(new Main());

	public function new():Void 
	{
		
		super();

		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		// Initialize the Crash Handler as soon as possible before the game starts.
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	function init(e:Event = null):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

	/**
	 * The FPS debug display on the top left of your game window.
	 */
	public static var debugDisplay:DebugDisplay;
	
	function setupGame():Void
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');
		DefinitiveData.initialize();

		// Get the framerate from your saved data if it exists, otherwise fallback to 60 FPS.
		var framerate:Int = FlxG.save.data.fpsCap == null ? 60 : FlxG.save.data.fpsCap;

		var game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, 
			FlxG.stage.window.fullscreen || FlxG.save.data.launchInFullscreen);
		addChild(game);

		debugDisplay = new DebugDisplay(10, 15, FlxTextBorderStyle.OUTLINE);
		addChild(debugDisplay);
		toggleFPS(FlxG.save.data.debugDisplay);
		debugDisplay.createBackground();
		debugDisplay.backgroundOpacity = (FlxG.save.data.debugDisplayBGOpacity) / 100;
		debugDisplay.set_backgroundOpacityVisible(FlxG.save.data.debugDisplay);

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		Highscore.load();
		PlayerSettings.init();

		#if hxcpp_debug_server
    		trace('hxcpp_debug_server is enabled! You can now connect to the game with a debugger.');
    		#else
    		trace('hxcpp_debug_server is disabled! This build does not support debugging.');
    		#end
	}

	/**
	 * Toggle the FPS counter.
	 */
	public static function toggleFPS(value:Bool):Void 
		if (debugDisplay != null) debugDisplay.visible = value;

	/**
	 * Clear games cache of assets and song data. (taken from Kade Engine)
	 */
	public static function dumpCache():Void
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Assets.cache.clear("songs");
	}

	/**
	 * Get the current version of the game, and determine whether or not an update is available.
	 */
	public static var updateVersion:String = "";
	public static var mustUpdate:Bool = false;

	/**
	 * Check to see if there is a new version of the game.
	 */
	public static function getBuildVersion():Void
	{
		#if !debug
		var http = new haxe.Http('https://raw.githubusercontent.com/AnimatingLegend/Funkin-Definitive-Edition/refs/heads/main/gitVersion.txt');

		trace('[VERSION] Checking for updates...');

		http.onData = function(data:String)
		{
			updateVersion = data.split('\n')[0].trim();
			var currentVersion:String = MainMenuState.definitiveVersion.trim();

			trace('[VERSION] Current version: ${currentVersion} | New version: ${updateVersion}');

			if (updateVersion != currentVersion)
			{
				trace('[VERSION] New version available. Please update to ${updateVersion}.');
				mustUpdate = true;
			}
			else trace('[VERSION] Game version is up to date.');
		}

		http.onError = function(error) { trace('[VERSION] Error: ${error}'); }
		http.request();
		#end
	}

	/**
	 * Handle uncaught errors on game crash.
	 * @param crashEvent - The uncaught error event.
	 */
	#if CRASH_HANDLER
	public function onCrash(crashEvent:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = './crash/' + 'Funkin Definitive Edition ${dateNow}.txt';

		// Get the file and the line number of the error.
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\nUncaught Error: ${crashEvent.error}\n Please report this error to the GitHub page: https://github.com/AnimatingLegend/Funkin-Definitive-Edition/issues';

		// Create the crash directory if it doesn't exist.
		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
	#end
}
