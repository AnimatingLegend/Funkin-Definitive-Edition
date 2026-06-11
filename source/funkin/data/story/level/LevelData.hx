package funkin.data.story.level;

/**
 * Data structure for a single week, loaded from `assets/data/weeks/<name>.json`.
 */
typedef LevelData =
{
	var name:String;
	var displayName:String;
	var songs:Array<String>;
	var characters:Array<String>;
	@:optional var background:Null<String>;
}