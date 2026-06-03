package funkin.gameplay.objects;

import funkin.backend.settings.Options.AccuracyDisplay;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.backend.chart.Section.SwagSection;
import funkin.backend.utils.CoolUtil;
import funkin.backend.utils.Paths;
import funkin.gameplay.PlayState;
import haxe.Json;
import openfl.Assets;

using StringTools;

/**
 * CHARACTER CLASS
 * 
 * This is where all the character's data / information is stored.
 * [!NOTE] The character's origin is at its FEET. (horizontal center, vertical bottom)
 */
class Character extends FlxSprite
{
	/**
	 * The current character's name.
	 */
	public var currentCharacter:String = '';

	/**
	 * The character's animation offsets.
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;

	/**
	 * The character's animation notes.
	 */
	public var animNotes:Array<Dynamic> = [];

	/**
	 * If present, determines whether the character has animations mapped into a .json file, 
	 * 	or anywhere else.
	 */
	public var mappedAnimCharId:String = null;

	public var mappedAnimSongId:String = null;
	public var lastMappedAnimSongPosition:Float = 0;

	/**
	 * Determines whether the character is in the debug build or not.
	 */
	public var debugMode:Bool = false;

	/**
	 * Determines whether the character is being played by the player.
	 */
	public var isPlayer:Bool = false;

	/**
	 * Determine how long a character holds it's current animation.
	 */
	public var holdTimer:Float = 0;

	public var singDuration:Float = 0;

	/**
	 * Whether this character alternates  `danceLeft` and `danceRight` instead of `idle`.
	 */
	public var isDanceCharacter:Bool = false;

	/**
	 * Whether `singLEFT` or `singRIGHT` affect the dance state. (GF Behavior)
	 */
	public var danceTracksDirection:Bool = false;

	/**
	 * Determine whether the character is dancing or not.
	 */
	private var danced:Bool = false;

	/**
	 * The default character, if one isn't specified.
	 */
	static final DEFAULT_CHARACTER:String = 'bf';

	/**
	 * The directory path where `.json` character data is stored.
	 */
	static final CHARACTER_DATA_PATH:String = 'data/characters/';

	/**
	 * Initialize the characters instance.
	 * @param x - Characters X position.
	 * @param y - Characters Y position.
	 * @param character - The specified character.
	 * @param isPlayer - Determines whether the character is being played by the player.
	 */
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		currentCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = FlxG.save.data.antialiasing;

		loadCharacter(currentCharacter);

		dance();
		animation.finish();

