package funkin.play.cutscene;

import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

using StringTools;

/**
 * DIALOGUE BOX CLASS
 * 
 * A resusable class for dialogue boxes that supports pixel-art and standard styles.
 */
class DialogueBox extends FlxSpriteGroup
{
	/**
	 * Legacy `Alphabet` dialogue object - KEPT FOR COMPATIBILITY.
	 */
	var dialogueObject:Alphabet;

	/**
	 * The dialogue box background sprite. (like the name of the class!! :0)
	 */
	var dialogueBox:FlxSprite;

	/**
	 * Background fade overlay
	 */
	var backgroundFade:FlxSprite;

	/**
	 * Left-side portrait (opponent/dad).
	 */
	var portraitLeft:FlxSprite;

	/**
	 * Right-side portrait (boyfriend).
	 */
	var portraitRight:FlxSprite;

	/**
	 * Alternative `portraitLeft` sprite for the thorns dialogue box.
	 */
	var portraitLeft_spirit:FlxSprite;

	/**
	 * Hand cursor showed when dialogue is complete.
	 */
	var handSelect:FlxSprite;

	/**
	 * Drop shadow text behind the main dialogue text.
	 */
	var dropText:FlxText;

	/**
	 * The skip hint text element; press `BACKSPACE` to skip.
	 */
	var skipHint:FlxText;

	/**
	 * The animated typewriter text element for dialogue.
	 * swagDialogue
	 */
	var animatedDialogue:FlxTypeText;

	//
	// STATE VARIABLES
	//

	/**
	 * The remaining lines of dialogue to display.
	 */
	var dialogueList:Array<String> = [];

	/**
	 * Which character is currently speaking.
	 */
	var currentCharacter:String = '';

	//
	// BOOLEAN VARIABLES
	//

	/**
	 * Whether the dialogue box is currently open.
	 * @default false
	 */
	var dialogueOpened:Bool = false;

	/**
	 * Whether the first line of dialogue has started.
	 * @default false
	 */
	var dialogueStarted:Bool = false;

	/**
	 * Whether the current line has finished typing.
	 * @default false
	 */
	var dialogueComplete:Bool = false;

	/**
	 * Whether the closing sequence has started.
	 * @default false
	 */
	var isEnding:Bool = false;

	//
	// CALLBACKS
	//

