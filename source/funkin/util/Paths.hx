package funkin.util;

import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

/**
 * PATHS CLASS
 * 
 * A core class that handles certain asset paths, 
 * and memory management for assets.
 */
class Paths
{
	/**
	 * Get the extension for both sound and video for the current platform.
	 */
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	inline public static var VIDEO_EXT = "mp4";

	/**
	 * Exclude an asset from the memory dump.
	 * @param key 
	 */
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	/**
	 * List of assets to exclude from the memory dump.
	 */
	public static var dumpExclusions:Array<String> = ['assets/preload/music/freakyMenu.$SOUND_EXT'];

	/**
	 * List of assets and sounds that are currently being tracked.
	 */
	public static var localTrackedAssets:Array<String> = [];

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	/**
	 * Clears out any unused memory from the system.
	 */
	public static function clearUnusedMemory()
	{
		var counter:Int = 0;

		// Dispose of non-local assets in the tracked assets list.
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var object = cast(currentTrackedAssets.get(key), FlxGraphic);
				@:privateAccess
				if (object != null)
				{
					object.persist = false;
					object.destroyOnNoUse = true;

					OpenFlAssets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					FlxG.bitmap.removeByKey(key);

					if (object.bitmap.__texture != null)
					{
						object.bitmap.__texture.dispose();
						object.bitmap.__texture = null;
					}
					FlxG.bitmap.remove(object);

					object.dump();
					object.bitmap.disposeImage();
					FlxDestroyUtil.dispose(object.bitmap);
					object.bitmap = null;
					object.destroy();
					object = null;

					currentTrackedAssets.remove(key);
					counter++;
					trace('RAM(cache): Cleared $key from memory.');
					trace('RAM(cache): Cleared and removed $counter assets from memory.');
				}
			}
		}

		// Run garbage collection just incase...
		#if cpp
		cpp.vm.Gc.run(true);
		#end

		trace('RAM(cache): Finished clearing unused memory.');
	}

	/**
	 * Clears out any stored memory from the system.
	 */
	public static function clearStoredMemory()
	{
		var counterAssets:Int = 0;

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var object = cast(FlxG.bitmap._cache.get(key), FlxGraphic);

			if (object != null && !currentTrackedAssets.exists(key))
			{
				object.persist = false;
				object.destroyOnNoUse = true;

				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				FlxG.bitmap.removeByKey(key);

				if (object.bitmap.__texture != null)
				{
					object.bitmap.__texture.dispose();
					object.bitmap.__texture = null;
				}
				FlxG.bitmap.remove(object);

				object.dump();
				object.bitmap.disposeImage();
				object.bitmap = null;
				object.destroy();
				object = null;

				counterAssets++;
				trace('RAM(cache): Cleared $key from RAM.');
				trace('RAM(cache): Cleared and removed $counterAssets assets from RAM.');
			}
		}

		#if PRELOAD_ALL
		var counterSound:Int = 0;

		// Dispose of non-local sounds in the tracked assets list.
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				OpenFlAssets.cache.clear(key);
				OpenFlAssets.cache.removeSound(key);
				currentTrackedSounds.remove(key);

				counterSound++;
				trace('RAM(cache): Cleared $key from RAM.');
				trace('RAM(cache): Cleared and removed $counterSound cached sounds.');
			}
		}

		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
		#end

		// Run garbage collection just incase...
		#if cpp
		cpp.vm.Gc.run(true);
		#end

		trace('RAM(cache): Finished clearing stored memory.');
	}

	/**
	 * Get, and set the current level of a directory.
	 */
	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	/**
	 * Load a JSON file, and parse it when possible.
	 * @param key file name
	 * @param library wanted directory
	 */
	static public function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJsonPath = '';

		try
		{
			rawJsonPath = OpenFlAssets.getText(Paths.json(key, library));
			trace('JSON: Loaded $key from $rawJsonPath');
		}
		catch (err)
		{
			trace('JSON: Failed to load $key from $rawJsonPath');
			rawJsonPath = null;
		}

		// Cleanup on files that have bad data at the end.
		if (rawJsonPath != null)
		{
			while (!rawJsonPath.endsWith('}'))
				rawJsonPath = rawJsonPath.substr(0, rawJsonPath.length - 1);
		}

		try
		{
			// Attempt to parse the JSON data.
			if (rawJsonPath != null)
			{
				trace('JSON: Successfully parsed $key from $rawJsonPath');
				return haxe.Json.parse(rawJsonPath);
			}

			return null;
		}
		catch (err)
		{
			trace('JSON: Failed to parse $key from $rawJsonPath');
			return null;
		}
	}

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		// If the current level isn't null use that level.
		if (currentLevel != null)
		{
			var levelPath:String = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		// If the current level is null, try to use the shared level.
		var levelPath:String = getLibraryPathForce(file, 'shared');
		if (Assets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
		return '$library:assets/$library/$file';

	inline static function getPreloadPath(file:String)
		return 'assets/$file';

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
		return getPath(file, type, library);

	inline static public function txt(key:String, ?library:String)
		return getPath('data/$key.txt', TEXT, library);

	inline static public function xml(key:String, ?library:String)
		return getPath('data/$key.xml', TEXT, library);

	inline static public function json(key:String, ?library:String)
		return getPath('data/$key.json', TEXT, library);

	static public function sound(key:String, ?library:String)
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
		return sound(key + FlxG.random.int(min, max), library);

	inline static public function music(key:String, ?library:String)
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);

	inline static public function videos(key:String, ?library:String)
		return getPath('videos/$key.mp4', BINARY, library);

	inline static public function voices(song:String)
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';

	inline static public function inst(song:String)
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';

	inline static public function image(key:String, ?library:String)
		return getPath('images/$key.png', IMAGE, library);

	static public function loadImage(key:String, ?library:String):FlxGraphic
	{
		var path = image(key, library);

		#if desktop
		if (funkin.ui.transition.preload.CacheState.bitmapData != null)
		{
			if (funkin.ui.transition.preload.CacheState.bitmapData.exists(key))
			{
				trace('Loading image from bitmap cache: $key');
				return funkin.ui.transition.preload.CacheState.bitmapData.get(key);
			}
		}
		#end

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			FlxG.log.warn('Could not find image at path $path');
			return null;
		}
	}

	inline static public function font(key:String)
		return 'assets/fonts/$key';

	inline static public function getSparrowAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	inline static public function getPackerAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
}
