package funkin.play.cutscene;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.util.CoolUtil;
import funkin.util.Paths;

using StringTools;

/**
 * CUTSCENE CHARACTER CLASS
 * 
 * Handles certain character data and offsets for atlas cutscenes.
 */
class CutsceneCharacter extends FlxTypedGroup<FlxSprite> 
{
  /**
   * Get the stage position of the character.
   */
  public var characterPosition:FlxPoint = FlxPoint.get();

  /**
   * Get the animation offsets of the character.
   */
  public var animationMap:Map<String, FlxPoint> = new Map();

  /**
   * Called when a certain segment of the cutscene is finished, 
   *  or when the cutscene itself ends.
   */
  public var onFinish:Void->Void;

  /**
   * Get the image path of the character.
   */
  private var spriteImagePath:String;

  /**
   * Get the directory of the image path the character is in.
   */
  private var library:String;

  /**
   * Get the array of frames the character has.
   */
  var characterArray:Array<String> = [];

  public function new(x:Float, y:Float, spriteImagePath:String, library:String = null) 
  { 
    super();

    characterPosition.set(x, y);

    this.spriteImagePath = spriteImagePath;
    this.library = library;

    parseOffsets();
    createCutsceneCharacter();
  }

  /**
   * Parse the offsets, and get the frames of the character.
   */
  function parseOffsets():Void
  {
    var spritePath:Array<String> = CoolUtil.coolTextFile(Paths.file('images/cutscenes/${spriteImagePath}CutsceneOffsets.txt', library));
    for (index in spritePath)
    {
      var XY_AXIS:FlxPoint = FlxPoint.get();
      var splitOffsets:Array<String> = index.split('---')[1].trim().split(' ');
      
      trace('CHARACTER OFFSETS: $splitOffsets');
      XY_AXIS.set(Std.parseFloat(splitOffsets[0]), Std.parseFloat(splitOffsets[1]));

      animationMap.set(index.split('---')[0].trim(), XY_AXIS);
      characterArray.push(index.split('---')[0].trim());
    }

    // Trace the animation map
    var mapTrace:String = '';
    for (key in animationMap.keys())
    {
      mapTrace += '${key} : ${animationMap.get(key)}\n';
    }

    trace('ANIMATION MAP: \n$mapTrace');
  }

  /**
   * Create the character for the cutscene.
   * @param frameNumber - The amount of frames the character has.
   */
  function createCutsceneCharacter(frameNumber:Int = 0):Void
  {
    var characterSpr:FlxSprite = new FlxSprite(
      characterPosition.x + animationMap.get(characterArray[frameNumber]).x,
      characterPosition.y + animationMap.get(characterArray[frameNumber]).y
    );
    characterSpr.frames = Paths.getSparrowAtlas('cutscenes/${spriteImagePath}-$frameNumber', library);
    characterSpr.animation.addByPrefix('animation', characterArray[frameNumber], 24, false);
    characterSpr.animation.play('animation');
    characterSpr.antialiasing = FlxG.save.data.antialiasing;

    characterSpr.animation.finishCallback = function(_)
    {
      characterSpr.kill();
      characterSpr.destroy();
      characterSpr = null;

      // Create the next character if there is one.
      // Otherwise, end the segment.
      if (frameNumber + 1 < characterArray.length)
      {
        createCutsceneCharacter(frameNumber + 1);
      }
      else
        endCutscene();
    };

    add(characterSpr);
  }

  /**
   * Called when a certain segment of the cutscene is finished, 
   *  or when the cutscene itself ends.
   * 
   * @see `onFinish`
   */
  function endCutscene():Void
  {
    if (onFinish != null)
      onFinish();
  }
}
