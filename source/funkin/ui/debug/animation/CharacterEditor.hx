package funkin.ui.debug.animation;

import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import funkin.data.character.CharacterData;
import haxe.Json;
import haxe.xml.Access;
import openfl.events.Event;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;

using StringTools;

/**
 * CHARACTER ANIMATION EDITOR CLASS
 * 
 * Dynamically load your characters in, update their offsets, 
 * and save it to a `.json` file.
 */
class CharacterEditor extends MusicBeatState
{
	/**
	 * Scene Elements
	 */
	var opponent:Character;

	var characterBackground:Character;
	var character:Character;

	var uiVisible:Bool = true;
	var uiCollapsed:Bool = false;
	var onionSkinVisible:Bool = true;

	var textAnim:FlxText;
	var textOffset:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'bf';

	var camFollow:FlxSprite;
	private var camOther:FlxCamera;
	private var camHUD:FlxCamera;

	/**
	 * UI Panel Elements
	 */
	static final PANEL_W:Int = 280;

	static final PANEL_PAD:Int = 12;

	var panelBG:FlxSprite;
	var panelGroup:FlxGroup;

	var characters:Array<String> = [];
	var isPlayable:Bool = false;

	var currentCharacterData:CharacterData;
	var xmlPrefix:Array<String> = [];

	/**
	 * UI Dropdowns / Inputs
	 */
	var characterDropdown:FlxUIDropDownMenu;

	var animationDropdown:FlxUIDropDownMenu;

	/**
	 * Character Tab Fields
	 */
	var imageFileInput:FlxUIInputText;

	var healthIconInput:FlxUIInputText;
	var flipXCheck:FlxUICheckBox;
	var singDurStepper:FlxUINumericStepper;
	var scaleStepper:FlxUINumericStepper;
	var charXStepper:FlxUINumericStepper;
	var charYStepper:FlxUINumericStepper;

	/**
	 * Animation Tab Fields
	 */
	var animNameInput:FlxUIInputText;

	var animSymbolInput:FlxUIInputText;
	var animFPSStepper:FlxUINumericStepper;
	var animLoopCheck:FlxUICheckBox;
	var animIndicesInput:FlxUIInputText;

	var UI_BOX:FlxUITabMenu;

