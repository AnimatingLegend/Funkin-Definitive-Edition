package funkin.gameplay.objects.note;

import flixel.FlxSprite;
import flixel.FlxG;

import funkin.backend.chart.Conductor;
import funkin.gameplay.PlayState;

/**
 * Represents the skin/visual varient a note should use.
 * Decouples stage logic from the note itself.
 */
enum abstract NoteSkin(String) to String
{
	var DEFAULT = "default";
	var PIXEL = "pixel";
}

/**
 * Lightweight data-only struct passed to `Note.setup()`.
 * Keeps the constructor clean and enables object pooling.
 */
typedef NoteData = {
  var strumTime:Float;
  var noteData:Int;
  var sustainLength:Float;
  var isSustainNote:Bool;
  var skin:NoteSkin;
  var ?prevNote:Note;
}

/**
 * NOTE SPRITE CLASS
 * 
 * A single note arrow or sustain segment.
 * 
 * POOLING: Notes are never destroyed mid-song.
 * Call `Note.pool()` to get one, `Note.setup()` to initialize it,
 * and `Note.recycle()` to return it to the pool.
 */
class Note extends FlxSprite
{
	/**
	 * Pool of notes available for reuse.
	 */
	static final _pool:Array<Note> = [];

	/**
	 * Grab a note from the pool (or create one if empty).
	 */
	public static function pool():Note
	{
		return _pool.length > 0 ? _pool.pop() : new Note();
	}

	/**
	 * Call this when leaving `PlayState` to avoid stale graphic references across songs.
	 */
	public static function clearPool():Void
	{
		for (note in _pool) note.destroy();
		_pool.resize(0);
	}

	/**
	 * Return this note to the pool. Resets all state.
	 */
	public function recycle():Void
	{
		reset(0, -9999); // Move offscreen.
		_clear();
		_pool.push(this);
	}

	//
	// LAYOUT CONSTANTS
	//

	public static inline final SWAG_WIDTH:Float = 160 * 0.7;
	public static inline final PIXEL_ZOOM:Float = 6.0; // Matches `PlayState.daPixelZoom`.

	//
	// NOTE COLORS => COLUMN INDEX
	//

	public static inline final COL_LEFT:Int = 0; // purple
  public static inline final COL_DOWN:Int = 1; // blue
  public static inline final COL_UP:Int = 2; // green
  public static inline final COL_RIGHT:Int = 3; // red

	//
	// DATA FIELDS
	//

	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var mustPress:Bool = false;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var altNote:Bool = false;

	public var prevNote:Note = null;
	public var rating:String = 'shit';

	//
	// INTERNAL FIELDS
	//

	var _skin:NoteSkin = DEFAULT;
	var _loadedSkin:NoteSkin = null; // make true once the atlas/graphic is loaded for this skin.

	/**
	 * PRIVATE - Use `Note.pool()` instead.
	 */
	function new() { super(0, -9999); }

	/**
	 * Configure this not with new data.
	 * Loads graphics only when the skin actually changes.
	 * @param data 
	 */
	public function setup(data:NoteData, scrollSpeed:Float):Void
	{
		strumTime = data.strumTime;
		noteData = data.noteData;
		sustainLength = data.sustainLength;
		isSustainNote = data.isSustainNote;
		prevNote = data.prevNote != null ? data.prevNote : this;
		_skin = data.skin;

		// Reset hit state
		canBeHit = false;
		tooLate = false;
		wasGoodHit = false;
		willMiss = false;
		ignoreNote = false;
		hitCausesMiss = false;
		altNote = false;
		rating = "shit";
		alpha = 1.0;

		_loadGraphics();
		_scaleSustain(scrollSpeed);
	}

	//
	// INITIALIZE GRAPHICS
	//

	static final ANIM_SCROLL = ["purpleScroll", "blueScroll", "greenScroll", "redScroll"];
  static final ANIM_HOLD = ["purplehold", "bluehold", "greenhold", "redhold"];
  static final ANIM_HOLDEND = ["purpleholdend", "blueholdend", "greenholdend", "redholdend"];

