package funkin.ui.debug;

import openfl.display.Shape;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * DEBUG DISPLAY (FPS COUNTER) CLASS
 * 
 * Displays your current FPS, as well as your MEM usage for the game,
 * in the top left corner of your game window.
 */
class DebugDisplay extends TextField
{
	//
	// CONFIG (color, thickness, padding, etc.)
	//

	static inline final BG_COLOR:Int = 0x2c2f30;
	static inline final BORDER_COLOR:Int = 0x3d3f41;
	static inline final BORDER_THICKNESS:Int = 4;
	static inline final PADDING:Int = 6;
	static inline final FONT_SIZE:Int = 12;
	static inline final UPDATE_INTERVAL:Float = 50.0;

	//
	// PUBLIC FIELDS
	//

	/**
	 * Opacity of the debug display's background panel.
	 */
	public var backgroundOpacity(default, set):Float = 0.5;

	/**
	 * Whether the debug display's background panel is visible.
	 * @default true
	 */
	public var backgroundVisible(default, set):Bool = true;

	/**
	 * Current FPS, capped at the game's `FlxG.updateFramerate`.
	 */
	public var currentFPS(default, null):Int = 0;

	/**
	 * Current GC memory usage, in bytes.
	 */
	public var systemMemory(default, null):Float = 0;

	/**
	 * Peak GC memory usage, in bytes.
	 */
	public var maxMemory(default, null):Float = 0;

	//
	// PRIVATE FIELDS
	//

	/**
	 * The debug display's background panel.
	 */
	private var _background:Shape;

	/**
	 * Array of times since the last update.
	 */
	private var _times:Array<Float> = [];

	/**
	 * Accumulated time since the last update.
	 */
	private var _deltaAccumulator:Float = 0.0;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;
		multiline = true;
		autoSize = LEFT;

		defaultTextFormat = new TextFormat('_sans', FONT_SIZE, 0xffffff, true);
	}

	/**
	 * Call after adding to the display list to create the bacground panel.
	 */
	public function createBackground():Void
	{
		if (parent == null)
		{
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
      return;
		}

		_background = new Shape();
		_background.x = x;
		_background.y = y;
		parent.addChildAt(_background, parent.getChildIndex(this));
	}

	/**
   * Formats an MB value into a display string, switching to GB above 1000 MB.
   * @param value Memory value in megabytes
   */
	public function formatMemory(value:Float):String
	{
		return value >= 1000
			? '${FlxMath.roundDecimal(value / 1000, 2)}GB'
			: '${value}MB';
	}

	/**
	 * Updates the display of the FPS and memory usage.
	 * [!NOTE] Made the function `dynamic` so it can be overridden by mods and custom builds.
	 */
	public dynamic function updateDisplay():Void
	{
		// Get the operating system your game is running on
		final OS:Array<String> = [
			#if windows 
			'Windows',
			#elseif mac 
			'macOS',
			#elseif linux 
			'Linux',
			#elseif html5
			'HTML5',
			#elseif android
			'Android',
			#else
			'NO OS DETECTED', 
			#end
		];

		// Get the compiler used to build the game.
		final COMPILER:Array<String> = [
			#if cpp
			'C++',
			#elseif hl
			'HashLink',
			#else
			'NO COMPILER DETECTED',
			#end
		];

		text = [
			'FPS: ${currentFPS}',
			#if !hl 
			'MEM: ${formatMemory(systemMemory)} / ${formatMemory(maxMemory)}', 
			#end
			#if debug
			'OS: ${OS.join(" ")} (${COMPILER.join(" ")})',
			'STATE: ${Type.getClassName(Type.getClass(FlxG.state))}.hx' 
			#end
		].join('\n');

		// If the current FPS is less than half the target FPS, make the text red.
		// DEFAULT: White
		textColor = (maxMemory > 3000 || currentFPS <= FlxG.save.data.fpsCap / 2)
      ? 0xFF0000
      : 0xFFFFFF;
	}

	private function _onAddedToStage(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		createBackground();
	}

	private function _redrawBackground():Void
	{
		if (_background == null)
			return;

		final bgWidth:Float = this.width + (PADDING * 2);
		final bgHeight:Float = this.height + (PADDING * 2);

		_background.x = x - PADDING;
		_background.y = y - PADDING;
		_background.graphics.clear();

		// Outer Border
		_background.graphics.beginFill(BORDER_COLOR, 1);
		_background.graphics.drawRect(0, 0, bgWidth, bgHeight);
		_background.graphics.endFill();

		// Inner Border
		_background.graphics.beginFill(BG_COLOR, 1);
		_background.graphics.drawRect(
			BORDER_THICKNESS, BORDER_THICKNESS,
			bgWidth - (BORDER_THICKNESS * 2),
			bgHeight - (BORDER_THICKNESS * 2)
		);
		_background.graphics.endFill();

		_background.alpha = backgroundOpacity;
	}

	/**
	 * `__enterFrame` event handler that updates the FPS and memory usage every millisecond.
	 */
	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		_times.push(now);
		while (_times[0] < now - 1000)
		{
			_times.shift();
		}

		// Update the display once every 50ms
		_deltaAccumulator += deltaTime;
		if (_deltaAccumulator < UPDATE_INTERVAL)
			return;

		// Convert bytes to megabytes and round to 2 decimal places.
		systemMemory = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2));
		// Update max memory if current memory exceeds it.
		if (systemMemory > maxMemory)
			maxMemory = systemMemory;

		currentFPS = _times.length < FlxG.updateFramerate ? _times.length : FlxG.updateFramerate;

		updateDisplay();
		_redrawBackground();
		_deltaAccumulator;
	}

	public function set_backgroundOpacity(value:Float):Float
	{
		backgroundOpacity = value;
		if (_background != null)
			_background.alpha = value;
		return value;
	}

	public function set_backgroundVisible(value:Bool):Bool
	{
		backgroundVisible = value;
		if (_background != null)
			_background.visible = value;
		return value;
	}
}
