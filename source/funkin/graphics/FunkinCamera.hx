package funkin.graphics;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * FUNKIN CAMERA CLASS
 * 
 * Custom camera logic for `PlayState` and other states.
 * Handles lerping, zoom targets, follow targets, etc.
 * 
 * USAGE:
 * ```haxe
 * var cam = new FunkinCamera(FlxG.camera);
 * cam.setFollow(camFollow);
 * cam.setZoom(1.2, 0.5); // Tween to zoom 1.2 over 0.5 seconds
 * cam.update(elapsed);
 * ```
 */
class FunkinCamera
{
  /**
   * Get a singleton instance of the FunkinCamera class.
   */
  public static var instance:FunkinCamera = null;

  /**
   * The main game camera this class controls
   */
  public var camera:FlxCamera;

  //
  // ZOOM INTERVALS
  //

  /**
   * The zoom level the lerp always wants to be.
   * [NOTE] Set this instead of `FlxG.camera.zoom` Directly.
   */
  public var targetZoom:Float = 1.0;

  /**
   * The base zoom for a stage. Beat pulses return towards this.
   */
  public var defaultZoom:Float = 1.0;

  /**
   * How fast the camera lerps toward the targetZoom. 
   * [NOTE] Lower = slower
   */
  public var zoomLerpStrength:Float = 0.05;

  /**
   * Whether the zoom lerping is active.
   * @default false
   */
  public var zoomLerping:Bool = false;

  //
  // FOLLOW INTERVALS
  //

  /**
   * The object the camera smoothly follows.
   */
  public var followTarget:FlxObject = null;

  /**
   * How fast the camera lerps toward the followTarget.
   * [NOTE] Lower = slower
   */
  public var followLerpStrength:Float = 0.04;

  /**
   * Whether the follow lerping is active.
   * @default false
   */
  public var followLerping:Bool = false;

  public function new(camera:FlxCamera, ?defaultZoom:Float = 1.0)
  {
    this.camera = camera;
    this.defaultZoom = defaultZoom;
    this.targetZoom = defaultZoom;
    camera.zoom = defaultZoom;
  }

  //
  // UPDATE LOGIC
  //

  public function update(elapsed:Float)
  {
    if (zoomLerping)
      updateZoomLerp(elapsed);

    if (followLerping && followTarget != null)
      updateFollowLerp(elapsed);
  }

  /**
   * Lerps the camera zoom towards the `targetZoom` each frame.
   */
  private function updateZoomLerp(elapsed:Float):Void
  {
    var lerpSpeed:Float = 1.0 - Math.pow(zoomLerpStrength, elapsed);
    camera.zoom += (targetZoom - camera.zoom) * lerpSpeed;
  }

  /**
   * Lerps camera scroll towards the `followTarget` each frame.
   */
  private function updateFollowLerp(elapsed:Float):Void
  {
    var lerpSpeed:Float = 1.0 - Math.pow(followLerpStrength, elapsed);
    camera.scroll.x += (followTarget.x - camera.scroll.x - camera.width * 0.5) * lerpSpeed;
    camera.scroll.y += (followTarget.y - camera.scroll.y - camera.height * 0.5) * lerpSpeed;
  }

  //
  // ZOOM LOGIC
  //

  /**
   * Instantly sets the target zoom level.
   * @param zoom - The zoom level to set.
   */
  public function setZoom(zoom:Float):Void
  {
    targetZoom = zoom;
    trace('CAMERA: Set zoom event triggered.');
  }

  /**
   * Tweens the target zoom to a new value.
   * @param zoom Target zoom level.
   * @param duration Tween duration in seconds.
   * @param ease Easing Function.
   * @param onComplete Optional callback when the tween is complete.
   */
  public function tweenZoom(zoom:Float, duration:Float, ?ease:EaseFunction, ?onComplete:Void->Void):Void
  {
    if (ease == null)
      ease = FlxEase.quadInOut;

    FlxTween.tween(this, {targetZoom: zoom}, duration, 
    {
      ease: ease,
      onComplete: function(_)
      {
        if (onComplete != null)
          onComplete();
      }
    });

    trace('CAMERA: Tween zoom event triggered.');
  }

