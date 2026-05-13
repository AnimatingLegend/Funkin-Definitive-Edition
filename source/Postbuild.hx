package source;

import sys.FileSystem;
import sys.io.File;

/**
 * A script to run after building.
 */
class Postbuild
{
     static inline final BUILD_TIME_FILE:String = '.build_time';
     static function main():Void
     {
          getBuildTime();
     }

     static function getBuildTime():Void
     {
          var END:Float = Sys.time();
          if (FileSystem.exists(BUILD_TIME_FILE))
          {
               var FILE_INPUT:sys.io.FileInput = File.read(BUILD_TIME_FILE);
               var START:Float = FILE_INPUT.readDouble();
               FILE_INPUT.close();

               sys.FileSystem.deleteFile(BUILD_TIME_FILE);

               var buildTime:Float = roundToTwoDecimals(END - START);
               trace('Build took: ${buildTime} seconds.');
          }
     }

     static function roundToTwoDecimals(value:Float):Float
     {
          return Math.round(value * 100) / 100;
     }
}
