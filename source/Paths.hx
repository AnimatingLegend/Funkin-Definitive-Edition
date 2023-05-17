package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('music/$key.mp4', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	public static var dumpExclusions:Array<String> = ['assets/music/freakyMenu.$SOUND_EXT'];
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var localTrackedAssets:Array<String> = [];
	
	public static function clearUnusedMemory() // taken from kade engine | i love optimization :]
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				// get rid of it
				var obj = cast(currentTrackedAssets.get(key), FlxGraphic);
				@:privateAccess
				if (obj != null)
				{
					obj.persist = false;
					obj.destroyOnNoUse = true;
					OpenFlAssets.cache.removeBitmapData(key);

					FlxG.bitmap._cache.remove(key);
					FlxG.bitmap.removeByKey(key);

					if (obj.bitmap.__texture != null)
					{
						obj.bitmap.__texture.dispose();
						obj.bitmap.__texture = null;
					}

					FlxG.bitmap.remove(obj);

					obj.dump();
					obj.bitmap.disposeImage();
					FlxDestroyUtil.dispose(obj.bitmap);

					obj.bitmap = null;

					obj.destroy();

					obj = null;

					currentTrackedAssets.remove(key);
					counter++;
					trace('Cleared $key form RAM');
					trace('Cleared and removed $counter assets.');
				}
			}
		}
		// run the garbage collector for good measure lmfao
		runGC();
	}

	public static function runGC()
		System.gc();

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list

		var counterAssets:Int = 0;

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = cast(FlxG.bitmap._cache.get(key), FlxGraphic);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				obj.persist = false;
				obj.destroyOnNoUse = true;

				OpenFlAssets.cache.removeBitmapData(key);

				FlxG.bitmap._cache.remove(key);

				FlxG.bitmap.removeByKey(key);

				if (obj.bitmap.__texture != null)
				{
					obj.bitmap.__texture.dispose();
					obj.bitmap.__texture = null;
				}

				FlxG.bitmap.remove(obj);

				obj.dump();

				obj.bitmap.disposeImage();
				FlxDestroyUtil.dispose(obj.bitmap);
				obj.bitmap = null;

				obj.destroy();
				obj = null;
				counterAssets++;
				trace('Cleared $key from RAM');
				trace('Cleared and removed $counterAssets cached assets.');
			}
		}
	}
}