package funkin.play;

import flixel.addons.transition.FlxTransitionableState;
import funkin.play.PlayState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.freeplay.FreeplayState;
import funkin.util.Paths;

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	public function new():Void
		super();

	override function create()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.destroy();
			FlxG.sound.music = null;
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		bg.setGraphicSize(Std.int(FlxG.width));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		bf.screenCenter(X);
		bf.antialiasing = FlxG.save.data.antialiasing;
		add(bf);

		replayButton = new FlxSprite(FlxG.width * 0.25, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		replayButton.antialiasing = FlxG.save.data.antialiasing;
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		cancelButton.antialiasing = FlxG.save.data.antialiasing;
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			changeThing();
		if (controls.ACCEPT)
		{
			if (replaySelect)
			{
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				FlxG.switchState(new PlayState());
			}
			else
			{
				if (PlayState.isStoryMode)
				{
					FlxG.switchState(new StoryMenuState());
				}
				else
				{
					FlxG.switchState(new FreeplayState());
				}
			}
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
