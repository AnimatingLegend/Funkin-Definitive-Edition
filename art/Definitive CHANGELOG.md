# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - [8/12/22]
### Initial Public Release ~ (dont expect much from this update)
- Added Literally everything from my [Week 7 Port](https://github.com/LegendLOL/Funkin-Week7)
- Backend Version shit
------------------------------------------------------------
## [0.1.1] - [8/14/22]
**Added**
- Stage Lights to week 1
- Appearance option category
- Rival characters are now playable (pico in particular)
- Anti-Aliasing option

**Changed**
- GF Freeplay-menu color
- Lots of README.md changes/tweaks

**Fixed**
- Hair physics for Boyfriend & Mom [Week 4]
- The Update msg should pop up when the game is out-of-date
------------------------------------------------------------
## [0.1.2] - [8/16/22]
### Added
- Judgement Counter (Optional)
- Custom Song events - (Bopeebo, Philly, Blammed, Cocoa, & Eggnog) 
- Definitive changelog on desktop builds

### Changed
- Daddy Dearest sprites
- Dimmed philly City lights
- Pico-players offsets on some maps - (Spooky) 
- The HUD is hidden during Winter Horrorland's mini cutscene

### Fixed
- Major Stage/Preloading issues - (it only preloads when your on that specific week)
- Fixed issue where opponents didn't go idle after their turn was over
- More Week 4 hair physics
------------------------------------------------------------
## [0.1.2h] - [8/17/22]
## v0.1.2 is broken, so heres a hotfix update (sorry lol)

### Changed
- Some option description's
- A couple of file locations

### Fixed
- Charting Editor tweaks & fixes
- Watchtower Asset from not preloading (week 7)
- More preloading stage issue's
------------------------------------------------------------
## [0.2.0] - [8/29/22]

### Added
- Caching Menu (Preloads Assets as soon as the game boots up) 
- Rating FC system (Accuracy & Miss meter || Optional)
- Health Bar colors (Optional)

### Changed
- Tweaked Tankmans 'Ugh' code (All i did was change the variable names lol)
- Animation Debug Menu (Made it more easier to use & navigate through)
- Option Descriptions

### Fixed
- Pico Miss animations looping
- Issue where character didn't go idle after their turn was over
- The game SHOULDN'T crash after you finish playing a song in the freeplay menu
- Issue where Winter-Horrorland stage wouldn't load - (Backend Stage-Preloading bullshit)
------------------------------------------------------------
## [0.2.1] - [10/22/22]
### Added
- New Options (Flashing Menu)
- Re-Added misses to judgement counter

### Changed
- Rating/Combo Sprites are now shown in the games HUD
- Note Assets, Tweaked Note code a lil bit
- Animation Debug Editor can now be viewed on regular builds of the game
- Chart Editor (Sustain notes match the color of the notes now, other fixes/changes)
- Judge MS offsets (AKA - Rating Hit windows)

### Fixed
- Week 4 Hair physics
- Camera tweening on HTML5 builds
- More Stage Preloading issues

### Removed
- Health bar Color Option (they are on by default now)
------------------------------------------------------------
## [0.2.2] - [11/17/22]
### Added
- Onion Skin to Character Editor Menu (makes it easier to offset characters)
- Added Anti-Aliasing to philly stage (cause apparently it didnt have it before??)
- New Modifer Menu (you can view it in the pause menu)

### Changed
- Some Character Offsets
- Minor fps counter changes
- You can now use your mouse wheel to scroll through songs in the Freeplay Menu
- You can now access the Options Menu from the Pause Menu
- Changed Option Menu music - Give a lil Bit Back
- Backend Changes

### Fixed
- Charting note trails
- Minor Judgement-Counter Fixes
- Note strums being so close together
- Game crashing when ever you go back to the Title-Screen
- Fixed issue where characters dont play idle anim when camera is panned on them
- Other minor fixes
------------------------------------------------------------
## [0.2.3] - [2/7/23]
## Starting the year off with a mini update, hope you guys enjoy!

### Added
- Shaders for Week 3 buidings
- Test song to debug builds

### Changed
- Softcoded Character Offsets (should be easier to offset a character in the game now)
- Changed Thorns map size - 0.9
- Options Menu Revamp
- Backend Changes

### Fixed
- File Locations
- Minor FPS counter glithces
- Other minor fixes
------------------------------------------------------------
## [0.3.0] - [2/10/23]

### Added
- Scroll Speed Option
- Week 7 Cutscenes to desktop

### Changed
- Option Descriptions/Names
- Some File locations
- Character Offsets
- Backend Changes

### Fixed
- Your game shouldn't crash when in the Caching menu (startup)
- Week 7 cutscenes are now censored (when the censor option is on)
- Outdated version backend shit
- Tankman Mid-song event issues
- Other minor fixes

### Removed
- Week 7 MP4 Cutscenes
------------------------------------------------------------
## [0.3.1] - [2/25/23]
## Been feeding you guys good this month! Last update for a while, hope yall enjoy!

### Added
- (Re)Added ComboBreak Feature (from my [Week 7 port](https://github.com/LegendLOL/Funkin-Week7))
- (Re)Added Rating/Combos to HUD option
- Lane Transparency Option
- Cool Transitioning effects to Animation Debugging Menu

### Changed
- Intro song skips to 9.4 seconds if you skipped the intro
- Minor changes to Animation Debug Menu
- Combo now starts at 1 instead of 10
- Complete overhaul on Alphabet system
- Your Camera shakes when a train is passing by on Week 3
- Backend Changes

### Fixed
- The options music SHOULD be able to play on desktop builds
- Camera movement due to FPS bullshit (HTML Builds)
- StoryMenu Character's offsets (Pico is now flipped)
- Other minor fixes

### Removed
- Modding bullshit (it may come back, idk lol)
------------------------------------------------------------
## [0.3.2] - [5/22/23]

### Added
- Mini cutscene/transition to Monster
- Antialiasing to Week 4 stage (HOW TF DID I MISS THIS...)

### Changed
- Optimized week 7 cutscenes a smudge bit... (lag shouldn't be THAT bad on low-end computers)
- pico-player's offsets for all of the maps
- Backend Changes (mostly discord RPC stuff)

### Fixed
- Memory shouldn't spike consistently in certain menus, or in-game
- Week 6 debug errors
- Minor downscroll issues
- Choppy sustain note trails (only occurs when you have high scroll speed)

### Removed
- Caching Menu from booting screen **TEMPORARILY** (overloads memory and crashes your game, no point in keeping it.)
------------------------------------------------------------
## [0.3.3] - [12/10/23]
## Sorry for the long wait... Here's a mini update to end off the year, Merry Christmas!!!

### Added
- New Options (Distractions)
- Censored version of Roses Dialogue (Week 6)

### Changed
- Tweaked Ghost-Tapping and anti-aliasing code
- Backend Changes

### Fixed
- Stress cutscene issues
- Mid-Song Event issues (Week3)
- FPS issues
------------------------------------------------------------
## [0.4.0] - [1/25/24]

### Added
- New Option Category (Saves)
- New Options (Low-Quality, Shaders, & Progress Options for the Saves menu)
- BGSprite support to stage assets
- (Re)Added Caching Menu

### Changed
- Optimized a majority of the game's menus and SOME gameplay aspects
- You can now reset both your settings and highscore from the game
- Discord RPC backend stuff
- FPS/MEM Counter revamp
- Application branding has changed a bit (new icon, name update!!)
- Your camHUD now shakes whenever a train is passing by (Week3)

### Fixed
- Certain Assets not having antialiasing to them (I think....)
- MAJOR Stage Preloading bugs 
- Other miniscule fixes have been patched

### Removed
- Week 7 Cutscenes are no longer censored
- Took down the HTML Build of the engine from github servers
- Modifiers Option in the pause menu
- Practice Mode from the Pause menu
- Distractions Option
------------------------------------------------------------
## [0.4.0h] - [1/25/24]
## v0.4.0 broke, so heres a quick patch up!!

### Changed
- Cutscenes are now being cached during startup
- Some Option Descriptions

### Fixed
- Certain assets not preloading in week 7 cutscenes
- Memory shouldn't spike when in certain menus
- Crazy frame drops during gameplay & cutscenes
- Other game crashing bugs
------------------------------------------------------------
## [Unreleased]

### Added
- New Options (Botplay, Instakill on miss)
- (Re)Added Modifiers category (you can now view it in options menu)
- (Re)Added Practice Mode (you can also view this in the options menu)

### Changed
- Score/Judgement formatting

### Fixed
- Antialiasing on the countdown assets (idk how i missed this :sob:)
- Weird framerate drops on notesplashes