		if (isPlayer)
		{
			flipX = !flipX;

			if (!currentCharacter.startsWith('bf'))
			{
				// Swap left and right for non-bf characters.
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				if (animation.getByName('singRIGHTmiss') != null)
				{
					// Apply the same for miss animations.
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	/**
	 * Dynamically load a character's data from a `.json` file, or `.xml` spritesheet.
	 * @param id - The character's name.
	 */
	function loadCharacter(id:String):Void
	{
		var jsonPath = Paths.file(CHARACTER_DATA_PATH + id + '.json', TEXT, 'preload');

		// If the character data exists, automatically load it.
		if (Assets.exists(jsonPath))
		{
			var rawPath = Assets.getText(jsonPath);
			trace('CHARACTER: raw JSON length: ${rawPath.length}');

			var charData:CharacterData = Json.parse(Assets.getText(jsonPath));
			applyCharacterData(charData);
			return;
		}

		// Nothing found; fall back to default.
		trace('CHARACTER: No JSON or spritesheet found for "$id". Falling back to $DEFAULT_CHARACTER.');
		if (id != DEFAULT_CHARACTER)
		{
			currentCharacter = DEFAULT_CHARACTER;
			loadCharacter(DEFAULT_CHARACTER);
		}
		else
		{
			trace('CHARACTER: Default character "$DEFAULT_CHARACTER" has no JSON or spritesheet. Please check your character data.');
		}
	}

	/**
	 * Apply the character's data from a `.json` file.
	 * @param data 
	 */
	function applyCharacterData(data:CharacterData):Void
	{
		trace('CHARACTER: applyCharacterData called for: ' + currentCharacter);
		trace('CHARACTER: assetPath: ' + data.assetPath);
		trace('CHARACTER: animations count: ' + (data.animations != null ? data.animations.length : 0));
		trace('CHARACTER: renderType: ' + data.renderType);

		var library = data.library != null ? data.library : 'shared';

		// Initialize the atlas render type.
		frames = switch (data.renderType)
		{
			// Packer Atlas
			case 'packer':
				Paths.getPackerAtlas(data.assetPath, library);
			// Sparrow Atlas
			default:
				Paths.getSparrowAtlas(data.assetPath, library);
		}

		for (anim in data.animations)
		{
			var fps = anim.frameRate != null ? anim.frameRate : 24;
			var looped = anim.looped == true;

			// Use frame indices if they exist,
			// Otherwise, use the prefix.
			if (anim.frameIndices != null && anim.frameIndices.length > 0)
			{
				animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, '', fps, looped);
			}
			else
				animation.addByPrefix(anim.name, anim.prefix, fps, looped);

			// Use offsets if they exist
			// Otherwise, default to 0, 0
			if (anim.offsets != null && anim.offsets.length >= 2)
			{
				addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
			}
			else
				addOffset(anim.name, 0, 0);
		}

		// Dance / Idle Behavior
		// `danceEvery` is beats between idles; if `danceLeft` and `danceRight` exist, it's a GF-style character.
		isDanceCharacter = animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null;

		// `danceTracksDirection` stays true ONLY for GF-Style characters.
		danceTracksDirection = isDanceCharacter && animation.getByName('singLEFT') != null;

		singDuration = data.singDuration != null ? data.singDuration : 4.0;

		if (data.flipX == true)
			flipX = true;

		// Set the character's hitbox size if the character is a pixel variant.
		if (data.isPixel == true)
		{
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
			antialiasing = false;
		}
		else if (data.scale != null && data.scale != 1.0)
		{
			setGraphicSize(Std.int(width * data.scale));
			updateHitbox();
		}

		// Size trim data for pixel characters (specifically bf-pixel).
		if (data.widthTrim != null)
			width -= data.widthTrim;
		if (data.heightTrim != null)
			height -= data.heightTrim;

		// Get mapped animations dynamically loaded from a `.json` file.
		if (data.mappedAnims != null)
			loadMappedAnims(data.mappedAnims.charId, data.mappedAnims.songId);

		// Initialize the character's start  animation.
		var startingAnimation = data.startingAnimation != null ? data.startingAnimation : 'idle';
		if (animation.getByName(startingAnimation) != null)
			playAnim(startingAnimation);
	}

	override function update(elapsed:Float):Void
	{
		if (!isPlayer)
			updateHoldTimer(elapsed);
		if (!debugMode)
			updateLoopAnim();

		resetMappedAnims();
		updateCharacterSpecific();

		super.update(elapsed);
	}

	/**
	 * Update the character's hold timer for each pose.
	 * @param elapsed 
	 */
	function updateHoldTimer(elapsed:Float):Void
	{
		var currentAnimation = animation.curAnim.name;

		if (animation.curAnim == null)
			return;

		if (currentAnimation.startsWith('sing'))
		{
			holdTimer += elapsed;

			// Get the duration of the current animation in mileseconds.
			var singTimeSec:Float = Conductor.stepCrochet * 0.0015;

			if (holdTimer >= singTimeSec * singDuration)
			{
				holdTimer = 0;
				dance();
			}
		}
	}

	/**
	 * Constantly update the loop animation for characters that have it.
	 */
	function updateLoopAnim():Void
	{
		var loopAnim = animation.curAnim.name + '-loop';

		if (animation.curAnim == null)
			return;
		if (animation.getByName(loopAnim) != null && animation.curAnim.finished)
		{
			playAnim(loopAnim);
		}
	}

	/**
	 * Some characters have different animation behavior, than others...
	 * So, we update the specific ones here :)
	 */
	function updateCharacterSpecific():Void
	{
		switch (currentCharacter)
		{
			// Make a seemless transition between the `hairFall` animation to the ``danceRight`` animation.
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			// Animation data for pico-speaker.
			case 'pico-speaker':
				if (animNotes.length > 0 && Conductor.songPosition > animNotes[0][0])
				{
					// Determine what animation to play depending on the current beat of the song.
					var shotDirection:Int = (animNotes[0][1] >= 2) ? 3 : 1;
					shotDirection += FlxG.random.int(0, 1);
					playAnim('shoot' + shotDirection, true);
					animNotes.shift();
				}

				// Once the animation is finished, loop it.
				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
				}
		}
	}

	public function dance(forced:Bool = false, altAnim:Bool = false):Void
	{
		if (debugMode)
			return;

		// Characters that can't dance (death screens, scripted, etc.)
		switch (currentCharacter)
		{
			case 'bf-pixel-dead' | 'bf-holding-gf-dead' | 'pico-speaker':
				return;
		}

		if (isDanceCharacter)
		{
			if (currentCharacter.startsWith('gf') && animation.curAnim.name.startsWith('hair'))
				return;

			danced = !danced;
			playAnim(danced ? 'danceLeft' : 'danceRight');
		}
		else if (currentCharacter == 'tankman')
		{
			// After tankmans `pretty good` event ends, force him to go right back to idle.
			if (!animation.curAnim.name.endsWith('DOWN-alt'))
				playAnim('idle');
		}
		else
		{
			playAnim(altAnim && animation.getByName('idle-alt') != null ? 'idle-alt' : 'idle', forced);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daAnimOffset = animOffsets.get(AnimName);
		if (daAnimOffset != null)
		{
			offset.set(daAnimOffset[0], daAnimOffset[1]);
		}
		else
		{
			offset.set(0, 0);
		}

		// Track dance state for GF-Style characters.
		if (danceTracksDirection)
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;
			else if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	/**
	 * If a character has animations mapped into a .json file, or anywhere else, load them.
	 * @param charId - The character who has the mapped animations
	 * @param songId - The song that uses the mapped animations
	 */
	function loadMappedAnims(charId:String, songId:String):Void
	{
		mappedAnimCharId = charId;
		mappedAnimSongId = songId;
		animNotes.resize(0);

		var sections:Array<SwagSection> = Song.loadFromJson(charId, songId).notes;
		for (section in sections)
		{
			for (note in section.sectionNotes)
				animNotes.push(note);
		}

		TankmenBG.animationNotes = animNotes;
		animNotes.sort(sortAnims);
		lastMappedAnimSongPosition = Conductor.songPosition;
	}

	/**
	 * In whatever case we need to reset the mapped animations, do so.
	 * @see `loadMappedAnims`
	 */
	function resetMappedAnims():Void
	{
		if (mappedAnimCharId == null || mappedAnimSongId == null)
			return;

		var songPosition = Conductor.songPosition;
		if (songPosition <= 0 && songPosition < lastMappedAnimSongPosition)
			loadMappedAnims(mappedAnimCharId, mappedAnimSongId);
		lastMappedAnimSongPosition = songPosition;
	}

	function sortAnims(x:Dynamic, y:Dynamic):Int
		return x[0] < y[0] ? -1 : x[0] > y[0] ? 1 : 0;

	/**
	 * Quickly add an animation, instead of constantly typing `animation.addByPrefix()`.
	 */
	function quickAnimAdd(name:String, prefix:String):Void
		animation.addByPrefix(name, prefix, 24, false);

	/**
	 * Dynamically add an animation offset.
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];
}
