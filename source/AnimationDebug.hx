package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxSound;
import openfl.events.Event;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;

using StringTools;

/**
 * Tweaks made by OldFlag
 * was supposed to be added in 0.2.3 but i forgot, WHOOPS!
 */

class AnimationDebug extends MusicBeatState
{
	var dad:Character;
	var dadBG:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var song:FlxSound;

	var gridBG:FlxSprite;
	var bg:FlxSprite;
	var stageFront:FlxSprite;
	var stageCurtains:FlxSprite;

	var UI_box:FlxUITabMenu;
	var UI_options:FlxUITabMenu;
	var offsetX:FlxUINumericStepper;
	var offsetY:FlxUINumericStepper;

	var characters:Array<String>;

	private var camOther:FlxCamera;
	private var camHUD:FlxCamera;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		//gridBG = FlxGridOverlay.create(10, 10);
		//gridBG.scrollFactor.set(0.5, 0.5);
		//add(gridBG);

		//FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);

		camOther = new FlxCamera();
		FlxG.cameras.reset(camOther);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camOther];

		// Stage Shit
		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/stageback', 'shared'));
		bg.antialiasing = FlxG.save.data.lowData;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stage/stagefront', 'shared'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = FlxG.save.data.lowData;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage/stage_light', 'shared'));
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.antialiasing = FlxG.save.data.lowData;
		stageLight.updateHitbox();
		add(stageLight);

		var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage/stage_light', 'shared'));
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.antialiasing = FlxG.save.data.lowData;
		stageLight.updateHitbox();
		stageLight.flipX = true;
		add(stageLight);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stage/stagecurtains', 'shared'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = FlxG.save.data.lowData;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
		add(stageCurtains);

		FlxG.mouse.visible = true;
	
		// Your Opponent (Dad)
		dad = new Character(0, 0, daAnim);
		dad.screenCenter();
		dad.debugMode = true;

		// Dad's Onion skin (makes it easier to offset chars)
		dadBG = new Character(0, 0, daAnim);
		dadBG.screenCenter();
		dadBG.debugMode = true;
		dadBG.alpha = 0.75;
		dadBG.color = 0xFF000000;

		add(dadBG);
		add(dad);

		char = dad;
		dad.flipX = true;

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);
		
		genBoyOffsets();
		addHelpText();

		characters = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var tabs = [{name: "Character List", label: 'Characters'},];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.cameras = [camHUD];
		UI_box.resize(150, 70);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;
		add(UI_box);

		addOffsetUI();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function addOffsetUI():Void
	{
		var player1DropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			remove(dad);
			dad = new Character(0, 0, characters[Std.parseInt(character)]);
			dad.screenCenter();
			dad.debugMode = true;
			dad.flipX = false;

			remove(dadBG);	
			dadBG = new Character(0, 0, characters[Std.parseInt(character)]);
			dadBG.screenCenter();
			dadBG.debugMode = true;
			dadBG.flipX = false;
			dadBG.alpha = 0.75;
			dadBG.color = 0xFF000000;

			add(dadBG);
			add(dad);
	
			replace(char, dadBG);
			char = dadBG;
			char = dad;
	
			genBoyOffsets(true, true);
			updateTexts();
		});
	
		player1DropDown.selectedLabel = char.curCharacter;
 
		var tab_group_offsets = new FlxUI(null, UI_box);
		tab_group_offsets.name = "Character List";
 
		tab_group_offsets.add(player1DropDown);
	
		UI_box.addGroup(tab_group_offsets);
	}

	function genBoyOffsets(pushList:Bool = true, ?cleanArray:Bool = false):Void
	{
		if (cleanArray)
			animList.splice(0, animList.length);
	
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			text.color = FlxColor.WHITE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	function addHelpText():Void
	{
		var helpTextArray:Array<String> = "Q/E : Zoom in and out\n
		R : Resets Camerea Zoom\n
		F : Flip Characters Sprite\n
		I/J/K/L : Move Camera\n
		W/S : Cycle Animation\n
		Arrows : Offset Animation\n
		Shift-Arrows : Offset Animation x10\n
		Space : Replay Animation\n
		CTRL + S : Save Offsets \n
		ESC : Exit\n".split('\n');

		for (i in 0...helpTextArray.length-1)
		{
			var helpText:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 15 - 16 * (helpTextArray.length - i), 300, helpTextArray[i], 12);
			textAnim.cameras = [camHUD];
			helpText.cameras = [camHUD];
			helpText.scrollFactor.set();
			helpText.setFormat(null, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			helpText.borderSize = 1;
			add(helpText);
		}
	}
	
	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			var outputString:String = "";

			for (swagAnim in animList)
			{
				outputString += swagAnim + " " + char.animOffsets.get(swagAnim)[0] + " " + char.animOffsets.get(swagAnim)[1] + "\n";
			}

			outputString.trim();
			saveOffsets(outputString);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
			trace('Returning to PlayState');
		}

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;
		if (FlxG.keys.justPressed.R)
			FlxG.camera.zoom = 0.00;
		if (FlxG.keys.justPressed.F)
			char.flipX = !char.flipX;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		super.update(elapsed);
	}

	var _file:FileReference;

	private function saveOffsets(saveString:String)
	{
		if ((saveString != null) && (saveString.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(saveString, daAnim + "Offsets.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	* Called when the save file dialog is cancelled.
	*/
	 function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	* Called if there is an error while saving the gameplay recording.
	*/
	 function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
