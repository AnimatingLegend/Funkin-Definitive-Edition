package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import flash.media.Sound;

#if discord_rpc
import backend.Discord.DiscordClient;
#end

import objects.Note;
import objects.HealthIcon;

import backend.Conductor.BPMChangeEvent;
import backend.Section.SwagSection;
import backend.Song;
import backend.Song.SwagSong;

using StringTools;


/**
	* yckenn's chart editor for fnf-simple-engine (0.1.0)
	* tweaks made by legend
**/
class ChartingState extends MusicBeatState
{
	var curZoom:Int;
	var zoomList:Array<Float> = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

	var desc:String = "
	W/S or Mouse Wheel - Change Conductors strum time
	A/D - Go to the previous/next section
	Q/E - Decrease/Increase Note Sustain Length
	Space - Stop/Resume song
	Enter - Exit from Chart Editor";

	var strumColors:Array<FlxColor> = [0xd64cd6, 0x00fff2, 0x28f000, 0xff3d3d];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;
	var Charting_box:FlxUITabMenu;
	var startPos:Float;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var hitNotesPlayed:Array<Dynamic> = [];

	public static var lastSection:Int = 0;

	public static var hitsoundsDads:Bool = false;
	public static var hitsoundsBFs:Bool = false;

	public static var muteVocals:Bool = false;
	public static var muteSong:Bool = false;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var typingDiff:FlxInputText;
	var diffInt:Int = PlayState.storyDifficulty;
	var diffString:String;

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var icon:HealthIcon;

	var gridBlackLine:FlxSprite;

	override function create()
	{
		curSection = lastSection;

		var bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		var tipsBullshit:FlxText = new FlxText(650, FlxG.height - 258, 0, "", 16);
		tipsBullshit.scrollFactor.set();
		tipsBullshit.setFormat(16, FlxColor.WHITE, RIGHT);
		tipsBullshit.text += desc;
		add(tipsBullshit);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		gridBG.x = GRID_SIZE * 7;
		gridBG.y = GRID_SIZE * 1;
		add(gridBG);

		icon = new HealthIcon('face');
		icon.scrollFactor.set(1, 1);
		icon.setGraphicSize(0, 45);
		add(icon);
		icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gfVersion: 'gf',
				speed: 1,
				validScore: false
			};
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		strumLine = new FlxSprite(0 + gridBG.x, 50 - gridBG.y).makeGraphic(GRID_SIZE * 8, 4, FlxColor.BLUE);
		add(strumLine);

		dummyArrow = new FlxSprite(-FlxG.width * 10, FlxG.width * 10).makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Assets", label: 'Assets'},
			{name: "Tools", label: 'Tools'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + GRID_SIZE * 4;
		UI_box.y = 20;
		add(UI_box);

		bpmTxt = new FlxText(UI_box.x + UI_box.width, 50, 0, '', 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		getDiff();

		addSongUI();
		addSectionUI();
		addNoteUI();
		addAssetsUI();
		addToolsUI();
		updateHeads();

		add(curRenderedSustains);
		add(curRenderedNotes);

		super.create();
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperSongSpeed:FlxUINumericStepper;

	function getDiff()
	{
		if (diffInt == 0)
			diffString = 'easy';
		else if (diffInt == 1)
			diffString = 'normal';
		else if (diffInt == 2)
			diffString = 'hard';

		FlxG.log.add('DiffInt: ' + diffInt);
	}

	function addToolsUI():Void
	{
		var tab_group_tools = new FlxUI(null, UI_box);
		tab_group_tools.name = 'Tools';

		var hitSoundsDad = new FlxUICheckBox(10, 5, null, null, "Opponents hitsounds", 150);
		hitSoundsDad.checked = ChartingState.hitsoundsDads;
		hitSoundsDad.callback = function()
		{
			ChartingState.hitsoundsDads = hitSoundsDad.checked;
		};
		var hitSoundsBF = new FlxUICheckBox(10, 25, null, null, "Players hitsounds", 150);
		hitSoundsBF.checked = ChartingState.hitsoundsBFs;
		hitSoundsBF.callback = function()
		{
			ChartingState.hitsoundsBFs = hitSoundsBF.checked;
		};
		var muteSongCB = new FlxUICheckBox(10, 45, null, null, "Mute song", 150);
		muteSongCB.checked = muteSong;
		muteSongCB.callback = function()
		{
			muteSong = muteSongCB.checked;
		};
		var muteVocalsCB = new FlxUICheckBox(10, 65, null, null, "Mute vocals", 150);
		muteVocalsCB.checked = muteVocals;
		muteVocalsCB.callback = function()
		{
			muteVocals = muteVocalsCB.checked;
		};

		stepperSongSpeed = new FlxUINumericStepper(10, 85, 5, 4, 5, 1000);
		stepperSongSpeed.value = 100;
		stepperSongSpeed.name = 'editor_speed';

		var songSpeedLabel = new FlxText(10 + stepperSongSpeed.width + 3, 85, 0, 'Editor song speed in %');

		tab_group_tools.add(hitSoundsDad);
		tab_group_tools.add(hitSoundsBF);
		tab_group_tools.add(muteSongCB);
		tab_group_tools.add(muteVocalsCB);
		tab_group_tools.add(stepperSongSpeed);
		tab_group_tools.add(songSpeedLabel);

		UI_box.addGroup(tab_group_tools);
	}

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel = new FlxText(10 + stepperSusLength.width + 3, 10, 0, 'Sustain note length');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);

		UI_box.addGroup(tab_group_note);
	}


	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var UI_diffTitle = new FlxUIInputText(10, 30, 70, diffString, 8);
		typingDiff = UI_diffTitle;

