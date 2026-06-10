package funkin.play.components;

import flixel.text.FlxText.FlxTextFormat;

/**
 * RATINGS CLASS
 * 
 * Handles the timing windows for each rating,
 *  as well as determining the rating of a note based on how early/late it is.
 */
class Ratings
{
	/**
	 * The timing windows for each rating, in milliseconds.
	 */
	public static var timingWindows:Array<Float> = [
		166.0, // SHIT Rating
		135.0, // BAD Rating
		90.0, // GOOD! Rating
		45.0 // SICK!! Rating
	];

	/**
	 * The ratings for each timing window.
	 */
	public static var timingRatings:Array<String> = ['shit', 'bad', 'good', 'sick'];

	/**
	 * Determines the rating of a note based on how early/late it is.
	 * @param noteDiff The difference between the note's strum time and the current song position.
	 * @return The rating of the note.
	 */
	public static inline function judgeNote(noteDiff:Float):String
	{
		var count = timingWindows.length < timingRatings.length ? timingWindows.length : timingRatings.length;
		if (count <= 0)
			return 'good';

		var diff:Float = Math.abs(noteDiff) / Conductor.timeScale;
		var expectedRating = -1;
		var expectedWindow = Math.POSITIVE_INFINITY;
		var worstRating = 0;
		var worstWindow = timingWindows[0];
		var rating = 0;

		while (rating < count)
		{
			var window = timingWindows[rating];
			if (window > worstWindow)
			{
				worstWindow = window;
				worstRating = rating;
			}

			if (diff <= window && window < expectedWindow)
			{
				expectedRating = rating;
				expectedWindow = window;
			}

			rating++;
		}

		return timingRatings[expectedRating >= 0 ? expectedRating : worstRating];
	}

	/**
	 * Determines what rank the player gets based on their performance in the song.
	 * @see `PlayState.ratingFC` for the full combo rank, which is separate from the normal rank.
	 */
	public static inline function getComboRank():String
	{
		return PlayState.ratingFC = switch (PlayState.misses)
		{
			case 0:
				if (PlayState.bads > 0 || PlayState.shits > 0) 'FC'; else if (PlayState.goods > 0) 'GFC'; else if (PlayState.sicks > 0) 'MFC'; else 'N/A';
			case misses if (misses < 10): 'SDCB';
			default: 'CLEAR';
		}
	}

	/**
	 * The FlxTextFormats for each rank, 
	 * used to color the combo rank in the score text.
	 */
	static var RANK_COLORS:Array<FlxTextFormat> = [
		new FlxTextFormat(0xFFFA84EA), // GFC Format
		new FlxTextFormat(0xFFE6C949), // MFC Format
		new FlxTextFormat(0xFFFAF871), // FC Format
		new FlxTextFormat(0xB4FAF871), // SDCB Format
		new FlxTextFormat(0xFF00287E), // CLEAR Format
		new FlxTextFormat(0xFFFFFFFF) // Default Format
	];

	public static inline function getComboRankFormat():FlxTextFormat
	{
		return switch (PlayState.ratingFC)
		{
			case 'GFC': RANK_COLORS[0];
			case 'MFC': RANK_COLORS[1];
			case 'FC': RANK_COLORS[2];
			case 'SDCB': RANK_COLORS[3];
			case 'CLEAR': RANK_COLORS[4];
			default: RANK_COLORS[5];
		}
	}
}
