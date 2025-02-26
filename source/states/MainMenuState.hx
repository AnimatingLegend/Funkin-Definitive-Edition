package states;

import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

import ui.MenuItem;
import ui.MenuTypedList;
import ui.AtlasMenuItem;

import backend.GitCommit;

#if discord_rpc
import backend.Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var menuItems:MainMenuList;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var definitiveVersion:String = '0.5.2';
	public static var versionSuffix:String = #if debug ' DEBUG' #else '' #end;


	override function create()
	{
		Paths.clearStoredMemory();

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(null, null, Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.17;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(null, null, Paths.image('menuDesat'));
		magenta.scrollFactor.x = bg.scrollFactor.x;
		magenta.scrollFactor.y = bg.scrollFactor.y;
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.x = bg.x;
		magenta.y = bg.y;
		magenta.visible = false;
		magenta.antialiasing = FlxG.save.data.antialiasing;
		magenta.color = 0xFFFD719B;
		if (FlxG.save.data.flashingLights)
			add(magenta);

		menuItems = new MainMenuList();
		add(menuItems);
		menuItems.onChange.add(onMenuItemChange);
		menuItems.onAcceptPress.add(function(item:MenuItem)
		{
			FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
		});
		menuItems.enabled = false;
		menuItems.createItem(null, null, "story mode", function()
		{
			startExitState(new StoryMenuState());
		});
		menuItems.createItem(null, null, "freeplay", function()
		{
			startExitState(new FreeplayState());
		});
		if (!FlxG.save.data.weekUnlocked || StoryMenuState.weekUnlocked[7])
		{
			menuItems.createItem(null, null, "kickstarter", selectDonate, true);
		} 
		else 
		{
			menuItems.createItem(null, null, "donate", selectDonate, true);
		}
		menuItems.createItem(0, 0, "options", function()
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(1, 0);

			FlxG.sound.music.stop();
			startExitState(new options.OptionsMenuState());
		});

		var pos:Float = (FlxG.height - 160 * (menuItems.length - 1)) / 2;
		for (i in 0...menuItems.length)
		{
			var item:MainMenuItem = menuItems.members[i];
			item.x = FlxG.width / 2;
			item.y = pos + (160 * i);
		}
		
		#if html5
		FlxG.camera.follow(camFollow, null, 0.06);
		#else
		FlxG.camera.follow(camFollow, null, 0.06 * (30 / FlxG.save.data.framerateDraw));
		#end

		if (FlxG.save.data.watermark)
			git_VERSION();
		else 
		{
			var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' - v" + Application.current.meta.get('version') + versionSuffix, 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit);
		} 

		super.create();
		Paths.clearUnusedMemory();
	}

	override function finishTransIn()
	{
		super.finishTransIn();
		menuItems.enabled = true;
	}

	function onMenuItemChange(item:MenuItem)
	{
		camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);
	}

	function selectDonate()
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [
			"https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game/",
			"&"
		]);
		#else
		FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game/');
		#end
	}

	function startExitState(nextState:FlxState)
	{
		menuItems.enabled = false;
		menuItems.forEach(function(item:MainMenuItem)
		{
			if (menuItems.selectedIndex != item.ID)
			{
				FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			}
			else
			{
				item.visible = false;
			}
		});
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxG.switchState(nextState);
		});
	}

	override function update(elapsed:Float)
	{
		#if html5
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);
		#end

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (_exiting)
		{
			menuItems.enabled = false;
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE && menuItems.enabled && !menuItems.busy)
		{
			FlxG.switchState(new TitleState());
		}

		super.update(elapsed);
	}

	// Current Git Branch
   	public static final GIT_BRANCH:String = GitCommit.getGitBranch();

	// Current Git Commit Hash
   	public static final GIT_HASH:String = GitCommit.getGitCommitHash();
 
   	public static final GIT_HAS_LOCAL_CHANGES:Bool = GitCommit.getGitHasLocalChanges();

	#if debug
	function git_VERSION()
	{
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF' Definitive Edition - v" 
		+ definitiveVersion + ' ($GIT_BRANCH : ${GIT_HASH} ${GIT_HAS_LOCAL_CHANGES})' + versionSuffix , 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
	}
	#else
	function git_VERSION()
	{
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF' Definitive Edition - v" 
		+ definitiveVersion + versionSuffix , 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
	}
	#end
}

class MainMenuItem extends AtlasMenuItem
{
	public function new(?x:Float = 0, ?y:Float = 0, name:String, atlas:FlxAtlasFrames, callback:Dynamic)
	{
		super(x, y, name, atlas, callback);
		this.scrollFactor.set();
	}

	override public function changeAnim(anim:String)
	{
		super.changeAnim(anim);
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		offset.copyFrom(origin);
	}
}

class MainMenuList extends MenuTypedList<MainMenuItem>
{
	var atlas:FlxAtlasFrames;

	public function new()
	{
		atlas = Paths.getSparrowAtlas('main_menu');
		super(Vertical);
	}

	public function createItem(?x:Float = 0, ?y:Float = 0, name:String, callback:Dynamic = null, fireInstantly:Bool = false)
	{
		var item:MainMenuItem = new MainMenuItem(x, y, name, atlas, callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;
		return addItem(name, item);
	}
}
