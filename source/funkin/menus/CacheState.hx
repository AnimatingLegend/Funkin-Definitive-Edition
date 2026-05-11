package funkin.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import funkin.backend.utils.Paths;

import openfl.display.BitmapData;
import openfl.utils.Assets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * CACHE CLASS 
 * 
 * Preloads assets into memory to prevent stuttering during gameplay.
 */
class CacheState extends MusicBeatState
{
	/**
	 * Global maps to hold reference to graphics so they aren't garbage collected
	 */
	public static var bitmapData:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	var toBeDone = 0;
	var done = 0;

	var images = [];
	var music = [];
	var sounds = [];

	var preloadStuff:FlxText;
	var funkay:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = false;
		FlxG.worldBounds.set(0, 0);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		add(bg);

		funkay = new FlxSprite().loadGraphic(Paths.image('funkay'));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		funkay.screenCenter();
		funkay.antialiasing = (FlxG.save.data.antialiasing != null) ? FlxG.save.data.antialiasing : true;
		add(funkay);

		preloadStuff = new FlxText(5, FlxG.height - 40, 0, "Preloading Assets", 24);
		preloadStuff.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(preloadStuff);

		updateTextAnimation();

		#if sys
		// Populate asset lists
		if (FileSystem.exists("assets/shared/images/characters")) 
		{
			for (i in FileSystem.readDirectory("assets/shared/images/characters")) 
			{
				if (i.endsWith(".png")) images.push(i);
			}
		}

		if (FileSystem.exists("assets/songs")) 
		{
			for (i in FileSystem.readDirectory("assets/songs")) music.push(i);
		}

		if (FileSystem.exists("assets/shared/sounds")) 
		{
			for (i in FileSystem.readDirectory("assets/shared/sounds")) 
			{
				if (i.endsWith(".ogg")) sounds.push(i);
			}
		}

		// Start caching thread
		sys.thread.Thread.create(() -> { cache(); });
		#else
		// If not on a system target, skip to title
		FlxG.switchState(new funkin.menus.TitleState());
		#end

		super.create();
	}

	function updateTextAnimation()
	{
		var dots:Int = 0;
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			dots++;
			if (dots > 3) dots = 0;
			
			var dotStr = "";
			for (i in 0...dots) dotStr += ".";
			
			preloadStuff.text = "Preloading Assets" + dotStr;
		}, 0);
	}

	function cache()
	{
		#if sys
		// Cache Images
		for (i in images)
		{
			var replaced = i.replace(".png", "");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			trace("Cached image: " + replaced);
		}

		// Cache Sounds/SFX
		for (i in sounds)
		{
			var replaced = i.replace(".ogg", "");
			// Note: We don't store sounds in a Graphic Map, we use FlxG.sound.cache
			FlxG.sound.cache(Paths.sound(replaced, 'shared'));
			trace("Cached sound: " + replaced);
		}

		// Cache Music (Inst and Voices)
		for (i in music)
		{
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			trace("Cached music: " + i);
		}

		trace('Caching Process Complete');
		
		// Use a slight delay before switching so the user can see it's done
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			FlxG.switchState(new funkin.menus.TitleState());
		});
		#end
	}
}