  /**
   * Bumps the zoom up by an amount (i.e. on `beatHit` or `stepHit`).
   * The lerp in `update()` will bring it back to the target zoom automatically.
   * @param amount How much to add to `cam.zoom` directly.
   */
  public function bumpZoom(amount:Float):Void
  {
    camera.zoom += amount;
    trace('CAMERA: Bump zoom event triggered.');
  }

  /**
   * Resets the zoom to the default zoom level instantly.
   */
  public function resetZoom():Void
  {
    targetZoom = defaultZoom;
    camera.zoom = defaultZoom;
    trace('CAMERA: Reset zoom event triggered.');
  }

  //
  // FOLLOW LOGIC
  //

  /**
   * Sets the object the camera should follow.
   * @param target The object to follow.
   * @param snap If true, the camera will snap to the target immediately.
   */
  public function setFollow(target:FlxObject, snap:Bool = false):Void
  {
    followTarget = target;
    
    if (snap)
      snapToTarget();

    trace('CAMERA: Set follow event triggered.');
  }

  /**
   * Instantly snaps the camera to the current follow target.
   */
  public function snapToTarget():Void
  {
    // Don't snap if there's no target
    if (followTarget == null)
      return;

    camera.scroll.x = followTarget.x - camera.width * 0.5;
    camera.scroll.y = followTarget.y - camera.height * 0.5;

    trace('CAMERA: Snap to target event triggered.');
  }

  //
  // FADE LOGIC
  //

  /**
  * Fades the camera to a color.
  * @param color The color to fade to.
  * @param duration Duration in seconds.
  * @param fadeIn If true, fades from the color (reverse fade).
  * @param onComplete Optional callback when fade finishes.
  */
  public function fade(color:FlxColor, duration:Float, fadeIn:Bool = false, ?onComplete:Void->Void):Void
  {
    camera.fade(color, duration, fadeIn, onComplete);
    trace('CAMERA: Fade event triggered.');
  }

  /**
   * Fades to a color in discrete steps (pixel-art style).
   * @param color The color to fade to.
   * @param duration Duration in seconds.
   * @param fps Steps per second.
   * @param steps Number of discrete steps.
   * @param fadeIn If true, fades from the color instead.
   * @param onComplete Optional callback when fade finishes.
   */
  public function pixelFade(color:FlxColor, duration:Float, fps:Int, steps:Int, fadeIn:Bool = false, 
    ?onComplete:Void->Void, ?targetState:FlxState):Void
  {
    var overlay:FlxSprite = new FlxSprite(
      -FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, color);
    overlay.scrollFactor.set();
    overlay.alpha = fadeIn ? 1.0 : 0.0;

    var finalState:FlxState = targetState;
    // Get the final state to add the overlay to. Otherwise, add it to the current state.
    if (finalState == null)
    {
      finalState = (FlxG.state != null && FlxG.state.subState != null) ? FlxG.state.subState : FlxG.state;
    }
    if (finalState != null)
    {
      finalState.add(overlay);
    }

    var currentStep:Int = 0;
    
    new FlxTimer().start(duration / steps, function(tmr:FlxTimer)
    {
      currentStep++;

      var progress:Float = currentStep / steps;
      overlay.alpha = fadeIn ? (1.0 - progress) : progress;

      if (currentStep >= steps)
      {
        overlay.alpha = fadeIn ? 0.0 : 1.0;

        if (finalState != null)
          finalState.remove(overlay);

        if (onComplete != null)
          onComplete();
      }
    }, steps);

    trace('CAMERA: Pixel fade event triggered.');
  }

  /**
   * Cancels any active camera fade.
   */
  public function cancelFade():Void
  {
    camera.fade(FlxColor.TRANSPARENT, 0, false);
    trace('CAMERA: Fade event cancelled.');
  }

  //
  // SHAKE LOGIC
  //

  /**
   * Shakes the camera.
   * @param intensity Shake intensity.
   * @param duration Shake duration in seconds.
   */
  public function shake(intensity:Float = 0.005, duration:Float = 0.1):Void
  {
    camera.shake(intensity, duration);
    trace('CAMERA: Shake event triggered.');
  }
}
