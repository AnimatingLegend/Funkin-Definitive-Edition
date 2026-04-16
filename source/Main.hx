package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.text.FlxText.FlxTextBorderStyle;

import funkin.backend.chart.Conductor;
import funkin.backend.system.monitor.FPSCounter;
import funkin.backend.utils.DefinitiveData;

import funkin.menus.TitleState;
import funkin.menus.CacheState;

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

class Main extends Sprite
{
	var gameWidth:Int = 1280; // GAME WIDTH
	var gameHeight:Int = 720; // GAME HEIGHT
	var initialState:Class<FlxState> = TitleState; // GAMES INITIAL STATE
	var zoom:Float = -1; // GAME ZOOM (1 = 100%)
	var framerate:Int = 120; // GAME FRAMERATE
	var skipSplash:Bool = true; // SKIP HAXE LOGO
	var startFullscreen:Bool = false; // GAME STARTS IN FULLSCREEN

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !cpp
		framerate = 60;
		#end

		#if cpp
		#if !debug
		initialState = CacheState;
		#end
		game = new FlxGame(gameWidth, gameHeight, initialState, FlxG.drawFramerate, FlxG.updateFramerate, skipSplash, startFullscreen);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, FlxG.drawFramerate, FlxG.updateFramerate, skipSplash, startFullscreen);
		#end
		addChild(game);

		#if !mobile
		if(FlxG.save.data.fps == null) FlxG.save.data.fps = true;
		fpsCounter = new FPSCounter(10, 3, FlxTextBorderStyle.OUTLINE);
		toggleFPS(FlxG.save.data.fps);
		addChild(fpsCounter);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		DefinitiveData.settings();
		Conductor.offset = FlxG.save.data.notesOffset;
	}

	var game:FlxGame;
	var fpsCounter:FPSCounter;

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	// taken from kade engine :]
	public static function dumpCache()
	{
		///* SPECIAL THANKS TO HAYA
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
		// */
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "FNF - Definitive Edition " + dateNow + ".txt";

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

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/AnimatingLegend/Funkin-Definitive-Edition/issues";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
	#end
}