	public function new(daAnim:String = 'bf')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('pauseMusic/breakfast', 'shared'), 0.5);

		var gridBG = FlxGridOverlay.create(16, 16, FlxG.width, FlxG.height, true, 0xFF888888, 0xFF666666);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);

		camOther = new FlxCamera();
		FlxG.cameras.reset(camOther);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		this.cameras = [camOther, camHUD];
		FlxG.mouse.visible = true;

		characters = discoverCharacters();

		textOffset = new FlxText(8, FlxG.height - 32, 0, 'Offset: [0,0]', 16);
		textOffset.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		textOffset.borderSize = 1;
		textOffset.scrollFactor.set();
		textOffset.cameras = [camHUD];
		add(textOffset);

		textAnim = new FlxText(0, 8, FlxG.width, '', 20);
		textAnim.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		buildPanel();

		camFollow = new FlxSprite(0, 0);
		camFollow.visible = false;
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 1.0);

		loadCharacterIntoView(daAnim);
		genBoyOffsets();

		super.create();
	}

	function buildPanel():Void
	{
		panelGroup = new FlxGroup();

		var panelX = FlxG.width - PANEL_W;
		var panelH = FlxG.height;

		// Create a semi-transparent background to put the panel on
		// Doing this instead of using `haxeUI` because it sucks lol.
		panelBG = new FlxSprite(panelX, 0);
		panelBG.makeGraphic(PANEL_W, panelH, 0xDD1A1A1A);
		panelBG.scrollFactor.set();
		panelBG.cameras = [camHUD];
		panelGroup.add(panelBG);

		// Set positions for the panel
		var yOff = PANEL_PAD;
		var xBase = panelX + PANEL_PAD;
		var innerW = PANEL_W - (PANEL_PAD * 2);

		var collapseBtn = makeLabel(panelX + PANEL_W - 28, yOff, '^', 16);
		collapseBtn.borderColor = FlxColor.GRAY;
		panelGroup.add(collapseBtn);
		_collapseBtn = collapseBtn;

		//
		// Character Dropdown.
		//

		yOff += 4;
		panelGroup.add(makeSectionLabel(xBase, yOff, 'Character:'));
		yOff += 22;

		characterDropdown = new FlxUIDropDownMenu(xBase, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(characters.length > 0 ? characters : ['N/A'], true),
			function(idx:String)
			{
				var characterID = characters[Std.parseInt(idx)];
				if (characterID == null)
					return; // If the character ID is null, don't do anything.
				daAnim = characterID;
				loadCharacterIntoView(characterID);
				updateTexts();
				genBoyOffsets(true, true);
			});
		characterDropdown.selectedLabel = daAnim;
		characterDropdown.cameras = [camHUD];
		characterDropdown.scrollFactor.set();
		styleDropdown(characterDropdown, innerW);
		panelGroup.add(characterDropdown);
		yOff += 32;

		//
		// Animation Dropdown.
		//

		panelGroup.add(makeSectionLabel(xBase, yOff, 'Animation:'));
		yOff += 22;

		animationDropdown = new FlxUIDropDownMenu(xBase, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(['N/A'], true), function(idx:String)
		{
			var animationID = currentCharacterData.animations[Std.parseInt(idx)];
			if (animationID == null)
				return; // If the animation ID is null, don't do anything.
			curAnim = Std.parseInt(idx);
			character.playAnim(animList[curAnim]);

			updateOffsetDisplay();
			updateTexts();
			genBoyOffsets(false);
		});
		animationDropdown.cameras = [camHUD];
		animationDropdown.scrollFactor.set();
		styleDropdown(animationDropdown, innerW);
		panelGroup.add(animationDropdown);
		yOff += 32;

		//
		// Onion Skin / Playable Toggle
		//

		var onionSkinCheck = new FlxUICheckBox(xBase, yOff, null, null, 'Onion Skin', 100);
		onionSkinCheck.checked = onionSkinVisible;
		onionSkinCheck.cameras = [camHUD];
		onionSkinCheck.scrollFactor.set();
		onionSkinCheck.callback = function()
		{
			onionSkinVisible = onionSkinCheck.checked;
			if (characterBackground != null)
				characterBackground.alpha = onionSkinVisible ? 0.75 : 0;
		};
		panelGroup.add(onionSkinCheck);

		var playableCheck = new FlxUICheckBox(xBase + 110, yOff, null, null, 'Playable', 90);
		playableCheck.checked = isPlayable;
		playableCheck.cameras = [camHUD];
		playableCheck.scrollFactor.set();
		playableCheck.callback = function()
		{
			isPlayable = playableCheck.checked;
			loadCharacterIntoView(daAnim);
			updateTexts();
			genBoyOffsets(true, true);
		};
		panelGroup.add(playableCheck);
		yOff += 28;

		// Divide each section of the panel.
		panelGroup.add(makeDivider(xBase, yOff, innerW));
		yOff += 10;

		// Create tabs for the panel (Animation, & Character).
		var tabs = [
			{name: "Animations", label: 'Animations'},
			{name: "Character", label: 'Character'}
		];
		UI_BOX = new FlxUITabMenu(null, tabs, true);
		UI_BOX.scrollFactor.set();
		UI_BOX.cameras = [camHUD];
		UI_BOX.resize(innerW, 260);
		UI_BOX.x = xBase;
		UI_BOX.y = yOff;
		panelGroup.add(animationDropdown);
		panelGroup.add(characterDropdown);
		panelGroup.add(UI_BOX);

		buildAnimTab(xBase, innerW);
		buildCharacterTab(xBase, innerW);
		yOff += 268;

		// Divide each section of the panel.
		panelGroup.add(makeDivider(xBase, yOff, innerW));
		yOff += 10;

		var shortcuts = [
			"CTRL+Q: Exit to Main Menu",
			"CTRL+BACKSPACE: Exit to PlayState",
			"H: Show/Hide UI",
			"Middle Click: Pan Camera",
			"Scroll Wheel: Zoom",
			"F: Flip Sprite",
			"O: Toggle Onion Skin",
			"W/S: Cycle Animation",
			"Space: Replay Animation",
			"Arrows: Offset Anim",
			"Shift+Arrows: x10",
			"CTRL+S: Save JSON"
		];

		for (shortcut in shortcuts)
		{
			var txt = makeLabel(xBase, yOff, shortcut, 11);
			txt.color = 0xFFAAAAAA;
			panelGroup.add(txt);
			yOff += 15;
		}

		// Add everything to scene.
		panelGroup.cameras = [camHUD];
		add(panelGroup);
		add(animationDropdown);
		add(characterDropdown);
	}

	var _collapseBtn:FlxText;

	function buildAnimTab(xBase:Float, innerW:Float):Void
	{
		var tab = new FlxUI(null, UI_BOX);
		tab.name = "Animations";

		var yAxis = 10;
		tab.add(new FlxText(8, yAxis, 0, 'Animation Name:', 11));
		yAxis += 15;
		animNameInput = new FlxUIInputText(8, yAxis, Std.int(innerW - 16), '', 12);
		tab.add(animNameInput);
		yAxis += 24;

		tab.add(new FlxText(8, yAxis, 0, 'Symbol Name/Tag (XML prefix):', 11));
		yAxis += 15;
		animSymbolInput = new FlxUIInputText(8, yAxis, Std.int(innerW - 16), '', 12);
		tab.add(animSymbolInput);
		yAxis += 24;

		tab.add(new FlxText(8, yAxis, 0, 'Framerate:', 11));
		tab.add(new FlxText(90, yAxis, 0, 'Loop:', 11));
		yAxis += 15;
		animFPSStepper = new FlxUINumericStepper(8, yAxis, 1, 24, 1, 240, 0);
		animLoopCheck = new FlxUICheckBox(90, yAxis, null, null, '', 20);
		tab.add(animFPSStepper);
		tab.add(animLoopCheck);
		yAxis += 28;

		tab.add(new FlxText(8, yAxis, 0, 'Indices (comma-separated):', 11));
		yAxis += 15;
		animIndicesInput = new FlxUIInputText(8, yAxis, Std.int(innerW - 16), '', 12);
		tab.add(animIndicesInput);
		yAxis += 24;

		var addBtn = new FlxUIButton(8, yAxis, 'Add / Update', onAnimAddUpdate);
		var remBtn = new FlxUIButton(110, yAxis, 'Remove', onAnimRemove);
		addBtn.resize(95, 20);
		remBtn.resize(95, 20);
		tab.add(addBtn);
		tab.add(remBtn);

		UI_BOX.addGroup(tab);
	}

	function buildCharacterTab(xBase:Float, innerW:Float):Void
	{
		var tab = new FlxUI(null, UI_BOX);
		tab.name = "Character";

		var yAxis = 10;
		tab.add(new FlxText(8, yAxis, 0, 'Image file name:', 11));
		yAxis += 15;
		imageFileInput = new FlxUIInputText(8, yAxis, Std.int(innerW - 70), '', 12);
		var reloadBtn = new FlxUIButton(Std.int(innerW - 58), yAxis, 'Reload', function()
		{
			if (currentCharacterData == null)
				return;
			currentCharacterData.assetPath = imageFileInput.text.trim();
			xmlPrefix = scanXMLPrefixes(currentCharacterData.assetPath, currentCharacterData.library);

			loadCharacterIntoView(daAnim);
			updateTexts();
			genBoyOffsets(true, true);
		});
		reloadBtn.resize(54, 20);
		tab.add(imageFileInput);
		tab.add(reloadBtn);
		yAxis += 26;

		tab.add(new FlxText(8, yAxis, 0, 'Health Icon:', 11));
		yAxis += 15;
		healthIconInput = new FlxUIInputText(8, yAxis, Std.int(innerW - 80), '', 12);

		flipXCheck = new FlxUICheckBox(8, yAxis, null, null, 'Flip X', 60);
		tab.add(flipXCheck);
		yAxis += 24;

		tab.add(new FlxText(8, yAxis, 0, 'Sing Length:', 11));
		tab.add(new FlxText(110, yAxis, 0, 'Scale:', 11));
		yAxis += 15;
		singDurStepper = new FlxUINumericStepper(8, yAxis, 0.1, 4.0, 0.1, 20.0, 1);
		scaleStepper = new FlxUINumericStepper(110, yAxis, 0.1, 1.0, 0.1, 10.0, 1);
		tab.add(singDurStepper);
		tab.add(scaleStepper);
		yAxis += 28;

		var saveBtn = new FlxUIButton(8, yAxis, 'Save Character', saveToJson);
		saveBtn.resize(Std.int(innerW - 16), 22);
		tab.add(saveBtn);

		UI_BOX.addGroup(tab);
	}

	//
	// PANEL UTILITIES
	//

	function makeLabel(x:Float, y:Float, text:String, size:Int = 12):FlxText
	{
		var txt = new FlxText(x, y, 0, text, size);
		txt.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		txt.borderSize = 1;
		txt.scrollFactor.set();
		txt.cameras = [camHUD];
		return txt;
	}

	function makeSectionLabel(x:Float, y:Float, text:String):FlxText
	{
		var txt = makeLabel(x, y, text, 13);
		txt.color = FlxColor.WHITE;
		return txt;
	}

	function makeDivider(x:Float, y:Float, w:Float):FlxSprite
	{
		var divider = new FlxSprite(x, y);
		divider.makeGraphic(Std.int(w), 1, 0xFF444444);
		divider.scrollFactor.set();
		divider.cameras = [camHUD];
		return divider;
	}

	function styleDropdown(dropdown:FlxUIDropDownMenu, width:Float):Void
	{
		dropdown.width = width;
		dropdown.height = 20;
	}

	//
	// CHARACTER DATA
	//

	function discoverCharacters():Array<String>
	{
		var dataFound:Array<String> = [];

		for (file in openfl.Assets.list())
		{
			if (file.startsWith('assets/data/characters/') && file.endsWith('.json'))
			{
				var name = file.replace('assets/data/characters/', '').replace('.json', '');
				if (!dataFound.contains(name))
					dataFound.push(name);
			}
		}

		dataFound.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
		return dataFound;
	}

	/**
	 * Parse the character's XML and return all unique animation prefixes.
	 * Strips trailing digits so "BF idle dance001" becomes "BF idle dance".
	 */
	function scanXMLPrefixes(assetPath:String, library:String):Array<String>
	{
		var prefixes:Array<String> = [];
		if (assetPath == null)
			return prefixes;

		var lib = library != null ? library : 'shared';
		var xmlPath = Paths.file('images/$assetPath.xml', TEXT, lib);
		if (!openfl.Assets.exists(xmlPath))
			return prefixes;

		try
		{
			var xml = new Access(Xml.parse(openfl.Assets.getText(xmlPath)).firstElement());
			for (sub in xml.nodes.SubTexture)
			{
				var prefix = ~/[0-9]+$/.replace(sub.att.name, '').rtrim();
				if (!prefixes.contains(prefix))
					prefixes.push(prefix);
			}
			prefixes.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
		}
		catch (e)
		{
			trace('CHARACTER ANIMATION DEBUGGER: XML parse error: $e');
		}

		return prefixes;
	}

	function loadCharacterIntoView(id:String):Void
	{
		if (character != null)
			remove(character);
		if (characterBackground != null)
			remove(characterBackground);

		var jsonPath = Paths.file('data/characters/$id.json', TEXT, 'preload');

		// If the character data exists, automatically load it.
		// Otherwise, create an empty character.
		if (openfl.Assets.exists(jsonPath))
		{
			currentCharacterData = Json.parse(openfl.Assets.getText(jsonPath));
		}
		else
		{
			currentCharacterData = {
				version: '1.0.0',
				name: id,
				renderType: 'sparrow',
				assetPath: 'characters/$id',
				library: 'shared',
				startingAnimation: 'idle',
				singDuration: 4.0,
				animations: [],
				flipX: false,
				scale: 1.0,
				healthIcon: {
					id: id,
					scale: 1.0,
					flipX: false,
					offsets: [0, 0]
				}
			};
		}

		characterBackground = new Character(0, 0, id);
		characterBackground.screenCenter();
		characterBackground.debugMode = true;
		characterBackground.alpha = onionSkinVisible ? 0.75 : 0.0;

		opponent = new Character(0, 0, id);
		opponent.screenCenter();
		opponent.debugMode = true;

		if (isPlayable)
			character.flipX = !character.flipX;

		add(characterBackground);
		add(opponent);
		character = opponent;

		// Re-layer panel on top.
		remove(animationDropdown, true);
		remove(characterDropdown, true);
		remove(panelGroup, true);
		add(panelGroup);
		add(animationDropdown);
		add(characterDropdown);

		// Build the animation list.
		animList = [];
		for (animation in character.animation.getAnimationList())
			animList.push(animation.name);
		for (animation in animList)
		{
			if (!character.animOffsets.exists(animation))
				character.animOffsets.set(animation, [0.0, 0.0]);
		}

		curAnim = 0;
		if (animList.length > 0)
			character.playAnim(animList[0]);

		xmlPrefix = (currentCharacterData != null && currentCharacterData.assetPath != null) ? scanXMLPrefixes(currentCharacterData.assetPath,
			currentCharacterData.library) : [];

		rebuildAnimDropDown();
		syncCharTabToData();
		updateOffsetDisplay();
	}

	function rebuildAnimDropDown():Void
	{
		if (animationDropdown == null)
			return;

		var labels = animList.length > 0 ? animList : ['N/A'];
		animationDropdown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(labels, true));

		if (animList.length > 0)
			animationDropdown.selectedLabel = animList[curAnim];
	}

	function syncCharTabToData():Void
	{
		if (currentCharacterData == null)
			return;
		if (imageFileInput != null)
			imageFileInput.text = currentCharacterData.assetPath != null ? currentCharacterData.assetPath : '';
		if (healthIconInput != null)
			healthIconInput.text = currentCharacterData.healthIcon != null ? currentCharacterData.healthIcon.id : daAnim;
		if (flipXCheck != null)
			flipXCheck.checked = currentCharacterData.flipX == true;
		if (singDurStepper != null)
			singDurStepper.value = currentCharacterData.singDuration != null ? currentCharacterData.singDuration : 4.0;
		if (scaleStepper != null)
			scaleStepper.value = currentCharacterData.scale != null ? currentCharacterData.scale : 1.0;
	}

	//
	// OFFSET LIST
	//

	function genBoyOffsets(pushList:Bool = true, ?cleanArray:Bool = false):Void
	{
		if (cleanArray)
			animList.splice(0, animList.length);

		var daLoop = 0;
		for (anim => offsets in character.animOffsets)
		{
			var isSelected = (animList.indexOf(anim) == curAnim);
			var label = (isSelected ? '> ' : '  ') + anim + ': ' + offsets;

			var txt = new FlxText(8, 36 + (16 * daLoop), 0, label, 11);
			txt.setFormat(Paths.font('vcr.ttf'), 11, isSelected ? FlxColor.YELLOW : FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			txt.borderSize = 1;
			txt.scrollFactor.set();
			txt.cameras = [camHUD];
			dumbTexts.add(txt);

			if (pushList && !animList.contains(anim))
				animList.push(anim);
			daLoop++;
		}

		remove(dumbTexts, true);
		add(dumbTexts);

		// Keep panel on top
		remove(panelGroup, true);
		add(panelGroup);
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(txt)
		{
			txt.kill();
			dumbTexts.remove(txt, true);
		});
	}

	function updateOffsetDisplay():Void
	{
		if (animList.length == 0 || textOffset == null)
			return;
		var offsets = character.animOffsets.get(animList[curAnim]);
		textOffset.text = 'Offset: ' + (offsets != null ? offsets : [0, 0]);
	}

	//
	// ANIMATION TAB CALLBACKS
	//

	function onAnimAddUpdate():Void
	{
		if (currentCharacterData == null)
			return;

		var name = animNameInput.text.trim();
		var symbol = animSymbolInput.text.trim();
		if (name == '' || symbol == '')
			return;

		var framerate = Std.int(animFPSStepper.value);
		var looped = animLoopCheck.checked;
		var indices:Array<Int> = [];

		var indicesString = animIndicesInput.text.trim();
		if (indicesString != '')
		{
			for (part in indicesString.split(','))
			{
				var value = Std.parseInt(part.trim());
				if (value != null)
					indices.push(value);
			}
		}

		var animDataFound = false;
		for (animation in currentCharacterData.animations)
		{
			if (animation.name == name)
			{
				animation.prefix = symbol;
				animation.frameRate = framerate;
				animation.looped = looped;
				animation.frameIndices = indices.length > 0 ? indices : null;
				animDataFound = true;
				break;
			}
		}

		if (!animDataFound)
		{
			currentCharacterData.animations.push({
				name: name,
				prefix: symbol,
				frameRate: framerate,
				looped: looped,
				frameIndices: indices.length > 0 ? indices : null,
				offsets: [0, 0]
			});
		}

		if (indices.length > 0)
		{
			character.animation.addByIndices(name, symbol, indices, '', framerate, looped);
		}
		else
		{
			character.animation.addByPrefix(name, symbol, framerate, looped);
		}

		if (!character.animOffsets.exists(name))
			character.animOffsets.set(name, [0.0, 0.0]);
		if (!animList.contains(name))
			animList.push(name);
		curAnim = animList.indexOf(name);
		character.playAnim(name);

		rebuildAnimDropDown();
		updateTexts();
		genBoyOffsets(false);
		updateOffsetDisplay();
	}

	function onAnimRemove():Void
	{
		if (currentCharacterData == null || animList.length == 0)
			return;

		var name = animList[curAnim];
		currentCharacterData.animations = currentCharacterData.animations.filter(a -> a.name != name);
		animList.remove(name);
		character.animOffsets.remove(name);

		curAnim = Std.int(Math.max(0, curAnim - 1));
		rebuildAnimDropDown();
		if (animList.length > 0)
			character.playAnim(animList[curAnim]);
		updateTexts();
		genBoyOffsets(false);
		updateOffsetDisplay();
	}

	//
	// Sync Offsets + Saving Logic
	//

	function syncOffsetToCharData(animName:String, offsets:Array<Dynamic>):Void
	{
		if (currentCharacterData == null)
			return;

		for (anim in currentCharacterData.animations)
		{
			if (anim.name == animName)
			{
				anim.offsets = [offsets[0], offsets[1]];
				return;
			}
		}
	}

	function saveToJson():Void
	{
		if (currentCharacterData == null)
			return;
		if (imageFileInput != null)
			currentCharacterData.assetPath = imageFileInput.text.trim();
		if (flipXCheck != null)
			currentCharacterData.flipX = flipXCheck.checked;
		if (singDurStepper != null)
			currentCharacterData.singDuration = singDurStepper.value;
		if (scaleStepper != null)
			currentCharacterData.scale = scaleStepper.value;

		if (healthIconInput != null && currentCharacterData.healthIcon != null)
			currentCharacterData.healthIcon.id = healthIconInput.text.trim();

		for (animName => offsets in character.animOffsets)
			syncOffsetToCharData(animName, offsets);

		var jsonString = Json.stringify(currentCharacterData, null, '\t');
		var fileName = daAnim + '.json';

		_file = new FileReference();
		_file.addEventListener(Event.COMPLETE, onSaveComplete);
		_file.addEventListener(Event.CANCEL, onSaveCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file.save(jsonString, fileName);
	}

	override function update(elapsed:Float):Void
	{
		// Update the animation text
		if (character != null && character.animation != null)
		{
			textAnim.text = character.animation.curAnim.name + '  (' + (character.animation.curAnim.curFrame + 1) + ' / '
				+ character.animation.curAnim.numFrames + ')';
		}

		// Show / Hide UI Elements
		if (FlxG.keys.justPressed.H)
		{
			uiVisible = !uiVisible;
			panelGroup.visible = uiVisible;
			animationDropdown.visible = uiVisible;
			characterDropdown.visible = uiVisible;
			dumbTexts.visible = uiVisible;
			textOffset.visible = uiVisible;
		}

		// Onion Skin toggle
		if (FlxG.keys.justPressed.O)
		{
			onionSkinVisible = !onionSkinVisible;
			if (characterBackground != null)
				characterBackground.alpha = onionSkinVisible ? 0.75 : 0.0;
		}

		// Exit to Main Menu.
		// If you were in PlayState, you can also return back to it.
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Q)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.music.stop();
			FlxG.switchState(new funkin.ui.mainmenu.MainMenuState());
		}
		else if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.BACKSPACE)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.music.stop();
			FlxG.switchState(new funkin.play.PlayState());
		}

		// Save to JSON.
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveToJson();

		// Flip Character on its X Axis.
		if (FlxG.keys.justPressed.F)
		{
			character.flipX = !character.flipX;
			characterBackground.flipX = character.flipX;
		}

		// If your mouse is over the panel, don't zoom or pan the camera.
		var mouseOverPanel = FlxG.mouse.x > FlxG.width - PANEL_W;
		if (!mouseOverPanel)
		{
			// Zoom Camera using your scroll wheel.
			if (FlxG.mouse.wheel != 0)
			{
				FlxG.camera.zoom += FlxG.mouse.wheel * 0.1;
				FlxG.camera.zoom = Math.max(0.1, Math.min(8.0, FlxG.camera.zoom));
			}

			// Pan the camera around using your middle mouse button.
			if (FlxG.mouse.pressedMiddle)
			{
				camFollow.x -= FlxG.mouse.deltaScreenX / FlxG.camera.zoom;
				camFollow.y -= FlxG.mouse.deltaScreenY / FlxG.camera.zoom;
			}
		}

		// Cycle Animations
		if (FlxG.keys.justPressed.W)
			curAnim -= 1;
		if (FlxG.keys.justPressed.S && !FlxG.keys.pressed.CONTROL)
			curAnim += 1;

		if (curAnim < 0)
			curAnim = animList.length - 1;
		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.SPACE)
		{
			if (animList.length > 0)
			{
				character.playAnim(animList[curAnim]);
				if (animationDropdown != null)
					animationDropdown.selectedLabel = animList[curAnim];

				updateOffsetDisplay();
				updateTexts();
				genBoyOffsets(false);
			}
		}

		// Offset Adjustment
		var mutliplier = FlxG.keys.pressed.SHIFT ? 10 : 1;
		var up_arrow = FlxG.keys.anyJustPressed([UP]);
		var down_arrow = FlxG.keys.anyJustPressed([DOWN]);
		var left_arrow = FlxG.keys.anyJustPressed([LEFT]);
		var right_arrow = FlxG.keys.anyJustPressed([RIGHT]);

		if ((up_arrow || down_arrow || left_arrow || right_arrow) && animList != null)
		{
			var offsets = character.animOffsets.get(animList[curAnim]);
			if (offsets != null)
			{
				if (up_arrow)
					offsets[1] += 1 * mutliplier;
				if (down_arrow)
					offsets[1] -= 1 * mutliplier;
				if (left_arrow)
					offsets[0] += 1 * mutliplier;
				if (right_arrow)
					offsets[0] -= 1 * mutliplier;

				syncOffsetToCharData(animList[curAnim], offsets);
				updateOffsetDisplay();
				updateTexts();
				genBoyOffsets(false);
				character.playAnim(animList[curAnim]);
			}
		}

		// Update dropdowns EVERY SINGLE FRAME to prevent layering issues.
		// TODO: find a better way to do this.
		members.remove(animationDropdown);
		members.remove(characterDropdown);
		members.push(animationDropdown);
		members.push(characterDropdown);

		super.update(elapsed);
	}

	var _file:FileReference;

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;

		FlxG.log.notice('[ANIMATION EDITOR] Saved successfully.');
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;

		FlxG.log.error('[ANIMATION EDITOR] Save failed, Please try again.');
	}
}
