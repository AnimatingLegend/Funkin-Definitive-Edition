package objects;

import flixel.util.FlxColor;
import flixel.FlxG;
import backend.Section.SwagSection;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;

	public var holdTimer:Float = 0;
	public var singDuration:Float = 4;

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)

	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			case 'gf':
				tex = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('idleHair', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], "", 24, true);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');
				barColor = 0xED790135;

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
				animation.addByIndices('sad', 'GF Crying at Gunpoint ', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');
				barColor = 0xED790135;

			case 'pico-speaker':
				
				tex = Paths.getSparrowAtlas('characters/picoSpeaker', 'shared');
				frames = tex;

				quickAnimAdd('shoot1', "Pico shoot 1");
				quickAnimAdd('shoot2', "Pico shoot 2");
				quickAnimAdd('shoot3', "Pico shoot 3");
				quickAnimAdd('shoot4', "Pico shoot 4");

				loadOffsetFile(curCharacter);
				playAnim('shoot1');
	
				barColor = 0xFFb7d855;

				loadMappedAnims();

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFaf66ce;

			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				frames = tex;
				quickAnimAdd('singUP', 'spooky UP NOTE');
				quickAnimAdd('singDOWN', 'spooky DOWN note');
				quickAnimAdd('singLEFT', 'note sing left');
				quickAnimAdd('singRIGHT', 'spooky sing right');
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd57e00;

			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				frames = tex;

				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFd8558e;

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar', 'shared');
				frames = tex;

				quickAnimAdd('idle', "Mom Idle");
				quickAnimAdd('singUP', "Mom Up Pose");
				quickAnimAdd('singDOWN', "MOM DOWN POSE");
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');

				animation.addByIndices('idle-loop', "Mom Idle", [10, 11, 12, 13], "", 24, true);
				animation.addByIndices('singUP-loop', "Mom Up Pose", [10, 11, 12, 13], "", 24, true);
				animation.addByIndices('singDOWN-loop', "MOM DOWN POSE", [10, 11, 12, 13], "", 24, true);
				animation.addByIndices('singLEFT-loop', 'Mom Left Pose', [5, 6, 7, 8], "", 24, true);
				animation.addByIndices('singRIGHT-loop', 'Mom Pose Left', [5, 6, 7, 8], "", 24, true);
				
				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFd8558e;

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

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0x86f800df;

			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				// loop anims
				animation.addByIndices('idle-loop', 'monster idle', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singUP-loop', 'monster up note', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singDOWN-loop', 'monster down', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singLEFT-loop', 'monster left note', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singRIGHT-loop', 'monster Right note', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFf3ff6e;

			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				// loop anims
				animation.addByIndices('idle-loop', 'monster idle', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singUP-loop', 'monster up note', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singDOWN-loop', 'monster down', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singLEFT-loop', 'monster left note', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singRIGHT-loop', 'monster Right note', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFf3ff6e;

			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				quickAnimAdd('idle', "Pico Idle Dance");
				quickAnimAdd('singUP', 'pico Up note0');
				quickAnimAdd('singDOWN', 'Pico Down Note0');
				quickAnimAdd('singLEFT', 'Pico Note Right0');
				quickAnimAdd('singRIGHT', 'Pico NOTE LEFT0');

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFb7d855;

				flipX = true;

			case 'pico-player':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				quickAnimAdd('idle', "Pico Idle Dance");
				quickAnimAdd('singUP', 'pico Up note0');
				quickAnimAdd('singDOWN', 'Pico Down Note0');
				quickAnimAdd('singLEFT', 'Pico NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'Pico Note Right0');

				// Miss anims
				quickAnimAdd('singUPmiss', 'pico Up note miss');
				quickAnimAdd('singDOWNmiss', 'Pico Down Note MISS');
				quickAnimAdd('singRIGHTmiss', 'Pico Note Right Miss');
				quickAnimAdd('singLEFTmiss', 'Pico NOTE LEFT miss');

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFFb7d855;

				flipX = true;

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');

				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				
				quickAnimAdd('hey', 'BF HEY');

				quickAnimAdd('firstDeath', "BF dies");
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				quickAnimAdd('deathConfirm', "BF Dead confirm");

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFF31b0d1;

				flipX = true;

			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('hey', 'BF HEY');

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFF31b0d1;

				flipX = true;

			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');

				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');

				animation.addByIndices('idle-loop', 'BF idle dance', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singUP-loop', 'BF NOTE UP0', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singDOWN-loop', 'BF NOTE DOWN0', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singRIGHT-loop', 'BF NOTE RIGHT0', [10, 11, 12, 13], '', 24, true);
				animation.addByIndices('singLEFT-loop', 'BF NOTE LEFT0', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xFF31b0d1;

				flipX = true;

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				quickAnimAdd('idle', 'BF IDLE');
				quickAnimAdd('singUP', 'BF UP NOTE');
				if (!isPlayer)
				{
					quickAnimAdd('singRIGHT', 'BF LEFT NOTE');
					quickAnimAdd('singLEFT', 'BF RIGHT NOTE');
				}
				else
				{
					quickAnimAdd('singLEFT', 'BF LEFT NOTE');
					quickAnimAdd('singRIGHT', 'BF RIGHT NOTE');

					quickAnimAdd('singUPmiss', 'BF UP MISS');
					quickAnimAdd('singLEFTmiss', 'BF LEFT MISS');
					quickAnimAdd('singRIGHTmiss', 'BF RIGHT MISS');
					quickAnimAdd('singDOWNmiss', 'BF DOWN MISS');
				}
				quickAnimAdd('singDOWN', 'BF DOWN NOTE');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				loadOffsetFile(curCharacter);
				playAnim('idle');

				width -= 100;
				height -= 100;

				flipX = true;
				barColor = 0xFF31b0d1;
				antialiasing = false;

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				quickAnimAdd('firstDeath', "BF Dies pixel");
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				quickAnimAdd('deathConfirm', "RETRY CONFIRM");
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				flipX = true;
				barColor = 0xFF31b0d1;
				antialiasing = false;

			case 'bf-holding-gf':
				
				frames = Paths.getSparrowAtlas('characters/bfAndGF', 'shared');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singUP', 'BF NOTE UP0');

				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');

				quickAnimAdd('Catch', 'BF catches GF');

				loadOffsetFile(curCharacter);
				playAnim('idle');
	
				flipX = true;
				barColor = 0xFF31b0d1;

			case 'bf-holding-gf-dead':

				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD', 'shared');
				quickAnimAdd('firstDeath', 'BF Dies with GF');
				animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, true);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');

				flipX = true;
				barColor = 0xFF31b0d1;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				quickAnimAdd('idle', 'Senpai Idle');
				quickAnimAdd('singUP', 'SENPAI UP NOTE');
				quickAnimAdd('singLEFT', 'SENPAI LEFT NOTE');
				quickAnimAdd('singRIGHT', 'SENPAI RIGHT NOTE');
				quickAnimAdd('singDOWN', 'SENPAI DOWN NOTE');

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				barColor = 0xFFffaa6f;
				antialiasing = false;

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				quickAnimAdd('idle', 'Angry Senpai Idle');
				quickAnimAdd('singUP', 'Angry Senpai UP NOTE');
				quickAnimAdd('singLEFT', 'Angry Senpai LEFT NOTE');
				quickAnimAdd('singRIGHT', 'Angry Senpai RIGHT NOTE');
				quickAnimAdd('singDOWN', 'Angry Senpai DOWN NOTE');

				loadOffsetFile(curCharacter);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				barColor = 0xFFffaa6f;
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

				barColor = 0xFFff3c6e;
				loadOffsetFile(curCharacter);
				playAnim('idle');
				antialiasing = false;

			case 'tankman':
				tex = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
				frames = tex;
				quickAnimAdd('idle', "Tankman Idle Dance");
				quickAnimAdd('singUP', 'Tankman UP note ');
				quickAnimAdd('singDOWN', 'Tankman DOWN note ');
				quickAnimAdd('singLEFT', 'Tankman Right Note ');
				quickAnimAdd('singRIGHT', 'Tankman Note Left ');
	
				quickAnimAdd('singUP-alt', 'TANKMAN UGH instance');
				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD');
	
				loadOffsetFile(curCharacter);
				playAnim('idle');
				barColor = 0xff000000;
				flipX = true;
		}

		dance();
		animation.finish();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !curCharacter.startsWith('pico-player'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	function loadMappedAnims()
	{
		var sections:Array<SwagSection> = backend.Song.loadFromJson('picospeaker', 'stress').notes;
		for (section in sections)
		{
			for (note in section.sectionNotes)
			{
				animationNotes.push(note);
			}
		}
		states.stages.backgroundsprites.TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
	
			if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (!debugMode)
		{
			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
					
			case 'pico-speaker':
				if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var shotDirection:Int = 1;
					if (animationNotes[0][1] >= 2)
					{
						shotDirection = 3;
					}
					shotDirection += FlxG.random.int(0, 1);
						
					playAnim('shoot' + shotDirection, true);
					animationNotes.shift();
				}

				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
				}
		}
	
		super.update(elapsed);
	}

	private var danced:Bool = false;

 	// FOR GF DANCING SHIT
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel' | 'gf-tankmen':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;
	
						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				// These do nothing, just added these here so i wont get annoying debug errors
				case 'bf-pixel-dead':
					// a
				case 'bf-holding-gf-dead':
					// a
				case 'pico-speaker':
					// a
				case 'spooky':
					danced = !danced;
	
					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				case 'tankman':
					if (!animation.curAnim.name.endsWith('DOWN-alt'))
						playAnim('idle');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	function sortAnims(x, y)
	{
		return x[0] < y[0] ? -1 : x[0] > y[0] ? 1 : 0;
	}

	function quickAnimAdd(name:String, prefix:String)
	{
		animation.addByPrefix(name, prefix, 24, false);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function loadOffsetFile(offsetCharacter:String)
	{
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file("images/characters/character-offsets/" + offsetCharacter + "Offsets.txt"));
		
		for (i in daFile)
		{
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}
}
