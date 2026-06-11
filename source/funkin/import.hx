package funkin;

/**
 * Funkin Imports
 * This file contains all the imports required for the game to run.
 */
#if !macro
import funkin.data.character.*;
import funkin.data.stage.*;
import funkin.data.story.level.*;
import funkin.data.song.*;
import funkin.graphics.video.*;
import funkin.input.*;
import funkin.play.*;
import funkin.play.character.*;
import funkin.play.components.*;
import funkin.play.components.shaders.*;
import funkin.play.cutscene.*;
import funkin.play.notes.*;
import funkin.play.song.*;
import funkin.play.stage.boppers.*;
import funkin.play.stage.*;
import funkin.save.*;
import funkin.ui.*;
import funkin.ui.debug.*;
import funkin.ui.debug.animation.*;
import funkin.ui.debug.charting.*;
import funkin.ui.freeplay.*;
import funkin.ui.mainmenu.*;
import funkin.ui.mainmenu.components.*;
import funkin.ui.options.*;
import funkin.ui.options.components.*;
import funkin.ui.story.*;
import funkin.ui.story.components.*;
import funkin.ui.title.*;
import funkin.ui.transition.*;
import funkin.ui.transition.preload.*;
import funkin.util.*;
import funkin.util.macro.*;


/**
 * Flixel Imports
 * 
 * Adding the most used classes from flixel here
 * so I don't have to keep referencing them in every file.
 */
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

using StringTools;
#end
