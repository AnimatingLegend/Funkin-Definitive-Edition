package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
import display.FPSCounter;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function setupSaveData() {
	// False =  not enabled by default | True = enabled by default
		if(FlxG.save.data.judgementCounter == null)
			FlxG.save.data.judgementCounter = false;

		if(FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if(FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;

		if(FlxG.save.data.framerateDraw == null)
			FlxG.save.data.framerateDraw = 120;

		if(FlxG.save.data.ghostTapping == null)
			FlxG.save.data.ghostTapping = false;

		if(FlxG.save.data.cursingShit == null)
			FlxG.save.data.cursingShit = false;

		if(FlxG.save.data.flashingLights == null)
			FlxG.save.data.flashingLights = true;

		if(FlxG.save.data.notesplash == null)
			FlxG.save.data.notesplash = true;
		
		if(FlxG.save.data.glowStrums == null)
			FlxG.save.data.glowStrums = true;

		if(FlxG.save.data.accuracy == null)
			FlxG.save.data.accuracy = true;

		if(FlxG.save.data.camhudZoom == null)
			FlxG.save.data.camhudZoom = true;

		if(FlxG.save.data.ratingHUD == null)
			FlxG.save.data.ratingHUD = false;

		if(FlxG.save.data.colors == null)
			FlxG.save.data.colors = true;

		if(FlxG.save.data.lowData == null)
			FlxG.save.data.lowData = true;

		if(FlxG.save.data.fps == null)
			FlxG.save.data.fps = true;
	}

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
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

		// dont mind this code.. [Line 117 - 125]
		#if desktop
		initialState = CachingState;
		#else
		initialState = TitleState;
		#end

		#if debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsCounter = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		if(FlxG.save.data.fps == null)
			FlxG.save.data.fps = true;

		toggleFPS(FlxG.save.data.fps);
		#end

		setupSaveData();
		Conductor.offset = FlxG.save.data.notesOffset;
	}

	var fpsCounter:FPSCounter;

	public function toggleFPS(fpsEnabled:Bool):Void 
	{
		fpsCounter.visible = fpsEnabled;
	}
}