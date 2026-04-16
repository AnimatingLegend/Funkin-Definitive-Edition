package funkin.gameplay;

import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

import lime.utils.Assets;

import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

import haxe.Json;
import haxe.macro.Expr.Case;

import funkin.backend.chart.Conductor;
import funkin.backend.chart.Song.SwagSong;
import funkin.backend.chart.Song;
import funkin.backend.chart.Section.SwagSection;
import funkin.backend.utils.Highscore;

#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") 
import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") 
import VideoHandler as VideoHandler;
#else
import funkin.backend.media.FlxVideo;
#end

import funkin.menus.FreeplayState;
import funkin.menus.GitarooPause;
import funkin.menus.StoryMenuState;
import funkin.menus.LoadingState;

import funkin.editors.ChartingState;
import funkin.editors.AnimationDebug;

import funkin.gameplay.PauseSubState;
import funkin.gameplay.objects.note.Note;
import funkin.gameplay.objects.note.NoteSplash;
import funkin.gameplay.objects.note.NoteSplash.NoteSplashPixel;
import funkin.gameplay.objects.Character;
import funkin.gameplay.shaders.BuildingShaders;
import funkin.gameplay.shaders.WiggleEffect;

using StringTools;

class PlayStateTest extends MusicBeatState
{
     /**
      * The entire instance of `PlayStateTest`.
      */
     public static var instance:PlayStateTest = null;

     /**
      * The currently selected song, stage, & difficulty.
      */
     public var currentSong:String = '';
     public var currentStage:String = '';
     public var currentDifficulty:Array<String> = ['-easy', '-normal', '-hard'];

     /**
      * The currently selected vocals.
      */
     public var currentVocals:FlxSound;

     /**
      * Get song data, as well as the song name.
      */
     public static var SONG:SwagSong;
     public var songName:String;

     /**
      * Checks if the game is in story mode.
      */
     public static var isStoryMode:Bool = false;
     public static var storyWeek:Int = 0;
     public static var storyPlaylist:Array<String> = [];
     public static var storyDifficulty:Int = 1;

     /**
      * Get character data for boyfriend, dad, & girlfriend.
      */
     public var boyfriend:Character = null;
     public var dad:Character = null;
     public var girlfriend:Character = null;

     /**
      * The speed of girlfriend's dance animations.
      */
     public var girlfriendSpeed:Int = 1;

     /**
      * Get sprite groups for boyfriend, dad, & girlfriend.
      */
     public var boyfriendGroup:FlxSpriteGroup;
     public var dadGroup:FlxSpriteGroup;
     public var girlfriendGroup:FlxSpriteGroup;

     /**
      * Get sprite groups for notes strum lines, & note splashes.
      */
     public var notes:FlxTypedGroup<Note>;
     public var unspawnNotes:Array<Note> = [];
     public var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
     public var opponentStrums:FlxTypedGroup<FlxSprite> = null;
     public var playerStrums:FlxTypedGroup<FlxSprite> = null;
     public var noteSplashGroup:FlxTypedGroup<NoteSplash> = null;
     public var noteSplashPixelGroup:FlxTypedGroup<NoteSplashPixel> = null;

     /**
      * Get Health icons for boyfriend, & dad.
      */
     public var iconP1:HealthIcon = null;
     public var iconP2:HealthIcon = null;

     /**
      * Get the players health, as well as the health bar asset.
      */
     public var health:Float = 1;
     public var healthLerp:Float = 1;
     public var healthBar:FlxBar;
     public var healthBarBG:FlxSprite;

     /**
      * Get camera information for zoom, position, HUD, etc.
      */
     public var cameraZooming:Bool = false;
     public var cameraPosition:FlxPoint;
     public var cameraHUD:FlxCamera;
     public var cameraGame:FlxCamera;
     public var cameraOther:FlxCamera;
     public var defaultCameraZoom:Float = 1.05;
     public var cameraFollow:FlxObject;

     /**
      * Get the previous camera object that was following each player who sung.
      */
     private static var previousCameraFollow:FlxObject;

     /**
      * Get up-to-date judgement information when playing a song.
      */
     public var judgements:Array<Dynamic> = [
          { 
               sick: 0,
               good: 0,
               bad: 0,
               shit: 0,
               miss: 0,
               highestCombo: 0
          }
     ];

     public static var daPixelZoom:Float = 6;

