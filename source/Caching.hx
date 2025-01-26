#if sys
package;

import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;

import states.TitleState;
import backend.Paths;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;

	var images = [];
	var music  = [];
	var charts = [];

	var preloadStuff:FlxText;

    var funkay:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();

        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		add(bg);
		
        funkay = new FlxSprite(0, 0).loadGraphic(Paths.image('funkay'));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		funkay.scrollFactor.set();
		funkay.screenCenter();
		funkay.antialiasing = FlxG.save.data.antialiasing;
		add(funkay);

		preloadStuff = new FlxText(5, FlxG.height - 30, 0, "Preloading Assets", 12);
		preloadStuff.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		preloadStuff.scrollFactor.set();
		changetext();
		add(preloadStuff);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/data/charts")))
		{
			charts.push(i);
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}

	override function update(elapsed) 
	{
		super.update(elapsed);
	}

	function changetext() 
	{
		new FlxTimer().start(0.5, function(tmr:FlxTimer) 
		{
			preloadStuff.text = 'Preloading Assets';
			new FlxTimer().start(0.5, function(tmr:FlxTimer) 
			{
				preloadStuff.text = 'Preloading Assets.';
				new FlxTimer().start(0.5, function(tmr:FlxTimer) 
				{
					preloadStuff.text = 'Preloading Assets..';
					new FlxTimer().start(0.5, function(tmr:FlxTimer) 
					{
						preloadStuff.text = 'Preloading Assets...';
						changetext();
					});
				});
			});
		});
	}

	function cache()
	{
		#if !linux
		var sound1:FlxSound;
		sound1 = new FlxSound().loadEmbedded(Paths.voices('fresh'));
		sound1.play();
		sound1.volume = 0.00001;
		FlxG.sound.list.add(sound1);

		var sound2:FlxSound;
		sound2 = new FlxSound().loadEmbedded(Paths.inst('fresh'));
		sound2.play();
		sound2.volume = 0.00001;
		FlxG.sound.list.add(sound2);

		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
		}

		for (i in music)
		{
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			trace(i);
		}

		for (i in charts)
		{
			var replaced:String = i.replace(".json", "");
			var jsonPath:String = 'assets/data/charts/' + i;

			if (FileSystem.exists(jsonPath)) {
				var jsonData:Dynamic = jsonPath; 
                bitmapData.set(replaced, jsonData); 
			} else {
				trace("Chart file not found: " + jsonPath);
			}
		}

		#end
		FlxG.switchState(new TitleState());
		trace('Caching Process Complete');
	}
}
#end