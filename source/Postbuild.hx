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
               Sys.println('[INFO] Build took: ${formatTime(END - START)}');
          }
     }

     static function formatTime(time:Float, decimals:Int = 1):String
     {
          var timeUnits = [
               {name: "day", seconds: 86400}, 
               {name: "hour", seconds: 3600}, 
               {name: "minute", seconds: 60}, 
               {name: "second", seconds: 1},
          ];

          var parts:Array<String> = [];
          var remaining:Float = time;
          var factor = Math.pow(10, decimals); // compute once because the old code was computing it twice.

          for (unit in timeUnits)
          {
               var value:Float = (unit.name == "second") 
                    ? Math.round(remaining * factor) / factor 
                    : Math.floor(remaining / unit.seconds);
               
               if (unit.name != "second") remaining %= unit.seconds;
               if (value > 0 || (unit.name == "second" && parts.length == 0))
               {
                    parts.push('${value} ${unit.name}${value == 1 ? "" : "s"}');
               }
          }

          return parts.join(' ');
     }
}