     /**
      * Initialize a new PlayState.
      * @param params - Parameters used to initialize the PlayState, like song, stage, & difficulty.
      */
     public override function create()
     {
          // This shouldn't happen, but adding this here just in case...
          if (instance != null)
          {
               trace('[WARNING] PlayState already exists! Destroying this instance...');
               destroy();
               return;
          }
          instance = this;

          Paths.clearStoredMemory();

          FlxG.mouse.visible = false;
          if (FlxG.sound.music != null) FlxG.sound.music.stop();

          //
          // Initialize Cameras & Camera layering.
          //

          cameraGame = new FlxCamera();
          cameraHUD = new FlxCamera();
          cameraOther = new FlxCamera();
          cameraHUD.bgColor.alpha = 0;
          cameraOther.bgColor.alpha = 0;

          FlxG.cameras.reset(cameraGame);
          FlxG.cameras.add(cameraHUD, false);
          FlxG.cameras.add(cameraOther, false);

          noteSplashGroup = new FlxTypedGroup<NoteSplash>();
          noteSplashPixelGroup = new FlxTypedGroup<NoteSplashPixel>();

          FlxG.cameras.setDefaultDrawTarget(cameraGame, true);

          persistentUpdate = true;
          persistentDraw = true;

          //
          // Initialize song data
          //

          if (currentSong != SONG.song) currentSong = SONG.song;
          if (SONG == null) SONG = Song.loadFromJson('charts/tutorial');

          Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

          //
          // Initialize stage and character data.
          //

          currentStage = SONG.stage;
          trace('[STAGE] Successfully Loaded in ${currentStage} Stage.');
          trace('[SONG] Current Song: ${currentSong}');

          var stageData:StageFile = StageData.getStageFile(currentStage);
          if (stageData == null) stageData = StageData.dummyStage();

          defaultCameraZoom = stageData.defaultCamZoom;

          boyfriendGroup = new FlxSpriteGroup();
          dadGroup = new FlxSpriteGroup();
          girlfriendGroup = new FlxSpriteGroup();

          if (!currentStage) 
          {
               trace('[ERROR] No stage data found for ${currentStage}. Defaulting to week 1 stage...');
               return;
          }
          else
          {
               // TODO: Load stage data
               trace('[STAGE] Successfully loaded ${currentStage} into PlayState.');
          }

          add(boyfriendGroup);
          add(dadGroup);
          add(girlfriendGroup);

          if (SONG.gfVersion == null || SONG.gfVersion.length > 1) SONG.gfVersion = 'gf';
          girlfriend = new Character(0, 0, SONG.gfVersion);
          girlfriend.scrollFactor.set(0.95, 0.95);
          girlfriendGroup.add(girlfriend);

          dad = new Character(0, 0, SONG.player2);
          dadGroup.add(dad);

          boyfriend = new Character(0, 0, SONG.player1);
          boyfriendGroup.add(boyfriend);
          trace('[CHARACTER] Successfully loaded character into PlayState.');

          /**
           * Called after the stage is created.
           * @param stage - The stage that was just created.
           */
          stagesFunc(function(stage:BaseStage) {
               stage.createPost();
          });

          //
          // Initialize note strums.
          //

          strumLineNotes = new FlxTypedGroup<FlxSprite>();
          add(strumLineNotes);
          add(noteSplashGroup);

          var splash:NoteSplash = new NoteSplash(100, 100, 0);
          noteSplashGroup.add(splash);
          splash.alpha = 0.000001;

          var splashPixel:NoteSplashPixel = new NoteSplashPixel(100, 100, 0);
          noteSplashPixelGroup.add(splashPixel);
          splashPixel.alpha = 0.000001;

          opponentStrums = new FlxTypedGroup<FlxSprite>();
          playerStrums = new FlxTypedGroup<FlxSprite>();

          //
          // Camera setup.
          //

          cameraFollow = new FlxObject(0, 0, 1, 1);
          cameraFollow.setPosition(cameraPosition.x, cameraPosition.y);
          cameraPosition.put();

          if (previousCameraFollow != null)
          {
               cameraFollow = previousCameraFollow;
               previousCameraFollow = null;
          }
          add(cameraFollow);

          FlxG.camera.follow(cameraFollow, LOCKON, 0 * (30 / FlxG.save.data.framerateDraw));
          FlxG.camera.zoom = defaultCameraZoom;
          FlxG.camera.snapToTarget();

          FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
          FlxG.fixedTimestep = false;

          //
          // Initialize all HUD Elements.
          //

          healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !FlxG.save.data.hideHud;
		add(healthBarBG);
		if (FlxG.save.data.downscroll) healthBarBG.y = FlxG.height * 0.1;

          healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, 
               Std.int(healthBarBG.width - 8), 
               Std.int(healthBarBG.height - 8), this, 'healthLerp', 0, 2
          );
          healthBar.visible = !FlxG.save.data.hideHud;
		healthBar.scrollFactor.set();
		add(healthBar);
          healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
     }
}