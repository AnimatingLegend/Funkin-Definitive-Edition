package backend;

import states.PlayState;

import flixel.FlxG;

class Ratings
{
	/**
	* Rating Hit Windows 
	* Sick: 45ms | Good: 90ms | Bad: 135ms | Shit: 166ms
	**/

    public static var timingWindows = [166.0, 135.0, 90.0, 45.0]; 
   
    public static function judgeNote(noteDiff:Float)
    {
        var diff = Math.abs(noteDiff);
        for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
        {
            var time = timingWindows[index] * Conductor.timeScale;
            var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
            if (diff < time && diff >= nextTime * Conductor.timeScale)
            {
                switch (index)
                {
                    case 0:
                        return "shit";
                    case 1:
                        return "bad";
                    case 2:
                        return "good";
                    case 3:
                        return "sick";
                }
            }
        }
        return "good";
    }

	public static function fullComboRank() 
	{
		PlayState.ratingFC = 'N/A';
		
		if (PlayState.misses == 0) 
		{
			if (PlayState.bads > 0 || PlayState.shits > 0) {
				PlayState.ratingFC = 'FC';
			} else if (PlayState.goods > 0) {
				PlayState.ratingFC = 'GFC';
			} else if (PlayState.sicks > 0) {
				PlayState.ratingFC = 'MFC';
			}
		}
		else
		{
			if (PlayState.misses < 10) 
				PlayState.ratingFC = 'SDCB';
			else
				PlayState.ratingFC = 'Clear';
		}
	}
}