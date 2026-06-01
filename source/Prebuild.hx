package source;

import sys.io.File;

/**
 * A script to run before building.
 */
class Prebuild
{
     static inline final BUILD_TIME_FILE:String = '.build_time';
     static function main():Void
     {
          saveBuildTime();
          trace('INFO: Prebuilding the game...');
     }

     static function saveBuildTime():Void
     {
          var FILE_OUTPUT:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
          var NOW:Float = Sys.time();
          FILE_OUTPUT.writeDouble(NOW);
          FILE_OUTPUT.close();
     }
}