	/**
	 * Called when all dialogue lines have been shown, and the box closes.
	 */
	public var onDialogueComplete:Void->Void;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String> = null)
	{
		super();

		PlayState.inDialogue = true;

		this.dialogueList = dialogueList ?? [];

		setupBackgroundOverlay();

		var hasDialogue:Bool = setupDialogueBox();
		if (!hasDialogue) // If there is no dialogue, don't do anything.
			return;

		setupPortraits(talkingRight);
		setupText();

		trace('DIALOGUE BOX: Initialization complete.');
	}

	//
	// UI ELEMENTS
	//

	/**
	 * Create a basic background fade overlay.
	 */
	private function setupBackgroundOverlay():Void
	{
		backgroundFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		backgroundFade.scrollFactor.set();
		backgroundFade.alpha = 0;
		add(backgroundFade);

		new FlxTimer().start(0.83, function(_)
		{
			// Smoothly fade in to 70% opacity over 6 seconds.
			backgroundFade.alpha = Math.min(backgroundFade.alpha + (1 / 5) * 0.7, 0.7);
		}, 6);

		// If the song is roses, skip the fade in.
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			backgroundFade.alpha = 0.7;
	}

	/**
	 * Plays the opening music for the dialogue box depending on the stage, or character.
	 */
	private function setupMusic():Void
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox', 'week6'), 0);
        FlxG.sound.music.fadeIn(1, 0, 0.8);
      case 'thorns':
        FlxG.sound.playMusic(Paths.music('LunchboxScary', 'week6'), 0);
        FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
	}

	/**
	 * Creates the dialogue box sprite with the correct skin for the current song, or stage.
	 * @return Whether or not a song has dialogue.
	 */
	private function setupDialogueBox():Bool
	{
		dialogueBox = new FlxSprite(-20, 45);
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogueBox.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
				dialogueBox.animation.addByPrefix('open_textBox', 'Text Box Appear', 24, false);
				dialogueBox.animation.addByIndices('static_textBox', 'Text Box Appear instance 1', [4], "", 0);
				dialogueBox.animation.addByIndices('close_textBox', 'Text Box Appear instance 1', [4, 3, 2, 1, 0], "", 24, false);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				dialogueBox.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad', 'week6');
				dialogueBox.animation.addByPrefix('open_textBox', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				dialogueBox.animation.addByIndices('static_textBox', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 0);
				dialogueBox.animation.addByIndices('close_textBox', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 24, false);
			case 'thorns':
				dialogueBox.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6');
				dialogueBox.animation.addByPrefix('open_textBox', 'Spirit Textbox spawn', 24, false);
				dialogueBox.animation.addByIndices('static_textBox', 'Spirit Textbox spawn instance 1', [11], "", 0);
				dialogueBox.animation.addByIndices('close_textBox', 'Spirit Textbox spawn instance 1', [11, 8, 4, 1, 0], "", 24, false);

				portraitLeft_spirit = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward', 'week6'));
				portraitLeft_spirit.setGraphicSize(Std.int(portraitLeft_spirit.width * 6));
				portraitLeft_spirit.visible = false;
				add(portraitLeft_spirit);
			default:
				return false;
		}
		dialogueBox.animation.play('open_textBox');
		dialogueBox.setGraphicSize(Std.int(dialogueBox.width * PlayState.daPixelZoom * 0.9));
		dialogueBox.updateHitbox();
		dialogueBox.screenCenter(X);
		add(dialogueBox);

		return true;
	}

	/**
	 * Creates and adds the left and right portrait sprites.
	 */
	private function setupPortraits(talkingRight:Bool):Void
	{
		portraitLeft = new FlxSprite(-20, 40);
    portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait', 'week6');
    portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
    portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
    portraitLeft.updateHitbox();
  	portraitLeft.scrollFactor.set();
    portraitLeft.visible = false;
    add(portraitLeft);

    portraitRight = new FlxSprite(0, 40);
    portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'week6');
    portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
    portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
    portraitRight.updateHitbox();
    portraitRight.scrollFactor.set();
    portraitRight.visible = false;
    add(portraitRight);

    portraitLeft.screenCenter(X);
	}

	/**
	 * Creates the typewriter text, drop shadow, and hand cursor elements.
	 */
	private function setupText():Void
	{
		handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox', 'week6'));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
		handSelect.updateHitbox();
		handSelect.visible = false;
		add(handSelect);

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
    dropText.font = 'Pixel Arial 11 Bold';
    dropText.color = 0xFFD89494;
    add(dropText);

		skipHint = new FlxText(25, 0, Std.int(FlxG.width * 0.6), "", 0);
		skipHint.setFormat(Paths.font("vcr.ttf"), 24, 0xFFD89494, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, 0xFF3F2021);
		skipHint.text = "[BACKSPACE] - Skip Dialogue";
		skipHint.visible = false;
		add(skipHint);

		animatedDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		animatedDialogue.font = 'Pixel Arial 11 Bold';
		animatedDialogue.color = 0xFF3F2021;
		animatedDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.5)];
		add(animatedDialogue);

		dialogueObject = new Alphabet(0, 80, "", false, true);
	}

	//
	// HELPER FUNCTIONS
	//

	override function update(elapsed:Float):Void
	{
		switch (PlayState.SONG.song.toLowerCase())
    {
      case 'roses':
        portraitLeft.visible = false;
      case 'thorns':
        animatedDialogue.color = FlxColor.WHITE;
        dropText.color = FlxColor.BLACK;
    }

		dropText.text = animatedDialogue.text;

		// Check if the dialogue box has been opened, and set the dialogue started flag.
		if (dialogueBox.animation.curAnim != null && dialogueBox.animation.curAnim.name == 'open_textBox')
		{
			if (dialogueBox.animation.curAnim.finished)
			{
				dialogueBox.animation.play('static_textBox');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			setupMusic();
			dialogueStarted = true;
		}

		// If the enter key is pressed, handle basic dialogue input.
		if (FlxG.keys.justPressed.ENTER && dialogueOpened && dialogueStarted)
			handleInput();
		// If the backspace key is pressed, skip the entire dialogue segment,
		// and skip to gameplay. 
		if (FlxG.keys.justPressed.BACKSPACE && isEnding != true)
		{
			trace('DIALOGUE BOX: BACKSPACE key pressed. Closing dialogue box...');
			closeDialogue();
		}

		super.update(elapsed);
	}

	private function handleInput():Void
	{
		// Disable any further input if the dialogue is complete.
		if (isEnding)
			return;

		// If the text is still typing, snap it to completion.
		if (!dialogueComplete)
		{
			animatedDialogue.skip();
			trace('DIALOGUE BOX: Dialogue skipped.');
			return;
		}

		if (dialogueObject != null)
			remove(dialogueObject);

		FlxG.sound.play(Paths.sound('clickText'), 0.7);

		final isLastLine:Bool = dialogueList[1] == null && dialogueList[0] != null;
		if (isLastLine)
		{
			closeDialogue();
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
	}

	//
	// DIALOGUE LOGIC
	//

	/**
	 * Starts displaying the next line of dialogue.
	 */
	private function startDialogue():Void
	{
		parseNextLine();

		animatedDialogue.resetText(dialogueList[0]);
		animatedDialogue.start(0.04, true);
		animatedDialogue.completeCallback = function()
		{
			skipHint.visible = true;
			handSelect.visible = true;
			dialogueComplete = true;
			trace('DIALOGUE BOX: Dialogue section complete.');
		};

		handSelect.visible = false;
		dialogueComplete = false;

		updatePortraits();
	}

	/**
	 * Starts the closing sequence for the dialogue box.
	 */
	private function closeDialogue():Void
	{
		trace('DIALOGUE BOX: All dialogue complete. Closing dialogue box...');

		if (isEnding)
			return;

		isEnding = true;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai' | 'roses' | 'thorns':
				FlxG.sound.music.fadeOut(2.5, 0);
		}

		// Close the dialogue box, and hide its elements.
		dialogueBox.animation.play('close_textBox');
		animatedDialogue.visible = dropText.visible = false;
		handSelect.visible = false;

		// Fade all elements out over 6 ticks.
		new FlxTimer().start(0.3, function(_)
		{
			skipHint.alpha -= 1 / 5;
			dialogueBox.alpha -= 1 / 5;
			backgroundFade.alpha -= 1 / 5 * 0.9;

			// Add special fade effect for Roses and Thorns.
			// in 6 ticks.
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'roses':
					portraitRight.alpha -= 1 / 5;
				case 'thorns':
					portraitLeft_spirit.alpha -= 1 / 5;
				default: 
					// Otherwise, just hide the portraits normally.
					portraitRight.visible = portraitLeft.visible = false;
			}
		}, 6);

		new FlxTimer().start(1.5, function(_)
		{
			Paths.clearUnusedMemory();
			onDialogueComplete();
			kill();
		});

		trace('DIALOGUE BOX: Dialogue box closed. Now returning to gameplay.');
	}

	//
	// MISC FUNCTIONS
	//

	/**
  * Parses the character tag from the front of the current dialogue line.
  * Format: `line text:characterName`
  */
  private function parseNextLine():Void
  {
    var splitName:Array<String> = dialogueList[0].split(":");
    currentCharacter = splitName[1];
    dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
  }

	/**
  * Shows or hides portraits based on who is currently speaking.
  */
  private function updatePortraits():Void
  {
    switch (currentCharacter)
    {
      case 'senpai':
        portraitRight.visible = false;
        if (!portraitLeft.visible)
        {
					portraitLeft.visible = true;
          portraitLeft.animation.play('enter');
        }
			case 'spirit':
				portraitRight.visible = false;
				portraitLeft.visible = false;
				if (!portraitLeft_spirit.visible)
				{
					// Manually fade the spirit face in over 6 ticks.
					portraitLeft_spirit.alpha = 0;
					new FlxTimer().start(0.2, function(_)
					{
						portraitLeft_spirit.alpha += 1 / 5;
						portraitLeft_spirit.visible = true;
					}, 6);
				}
      case 'bf':
        portraitLeft.visible = false;
        if (!portraitRight.visible)
        {
          portraitRight.visible = true;
          portraitRight.animation.play('enter');
        }
    }
  }
}
