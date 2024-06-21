package;
#if !macro

#if discord_rpc
import backend.Discord;
import backend.Discord.DiscordClient;
#end
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.DefinitiveData;
import backend.Conductor;

#if (windows && !html5)
import hxcodec.flixel.FlxVideo as VideoHandler;
import hxcodec.flixel.FlxVideoSprite as VideoSprite;
#else
import cutscenes.FlxVideo;
#end

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;
#end