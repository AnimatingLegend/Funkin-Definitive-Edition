package funkin.backend.utils.data;

/**
 * CharacterAnimation data for `.xml` files. 
 */
typedef AnimData =
{
	var name:String;
	var prefix:String;

	@:optional var frameIndices:Array<Int>; // was: indices
	@:optional var frameRate:Int; // was: fps
	@:optional var looped:Bool;
	@:optional var flipX:Bool;
	@:optional var flipY:Bool;
	@:optional var offsets:Array<Float>; // [x, y]
}

/**
 * Health icon data
 */
typedef HealthIconData =
{
	var id:String;
	@:optional var scale:Float;
	@:optional var flipX:Bool;
	@:optional var offsets:Array<Float>;
}

/**
 * Mapped animation data written with a `.json` file.
 */
typedef MappedAnimData =
{
	var charId:String;
	var songId:String;
}

/**
 * Chararacter data for `.json` files.
 */
typedef CharacterData =
{
	var version:String;
	var name:String; // display name e.g. "Boyfriend"
	var renderType:String; // "sparrow" or "packer"
	var assetPath:String;
	var startingAnimation:String;
	var animations:Array<AnimData>;

	@:optional var singDuration:Float;
	@:optional var danceEvery:Int;
	@:optional var isPixel:Bool;
	@:optional var flipX:Bool;
	@:optional var scale:Float;
	@:optional var offsets:Array<Float>;
	@:optional var cameraOffsets:Array<Float>;
	@:optional var healthIcon:HealthIconData;
	@:optional var library:String;
	@:optional var mappedAnims:MappedAnimData;
	@:optional var widthTrim:Float;
	@:optional var heightTrim:Float;
}
