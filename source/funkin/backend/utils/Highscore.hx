package funkin.backend.utils;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songRatings:Map<String, Float> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	public static var songRatings:Map<String, Float> = new Map<String, Float>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!PlayState.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score) setScore(daSong, score);
			}
			else setScore(daSong, score);
		}
		else
		{
			trace('WARNING: BotPlay detected. Score saving is disabled.');
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong('week' + week, diff);

		if (!PlayState.botplay)
		{
			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score) setScore(daWeek, score);
			}
			else setScore(daWeek, score);
		}
		else
		{
			trace('WARNING: BotPlay detected. Score saving is disabled.');
		}
	}

	public static function saveCombo(song:String, combo:String = "N/A", ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!PlayState.botplay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo)) 
				{
					setCombo(daSong, finalCombo);
				}
			}
			else
			{
				setCombo(daSong, finalCombo);
			}
		}
		else
		{
			trace('WARNING: BotPlay detected. Combo saving is disabled.');
		}
	}

	public static function saveRating(song:String, accuracy:Float = 0.00, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!PlayState.botplay)
		{
			if (songRatings.exists(daSong))
			{
				if (songRatings.get(daSong) < accuracy) setRating(daSong, accuracy);
			}
			else setRating(daSong, accuracy);
		}
		else
		{
			trace('WARNING: BotPlay detected. Rating saving is disabled.');
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRatings.set(song, rating);
		FlxG.save.data.songRatings = songRatings;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
		{
			daSong += '-easy';
		}
		else if (diff == 2)
		{
			daSong += '-hard';
		}

		return daSong;
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			case 'SDCB': return 1;
			case 'FC': return 2;
			case 'GFC': return 3;
			case 'MFC': return 4;
			default: return 0;
		}
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		
		if (!songScores.exists(daSong))
		{
			setScore(daSong, 0);
		}

		return songScores.get(daSong);
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		var daWeek:String = formatSong('week' + week, diff);

		if (!songScores.exists(daWeek))
		{
			setScore(daWeek, 0);
		}

		return songScores.get(daWeek);
	}

	public static function getCombo(song:String, diff:Int):String
	{
		var daSong:String = formatSong(song, diff);

		if (!songCombos.exists(daSong))
		{
			setCombo(daSong, 'N/A');
		}

		return songCombos.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);

		if (!songRatings.exists(daSong))
		{
			setRating(daSong, 0);
		}

		return songRatings.get(daSong);
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null) songScores = FlxG.save.data.songScores;
		if (FlxG.save.data.songCombos != null) songCombos = FlxG.save.data.songCombos;
		if (FlxG.save.data.songRatings != null) songRatings = FlxG.save.data.songRatings;
	}
}
