package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		
		this.isBold = false;
		this.splitWords = [];
		this.xPosResetted = lastWasSpace = false;
		this.yMulti = 1;
		this.text = _finalText = "";
		this.isMenuItem = false;
		this.targetY = 0;
		super(x, y);
		this.text = _finalText = text;
		this.isBold = bold;
		if(text != "")
		{
			typed ? startTypedText() : addText();
		}
	}

	public function addText()
	{
		doSplitWords();
		var a:Float = 0;
		var b:Int = 0;
		var c:Array<String> = splitWords;
		for (i in 0 ... c.length) 
		{
			if(b < c.length)
			{
				var d:String = c[b];
				b++;
				if(d == " " || d == "-")
				{
					lastWasSpace = true;
				}
				var isNumber:Bool = AlphaCharacter.numbers.indexOf(d) != -1;
				var isSymbol:Bool = AlphaCharacter.symbols.indexOf(d) != -1;
				var isAlphabet:Bool = AlphaCharacter.alphabet.indexOf(d.toLowerCase()) != -1;
				if((isAlphabet || isSymbol || isNumber))
				{
					if(lastSprite != null) a = lastSprite.x + lastSprite.width;
					if(lastWasSpace)
					{
						a += 40;
						lastWasSpace = false;
					}
					var e:AlphaCharacter = new AlphaCharacter(a,0);
					if(isBold)
					{
						if (isNumber)
						{
							e.createNumber(d);
						}
						else if (isSymbol)
						{
							e.createSymbol(d);
						}
						else
						{
							e.createBold(d);
						}
						
					}
					else
					{
						if (isNumber)
						{
							e.createNumber(d);
						}
						else if (isSymbol)
						{
							e.createSymbol(d);
						}
						else
						{
							e.createLetter(d);
						}
						
					}
					add(e);
					lastSprite = e;
				}
			}
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();
		var b:Int = 0;
		var c:Float = 0;
		var d:Int = 0;

		new FlxTimer().start(0.05, function(e:FlxTimer)
		{
			if(_finalText.fastCodeAt(b) == 10)
			{
				yMulti += 1;
				xPosResetted = true;
				c = 0;
				d += 1;
			}
			if(splitWords[b] == " ")
			{
				lastWasSpace = true;
			}
			
			
			var f:Bool = AlphaCharacter.numbers.indexOf(splitWords[b]) != -1;
			var h:Bool = AlphaCharacter.symbols.indexOf(splitWords[b]) != -1;
			
			
			if(AlphaCharacter.alphabet.indexOf(splitWords[b].toLowerCase()) != -1 || f || h)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					c += lastSprite.width + 3;
				}
				else
				{
					xPosResetted = false;
				}
				if(lastWasSpace)
				{
					c += 20;
					lastWasSpace = false;
				}

				var m:AlphaCharacter = new AlphaCharacter(c, 55 * yMulti);
				m.row = d;
				if (isBold)
				{
					m.createBold(splitWords[b]);
				}
				else
				{
					if (f)
					{
						m.createNumber(splitWords[b]);
					}
					else if (h)
					{
						m.createSymbol(splitWords[b]);
					}
					else
					{
						m.createLetter(splitWords[b]);
					}

					m.x += 90;
				}
				
				if(FlxG.random.float(0, 100) < 45)
				{
					FlxG.sound.play(Paths.sound("GF_" + FlxG.random.int(1, 4), null));
				}
				add(m);
				lastSprite = m;
			}
			b += 1;
			e.time = FlxG.random.float(0.04, 0.09);
		}, this.splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = CoolUtil.coolLerp(y, 120 * scaledY + 0.48 * FlxG.height, 0.16);
			x = CoolUtil.coolLerp(x, 20 * targetY + 90, 0.16);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		row = 0;
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = FlxG.save.data.lowData;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}
		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();
		
		y = (80 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);
		updateHitbox();
		y = (80 - height);
		y += row * 60;
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				y += 65;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			case ":":
				animation.addByPrefix(letter, ":", 24);
				y += 40;
		/*	case "-":
				animation.addByPrefix(letter, "-", 24);
				y += 30;
				x -= 40;
		*/		
			default:
				animation.addByPrefix(letter, letter, 24);
				
		}
		animation.play(letter);

		updateHitbox();
	}
}