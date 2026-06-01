package funkin.backend.system.monitor;

import flixel.text.FlxText.FlxTextBorderStyle;

import openfl.display.Shape;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * DEBUG DISPLAY (FPS COUNTER) CLASS
 * 
 * A simple FPS Counter that displays your current FPS, and Memory usage.
 */
class DebugDisplay extends TextField 
{
     /**
      * The opacity of the FPS Counters background.
      */
     public var backgroundOpacity(default, set):Float = 0.5;

     /**
      * The current FPS, calculated as the number of frames rendered in the last second.
      */
     public var currentFPS(default, null):Int;


     /**
      * The current, and maximum memory usage of the game.
      */
     public var systemMemory(default, null):Float = 0;
     public var maxMemory:Float = 0;

	/**
	 * The timestamps of the frames rendered in the last second.
	 */
	@:noCompletion private var times:Array<Float>;

     var debugDisplayBG:Shape;

     public function new(x:Float = 10, y:Float = 10, args:FlxTextBorderStyle) 
     {
          super();

		this.x = x;
		this.y = y;

          this.times = [];

          this.selectable = false;
          this.mouseEnabled = false;

          this.textColor = FlxColor.WHITE;
          this.defaultTextFormat = new TextFormat('_sans', 12, FlxColor.BLACK, true);
          this.multiline = true;
          this.autoSize = LEFT;
     }

     public function createBackground():Void
     {
          if (parent == null)
          {
               trace('WARNING: Parent is null, retrying next frame...');
               addEventListener(Event.ADDED_TO_STAGE, retryCreateBackground);
               return;
          }
          debugDisplayBG = new Shape();
          debugDisplayBG.x = this.x;
          debugDisplayBG.y = this.y;
          parent.addChildAt(debugDisplayBG, parent.getChildIndex(this));
          trace('INFO: Created debug display background.');
     }

     function retryCreateBackground(_):Void
     {
          if (parent == null) return;
          removeEventListener(Event.ADDED_TO_STAGE, retryCreateBackground);
          createBackground();
     }

     
     function redrawBackground():Void
     {
          if (debugDisplayBG == null) return;

          final padding:Int = 6;
          final borderThickness:Int = 4;
          final width:Float = this.width + (padding * 2);
          final height:Float = this.height + (padding * 2);

          debugDisplayBG.x = this.x - padding;
          debugDisplayBG.y = this.y - padding;
          debugDisplayBG.graphics.clear();

          // Outer border
          debugDisplayBG.graphics.beginFill(0x3d3f41, 1);
          debugDisplayBG.graphics.drawRect(0, 0, width, height);
          debugDisplayBG.graphics.endFill();

          // Inner background
          debugDisplayBG.graphics.beginFill(0x2c2f30, 1);
          debugDisplayBG.graphics.drawRect(borderThickness, borderThickness, width - (borderThickness * 2), height - (borderThickness * 2));
          debugDisplayBG.graphics.endFill();
          
          debugDisplayBG.alpha = backgroundOpacity;
     }

     var deltaTimeout:Float = 0.0;

     /**
      * `__enterFrame` event handler that updates the FPS and memory usage every second.
      */
     @:noCompletion 
     private override function __enterFrame(deltaTime:Float):Void 
     {
          final now:Float = haxe.Timer.stamp() * 1000;
          times.push(now);
          while (times[0] < now - 1000) times.shift();

          // If the time between updates is less than 50 milliseconds, don't update the display yet.
          if (deltaTimeout < 50) { deltaTimeout += deltaTime; return; }

          systemMemory = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2)); // Convert bytes to megabytes and round to 2 decimal places.
          if (systemMemory > maxMemory) maxMemory = systemMemory; // Update max memory if current memory exceeds it.

          currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
          updateDisplay();
          redrawBackground();
          deltaTimeout = 0.0;
     }

     /**
      * Updates the display of the FPS and memory usage.
      * [!NOTE] Made the function `dynamic` so it can be overridden by mods and custom builds.
      */
     public dynamic function updateDisplay():Void
     {
          // If your memory usage is above 1000 megabytes, display it in gigabytes. (default: megabytes)
          var memoryUnit = systemMemory >= 1000 ? 'GB' : 'MB';

          text = [
               'FPS: ${currentFPS}',
               'MEM: ${systemMemory} / ${maxMemory}${memoryUnit}',
			'GAME STATE: ${Type.getClassName(Type.getClass(FlxG.state))}.hx'
          ].join('\n');

          textColor = FlxColor.WHITE;
          if (maxMemory > 3000 || currentFPS <= FlxG.save.data.fpsCap / 2) textColor = FlxColor.RED;
     }

     public function set_backgroundOpacityVisible(value:Bool):Void 
          if (debugDisplayBG != null) debugDisplayBG.visible = value;

     public function set_backgroundOpacity(value:Float):Float
     {
		if (debugDisplayBG != null) debugDisplayBG.alpha = value;
          return backgroundOpacity = value;
     }
}