		var songTitleLabel = new FlxText(80, 10, 64, 'Song name');
		var diffTitleLabel = new FlxText(80, 30, 128, 'Song Difficulty');

		var saveButton:FlxButton = new FlxButton(210, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x, 38, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(saveButton.x, 68, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(saveButton.x, 96, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var speedLabel = new FlxText(70, 80, 64, 'Song speed');
		var bpmLabel = new FlxText(70, 65, 64, 'BPM');

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(UI_diffTitle);

		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(songTitleLabel);
		tab_group_song.add(diffTitleLabel);
		tab_group_song.add(speedLabel);
		tab_group_song.add(bpmLabel);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
	}

	function addAssetsUI()
	{
		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";
	
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfVersions:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
	
		var player1DropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 30, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;
	
		var gfVersionDropDown = new FlxUIDropDownMenu(10, 80, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
		{
			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
	
		var stageDropDown = new FlxUIDropDownMenu(140, 80, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;
	
		var player1Label = new FlxText(10, 10, 64, 'Player');
		var player2Label = new FlxText(140, 10, 64, 'Opponent');
		var gfVersionLabel = new FlxText(10, 60, 64, 'Girlfriend');
		var stageLabel = new FlxText(140, 60, 64, 'Stage');
	
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);

		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(gfVersionLabel);
	
	
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);


		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);

		UI_box.addGroup(tab_group_assets);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
	//	check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 330, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote != null)
					curSelectedNote[2] = nums.value;
				else
					trace("PICK NOTE!!!!!!!!");
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.playing)
		{
			#if cpp
			@:privateAccess
			{
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH,
					stepperSongSpeed.value / (1 * 100));
				if (vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, stepperSongSpeed.value / (1 * 100));
			}
			#end
		}

		for (i in 0...curRenderedNotes.length)
		{
			if (curRenderedNotes.members[i].y < (strumLine.y + 5))
				curRenderedNotes.members[i].alpha = 0.65;
			else
				curRenderedNotes.members[i].alpha = 1;
		}
		for (i in 0...curRenderedSustains.length)
		{
			if (curRenderedSustains.members[i].y + curRenderedSustains.members[i].height < (strumLine.y + 5))
				curRenderedSustains.members[i].alpha = 0.65;
			else
				curRenderedSustains.members[i].alpha = 1;
		}

		curStep = recalculateSteps();

		Conductor.songPosition = Std.int(FlxG.sound.music.time);

		_song.song = typingShit.text;
		diffString = typingDiff.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}
		else if (strumLine.y < -10)
		{
			if (_song.notes[curSection - 1] == null)
			{
				FlxG.sound.music.time = 0;
				vocals.time = FlxG.sound.music.time;
			}

			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('curBeat', curBeat);
		FlxG.watch.addQuick('curStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (ChartingState.hitsoundsDads)
			{
				for (note in _song.notes[curSection].sectionNotes)
				{
					var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;
	
					if (note[1] > 4 - 1)
					{
						gottaHitNote = !_song.notes[curSection].mustHitSection;
					}
					if (note[0] <= Conductor.songPosition
						&& FlxG.sound.music.playing
						&& !hitNotesPlayed.contains(note)
						&& !gottaHitNote)
					{
						hitNotesPlayed.push(note);
						FlxG.sound.play(Paths.sound("hitsound"), 1);
					}
				}
			}
	
		if (ChartingState.hitsoundsBFs)
		{
			for (note in _song.notes[curSection].sectionNotes)
			{
					var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;
	
				if (note[1] > 4 - 1)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}
				if (note[0] <= Conductor.songPosition
					&& FlxG.sound.music.playing
					&& !hitNotesPlayed.contains(note)
					&& gottaHitNote)
				{
					hitNotesPlayed.push(note);
					FlxG.sound.play(Paths.sound("hitsound"), 1);
				}
			}
		}
	
		if (muteSong)
			FlxG.sound.music.volume = 0.000001;
		else
			FlxG.sound.music.volume = 1;
	
		if (muteVocals)
			vocals.volume = 0.000001;
		else
			vocals.volume = 1;

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (FlxG.keys.justPressed.X)
			toggleAltAnimNote();

		if (!typingShit.hasFocus || !typingDiff.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					hitNotesPlayed = [];
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;

				hitNotesPlayed = [];
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;

					hitNotesPlayed.splice(0, hitNotesPlayed.length);
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;

					hitNotesPlayed.splice(0, hitNotesPlayed.length);
				}
			}
		}

		_song.bpm = tempBpm;

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = 'Song: ' + _song.song + '\nDifficulty: ' + diffString + "\n\nPos:"
			+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2) + " / " + FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2) + "\nSong BPM: "
			+ tempBpm + "\nSection: " + curSection + "\nCurbeat: " + curBeat + "\nCurstep: " + curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function toggleAltAnimNote():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[3] != null)
			{
				trace('ALT NOTE SHIT');
				curSelectedNote[3] = !curSelectedNote[3];
				trace(curSelectedNote[3]);
			}
			else
				curSelectedNote[3] = true;
		}
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			songBeginning = true;
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			remove(icon);
			icon = new HealthIcon(_song.player1);
			icon.scrollFactor.set(1, 1);
			icon.setGraphicSize(0, 45);
			add(icon);
			icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);
		}
		else if (!check_mustHitSection.checked)
		{
			remove(icon);
			icon = new HealthIcon(_song.player2);
			icon.scrollFactor.set(1, 1);
			icon.setGraphicSize(0, 45);
			add(icon);
			icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);
		}
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			updateHeads();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + gridBG.x;
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x - 3 + (GRID_SIZE / 2), note.y - 4 + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height))); 
				sustainVis.color = strumColors[note.noteData];
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		if (diffString == 'normal')
		{
			FlxG.log.add('Normal');
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			PlayState.storyDifficulty = 1;
		}
		else if (diffString == 'hard' || diffString == 'easy' || diffString == 'normal')
		{
			FlxG.log.add('Loading chart...');
			if (diffString == 'normal')
				PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			else
				PlayState.SONG = Song.loadFromJson(song.toLowerCase() + '-' + diffString, song.toLowerCase());
			if (diffString == 'easy')
				PlayState.storyDifficulty = 0;
			else if (diffString == 'normal')
				PlayState.storyDifficulty = 1;
			else if (diffString == 'hard')
				PlayState.storyDifficulty = 2;
		}
		else if (diffString != 'hard' || diffString != 'easy' || diffString != 'normal')
		{
			FlxG.log.add('Unknown difficulty');
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			PlayState.storyDifficulty = 1;
		}

		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

			if (diffString == 'normal')
				_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			else
				_file.save(data.trim(), _song.song.toLowerCase() + "-" + diffString + ".json");
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