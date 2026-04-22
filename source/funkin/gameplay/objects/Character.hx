package funkin.gameplay.objects;

import funkin.backend.chart.Section.SwagSection;
import funkin.backend.utils.CoolUtil;
import funkin.backend.utils.Paths;

import funkin.gameplay.PlayState;

using StringTools;

/**
 * CHARACTER CLASS
 * 
 * This is where all the character's data /  information is stored.
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
	public var animOffsets:Map<String, Array <Dynamic>>;

	/**
	 * The character's animation notes.
	 */
	public var animNotes:Array<Dynamic> = [];

	/**
	 * Determines whether the character is in the debug build or not.
	 */
	public var debugMode:Bool = false;

	/**
	 * Determines whether the character is being played by the player.
	 */
	public var isPlayer:Bool = false;

	/**
	 * Get the health bar color for a specific character.
	 */
	public var HEALTH_BAR_COLOR:FlxColor;

	/**
	 * Determine how long a character holds it's current animation.
	 */
	public var holdTimer:Float = 0;
	public var singDuration:Float = 4;

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
	 * Initialize the characters instance.
	 * @param x - Characters X position.
	 * @param y - Characters Y position.
	 * @param character - The specified character.
	 * @param isPlayer - Determines whether the character is being played by the player.
	 */
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array <Dynamic>>();
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
	 * All hardcoded character setup lives here.
	 * This entire function will be replaced with JSON loading in the softcoding pass very soon.
	 * @param id - The character's name.
	 */
	function loadCharacter(id:String):Void
	{
		switch (id)
		{
			case 'gf' | 'gf-christmas':
				var assetFile = (id == 'gf') ? 'characters/GF_assets' : 'characters/gfChristmas';
				frames = Paths.getSparrowAtlas(assetFile, 'shared');
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0,1,2,3,4,5,6,7,8,9,10,11,12], "", 24, id == 'gf');
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0,1,2,3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0,1,2,3,4,5,6,7,8,9,10,11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);
				loadOffsetFile(id);
				playAnim('danceRight');
				isDanceCharacter = true;
				danceTracksDirection = true;
				HEALTH_BAR_COLOR = 0xED790135;
				singDuration = 4.2;

			case 'gf-car':
				frames = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				animation.addByIndices('idleHair', 'GF Dancing Beat Hair blowing CAR', [10,11,12,25,26,27], "", 24, true);
				loadOffsetFile(id);
				playAnim('danceRight');
				HEALTH_BAR_COLOR = 0xED790135;
				isDanceCharacter = true;
				singDuration = 4.2;

			case 'gf-pixel':
				frames = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				loadOffsetFile(id);
				playAnim('danceRight');
				HEALTH_BAR_COLOR = 0xED790135;
				isDanceCharacter = true;
				singDuration = 4.2;
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
				animation.addByIndices('sad', 'GF Crying at Gunpoint ', [0,1,2,3,4,5,6,7,8,9,10,11,12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				loadOffsetFile(id);
				playAnim('danceRight');
				HEALTH_BAR_COLOR = 0xED790135;
				isDanceCharacter = true;
				singDuration = 4.2;

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker', 'shared');
				quickAnimAdd('shoot1', "Pico shoot 1");
				quickAnimAdd('shoot2', "Pico shoot 2");
				quickAnimAdd('shoot3', "Pico shoot 3");
				quickAnimAdd('shoot4', "Pico shoot 4");
				loadOffsetFile(id);
				playAnim('shoot1');
				HEALTH_BAR_COLOR = 0xFFb7d855;
				loadMappedAnims('picospeaker', 'stress');

			case 'dad':
				frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFaf66ce;
				singDuration = 6.1;

			case 'spookyKids':
				frames = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				quickAnimAdd('singUP', 'spooky UP NOTE');
				quickAnimAdd('singDOWN', 'spooky DOWN note');
				quickAnimAdd('singLEFT', 'note sing left');
				quickAnimAdd('singRIGHT', 'spooky sing right');
				quickAnimAdd('singUP-alt', 'spooky kids YEAH!!');
				animation.addByIndices('danceLeft', 'spooky dance idle', [0,2,6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8,10,12,14], "", 12, false);
				loadOffsetFile(id);
				HEALTH_BAR_COLOR = 0xFFd57e00;
				isDanceCharacter = true;
				singDuration = 4.2;

			case 'mom':
				frames = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				quickAnimAdd('singRIGHT', 'Mom Pose Left'); // NOTE: sprite name is misleading, this is actually right
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFd8558e;

			case 'mom-car':
				frames = Paths.getSparrowAtlas('characters/momCar', 'shared');
				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				quickAnimAdd('singRIGHT', 'Mom Pose Left'); // NOTE: sprite name is misleading, this is actually right
				animation.addByIndices('idle-loop', "Mom Idle", [10,11,12,13], "", 24, true);
				animation.addByIndices('singUP-loop', "Mom Up Pose", [10,11,12,13], "", 24, true);
				animation.addByIndices('singDOWN-loop', "MOM DOWN POSE", [10,11,12,13], "", 24, true);
				animation.addByIndices('singLEFT-loop', 'Mom Left Pose', [5,6,7,8], "", 24, true);
				animation.addByIndices('singRIGHT-loop', 'Mom Pose Left', [5,6,7,8], "", 24, true);
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFd8558e;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				quickAnimAdd('idle', 'Parent Christmas Idle');
				quickAnimAdd('singUP', 'Parent Up Note Dad');
				quickAnimAdd('singDOWN', 'Parent Down Note Dad');
				quickAnimAdd('singLEFT', 'Parent Left Note Dad');
				quickAnimAdd('singRIGHT', 'Parent Right Note Dad');
				quickAnimAdd('singUP-alt', 'Parent Up Note Mom');
				quickAnimAdd('singDOWN-alt', 'Parent Down Note Mom');
				quickAnimAdd('singLEFT-alt', 'Parent Left Note Mom');
				quickAnimAdd('singRIGHT-alt', 'Parent Right Note Mom');
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0x86f800df;

			case 'monster' | 'monster-christmas':
				var assetFile = (id == 'monster') ? 'characters/Monster_Assets' : 'characters/monsterChristmas';
				frames = Paths.getSparrowAtlas(assetFile, 'shared');
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster Right note'); // NOTE: poses are flipped in the spritesheet
				quickAnimAdd('singRIGHT', 'Monster left note');
				animation.addByIndices('idle-loop', 'monster idle', [10,11,12,13], '', 24, true);
				animation.addByIndices('singUP-loop', 'monster up note', [10,11,12,13], '', 24, true);
				animation.addByIndices('singDOWN-loop', 'monster down', [10,11,12,13], '', 24, true);
				animation.addByIndices('singLEFT-loop', 'monster Right note', [10,11,12,13], '', 24, true);
				animation.addByIndices('singRIGHT-loop', 'monster left note', [10,11,12,13], '', 24, true);
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFf3ff6e;

			case 'pico':
				frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				quickAnimAdd('idle', "Pico Idle Dance");
				quickAnimAdd('singUP', 'pico Up note0');
				quickAnimAdd('singDOWN', 'Pico Down Note0');
				quickAnimAdd('singLEFT', 'Pico Note Right0');
				quickAnimAdd('singRIGHT', 'Pico NOTE LEFT0');
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFb7d855;
				flipX = true;

			case 'bf' | 'bf-christmas' | 'bf-car' | 'bf-holding-gf':
				var assetMap = [
					'bf'           => 'characters/BOYFRIEND',
					'bf-christmas' => 'characters/bfChristmas',
					'bf-car'       => 'characters/bfCar',
					'bf-holding-gf'=> 'characters/bfAndGF'
				];

				frames = Paths.getSparrowAtlas(assetMap[id], 'shared');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');

				if (id == 'bf' || id == 'bf-christmas') quickAnimAdd('hey!', 'BF HEY');

				if (id == 'bf')
				{
					quickAnimAdd('firstDeath', "BF dies");
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					quickAnimAdd('deathConfirm', "BF Dead confirm");
					animation.addByPrefix('scared', 'BF idle shaking', 24);
				}

				if (id == 'bf-car')
				{
					animation.addByIndices('idle-loop', 'BF idle dance', [10,11,12,13], '', 24, true);
					animation.addByIndices('singUP-loop', 'BF NOTE UP0', [10,11,12,13], '', 24, true);
					animation.addByIndices('singDOWN-loop', 'BF NOTE DOWN0', [10,11,12,13], '', 24, true);
					animation.addByIndices('singRIGHT-loop', 'BF NOTE RIGHT0', [10,11,12,13], '', 24, true);
					animation.addByIndices('singLEFT-loop', 'BF NOTE LEFT0', [10,11,12,13], '', 24, true);
				}

				if (id == 'bf-holding-gf') quickAnimAdd('Catch', 'BF catches GF');

				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFF31b0d1;
				flipX = true;

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				quickAnimAdd('idle', 'BF IDLE');
				quickAnimAdd('singUP', 'BF UP NOTE');
				quickAnimAdd('singDOWN', 'BF DOWN NOTE');
				// [!NOTE] Left/right are flipped on opponent side
				quickAnimAdd('singRIGHT', isPlayer ? 'BF RIGHT NOTE' : 'BF LEFT NOTE');
				quickAnimAdd('singLEFT',  isPlayer ? 'BF LEFT NOTE'  : 'BF RIGHT NOTE');
				if (isPlayer)
				{
					quickAnimAdd('singUPmiss', 'BF UP MISS');
					quickAnimAdd('singLEFTmiss', 'BF LEFT MISS');
					quickAnimAdd('singRIGHTmiss', 'BF RIGHT MISS');
					quickAnimAdd('singDOWNmiss', 'BF DOWN MISS');
				}
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				width -= 100;
				height -= 100;
				loadOffsetFile(id);
				playAnim('idle');
				flipX = true;
				HEALTH_BAR_COLOR = 0xFF31b0d1;
				antialiasing = false;

			case 'bf-pixel-dead' | 'bf-holding-gf-dead':
				var assetFile = (id == 'bf-pixel-dead') ? 'characters/bfPixelsDEAD' : 'characters/bfHoldingGF-DEAD';
				frames = Paths.getSparrowAtlas(assetFile, 'shared');
				if (id == 'bf-pixel-dead')
				{
					quickAnimAdd('firstDeath', "BF Dies pixel");
					animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
					quickAnimAdd('deathConfirm', "RETRY CONFIRM");
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
				}
				else
				{
					quickAnimAdd('firstDeath', 'BF Dies with GF');
					animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, true);
					quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');
				}
				loadOffsetFile(id);
				playAnim('firstDeath');
				flipX = true;
				HEALTH_BAR_COLOR = 0xFF31b0d1;

			case 'senpai' | 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				var prefix = (id == 'senpai-angry') ? 'Angry Senpai' : 'Senpai';
				quickAnimAdd('idle', '$prefix Idle');
				quickAnimAdd('singUP', '$prefix UP NOTE');
				quickAnimAdd('singLEFT', '$prefix LEFT NOTE');
				quickAnimAdd('singRIGHT', '$prefix RIGHT NOTE');
				quickAnimAdd('singDOWN', '$prefix DOWN NOTE');
				loadOffsetFile(id);
				if (id == 'senpai-angry') playAnim('idle');
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				HEALTH_BAR_COLOR = 0xFFffaa6f;
				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				quickAnimAdd('idle', "idle spirit_");
				quickAnimAdd('singUP', "up_");
				quickAnimAdd('singRIGHT', "right_");
				quickAnimAdd('singLEFT', "left_");
				quickAnimAdd('singDOWN', "spirit down_");
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFff3c6e;
				antialiasing = false;

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
				quickAnimAdd('idle', "Tankman Idle Dance");
				animation.addByIndices('singUP',    'Tankman UP note',     [10000,10001,10002,10003,10004,10005,10006,10007,10008,10009], '', 24, false);
				animation.addByIndices('singDOWN',  'Tankman DOWN note',   [10000,10001,10002,10003,10004,10005,10006,10007,10008,10009], '', 24, false);
				animation.addByIndices('singLEFT',  'Tankman Right Note',  [10000,10001,10002,10003,10004,10005,10006,10007,10008,10009], '', 24, false);
				animation.addByIndices('singRIGHT', 'Tankman Note Left',   [10000,10001,10002,10003,10004,10005,10006,10007],             '', 24, false);
				quickAnimAdd('singUP-alt', 'TANKMAN UGH');
				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD tankman');
				loadOffsetFile(id);
				playAnim('idle');
				HEALTH_BAR_COLOR = 0xFFFFFFFF;
				flipX = true;

		}
	}

	override function update(elapsed:Float):Void 
	{
		if (!isPlayer) updateHoldTimer(elapsed);
		
		if (!debugMode) updateLoopAnim();

		updateCharacterSpecific();

		super.update(elapsed);
	}

	/**
	 * Update the character's hold timer for each pose.
	 * @param elapsed 
	 */
	function updateHoldTimer(elapsed:Float):Void
	{
		if (animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;

		if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
		{
			dance();
			holdTimer = 0;
		}
	}

	/**
	 * Constantly update the loop animation for characters that have it.
	 */
	function updateLoopAnim():Void
	{
		var loopAnim = animation.curAnim.name + '-loop';

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
			case 'gf': if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished) playAnim('danceRight');
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
		if (debugMode) return;

		// Characters that can't dance (death screens, scripted, etc.)
		switch (currentCharacter)
		{
			case 'bf-pixel-dead' | 'bf-holding-gf-dead' | 'pico-speaker': return;
		}

		if (isDanceCharacter)
		{
			if (currentCharacter.startsWith('gf') && animation.curAnim.name.startsWith('hair')) return;

			danced = !danced;
			playAnim(danced ? 'danceLeft' : 'danceRight');
		}
		else if (currentCharacter == 'tankman')
		{
			// After tankmans `pretty good` event ends, force him to go right back to idle.
			if (!animation.curAnim.name.endsWith('DOWN-alt')) playAnim('idle');
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
			if (AnimName == 'singLEFT') danced = true;
			else if (AnimName == 'singRIGHT') danced = false;
			else if (AnimName == 'singUP' || AnimName == 'singDOWN') danced = !danced;
		}
	}

	/**
	 * If a character has animations mapped into a .json file, or anywhere else, load them.
	 * @param charId - The character who has the mapped animations
	 * @param songId - The song that uses the mapped animations
	 */
	function loadMappedAnims(charId:String, songId:String):Void
	{
		var sections:Array<SwagSection> = Song.loadFromJson(charId, songId).notes;
		for (section in sections)
		{
			for (note in section.sectionNotes) animNotes.push(note);
		}

		TankmenBG.animationNotes = animNotes;
		animNotes.sort(sortAnims);
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

	/**
	 * Create an offset file for a specific characters animation offsets.
	 */
	public function loadOffsetFile(offsetCharacter:String):Void
	{
		var filePath:Array<String> = CoolUtil.coolTextFile(Paths.file('images/characters/character-offsets/' + offsetCharacter + 'Offsets.txt', 'shared'));
		for (index in filePath)
		{
			var split:Array<String> = index.split(' ');
			addOffset(split[0], Std.parseInt(split[1]), Std.parseInt(split[2]));
		}
	}
}
