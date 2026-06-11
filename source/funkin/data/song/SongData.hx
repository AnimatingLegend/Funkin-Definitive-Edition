package funkin.data.song;

/**
 * Data structure for representing a song in the freeplay menu.
 */
typedef SongData =
{
	var songName:String;
	var week:Int;
	var songCharacter:String;
	@:optional var color:Null<Int>;
}