	function _loadGraphics():Void
	{
		if (_loadedSkin != _skin)
		{
			_loadedSkin = _skin;
			switch (_skin)
			{
				case PIXEL: 
					_loadPixelGraphics();
				default: 
					_loadDefaultGraphics();
			}
		}
		else _playNoteAnim(); // Skin is already loaded, just play the correct skin.
	}

	function _loadDefaultGraphics():Void
	{
		frames = Paths.getSparrowAtlas('NOTE_assets');

		animation.addByPrefix('purpleScroll', 'purple instance');
		animation.addByPrefix('blueScroll', 'blue instance');
		animation.addByPrefix('greenScroll', 'green instance');
		animation.addByPrefix('redScroll', 'red instance');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('blueholdend', 'blue hold end');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = FlxG.save.data.antialiasing;

		_playNoteAnim();
	}

	function _loadPixelGraphics():Void
	{
		if (!isSustainNote)
		{
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
			animation.add('purpleScroll', [4]);
			animation.add('blueScroll', [5]);
			animation.add('greenScroll', [6]);
			animation.add('redScroll', [7]);
		}
		else
		{
			loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);
			animation.add('purpleholdend', [4]);
			animation.add('blueholdend', [5]);
			animation.add('greenholdend', [6]);
			animation.add('redholdend', [7]);
			animation.add('purplehold', [0]);
			animation.add('bluehold', [1]);
			animation.add('greenhold', [2]);
			animation.add('redhold', [3]);
		}

		setGraphicSize(Std.int(width * PIXEL_ZOOM));
		updateHitbox();
		antialiasing = false;

		_playNoteAnim();
	}

	inline function _playNoteAnim():Void
	{
		final col = noteData % 4;

		if (!isSustainNote) animation.play(ANIM_SCROLL[col]);
		else
		{
			// Kade Engine moment lol
			if (FlxG.save.data.downscroll) flipY = true;

			animation.play(ANIM_HOLDEND[col]);
			updateHitbox();
			alpha = 0.8;

			if (_skin == PIXEL) x += 30;

			// Tell the previous note to switch to its hold-piece animation.
			if (prevNote != null && prevNote != this && prevNote.isSustainNote)
			{
				prevNote.animation.play(ANIM_HOLD[prevNote.noteData % 4]);
			}
		}
	}

	/**
	 * Scales the sustain note to match the scroll speed.
	 * @see PlayState - x and y axis for strumline notes will be specifically handled there.
	 * @param scrollSpeed 
	 */
	function _scaleSustain(scrollSpeed:Float):Void
	{
		if (!isSustainNote) return;
		if (prevNote == null || prevNote == this || !prevNote.isSustainNote) return;

		scrollSpeed = FlxMath.roundDecimal(scrollSpeed, 2);

		prevNote.scale.y = (0.45 * Conductor.stepCrochet * scrollSpeed + 2) / prevNote.frameHeight;
		prevNote.updateHitbox();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!mustPress)
		{
			// For opponent notes, automatically hit them when the strumTime is reached.
			if (!wasGoodHit && strumTime <= Conductor.songPosition) wasGoodHit = true;
			return;
		}

		// Already hit, so do nothing.
		if (tooLate || wasGoodHit) return;

		if (willMiss)
		{
			tooLate = true;
			canBeHit = false;
			if (alpha > 0.3) alpha = 0.3;
			return;
		}

		final songPos = Conductor.songPosition;
		final safeZone = Conductor.safeZoneOffset;

		// Check if the note has been hit, or if it's too late to be hit.
		if (strumTime > songPos - safeZone && strumTime < songPos + 0.7 * safeZone) canBeHit = true;
		else if (strumTime <= songPos - safeZone)
		{
			willMiss = true;
			canBeHit = true;
		}
	}

	/**
	 * Reset all fields to default without touching the graphics.
	 */
	function _clear():Void
	{
		strumTime = 0;
		noteData = 0;
		sustainLength = 0;
		isSustainNote = false;
		mustPress = false;
		canBeHit = false;
		tooLate = false;
		wasGoodHit = false;
		willMiss = false;
		ignoreNote = false;
		hitCausesMiss = false;
		altNote = false;
		prevNote = null;
		rating = "shit";
		alpha = 1.0;
		angle = 0;
		scale.set(1, 1);
		clipRect = null;
	}
}
