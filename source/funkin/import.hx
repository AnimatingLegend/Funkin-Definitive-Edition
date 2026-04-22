package funkin;

#if !macro
// Funkin' Imports (mainly adding the ones that get called very often)
import funkin.backend.*;
import funkin.backend.chart.*;
import funkin.backend.utils.*;
import funkin.backend.utils.data.*;
import funkin.gameplay.*;
import funkin.gameplay.objects.*;
import funkin.gameplay.objects.note.*;
import funkin.gameplay.objects.stage.*;
import funkin.menus.objects.Alphabet;

// Flixel Imports
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