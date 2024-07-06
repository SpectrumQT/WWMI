Wuthering Waves Model Importer ALPHA-1
< For Mod Developers >


Warning! WWMI Alpha-1 is intended to be used by experienced modders and advanced users.

Disclaimers:
Alpha-1 Warning — WWMI is in early alpha testing phase, so you can expect all kinds of issues. Also, please keep in mind that WWMI feature set and formats are not set in stone and may be subject to change.
Compatibility Warning — WWMI uses 3dmigoto settings that may require existing mods to update texture hashes to work correctly. It also uses performance-friendly approach to trigger texture overrides, so some existing texture mods just won't work with it, and others may force WWMI to do excessive calcs degrading performance. Please be patient and wait for said mods to update.


To get into mod creation refer to the WWMI Tools:
1. GitHub: https://github.com/SpectrumQT/WWMI-Tools
2. Gamebanana: https://gamebanana.com/tools/17289


Installation:
1. Install Python from https://www.python.org/downloads/ (it's widely used for different modding tools)
2. Force Wuthering Waves to load in **DX11** mode:
2.1. Locate and open following folder:
     `\Wuthering Waves Game\Engine\Plugins\Runtime\`
2.2. Remove Nvidia folder
3. Change character LOD setting in Engine.ini:
3.1. Open \Wuthering Waves\Wuthering Waves Game\Client\Saved\Config\WindowsNoEditor\Engine.ini
3.2. Add following lines to the bottom of the file (refer https://gamebanana.com/tuts/17580 for tutorial):

[ConsoleVariables]
r.Kuro.SkeletalMesh.LODDistanceScale=25
r.Streaming.FullyLoadUsedTextures=1

4. Extract WWMI archive to any convenient location
5. Open d3dx.ini in WWMI folder with text editor of your choise
6. Locate [Loader] section in the top of the file
7. Change `launch = ` according to location of your Wuthering Waves folder, for example:
launch = C:\Games\WutheringWavesj3oFh\Wuthering Waves Game\Client\Binaries\Win64\Client-Win64-Shipping.exe
8. Double-click `WWMI Loader.exe` to start the game with WWMI


Mod Installation:
1. Extract mod's archive
2. Put extracted folder into the Mods folder


Mod Hot Load (without game restart):
1. Install mod
2. Hide modded character from screen (switch to another)
3. Press F10 to reload WWMI


Mod User Hotkeys:
[F12]: Toggle User Guide
[F6]: Toggle WWMI
[F10]: Reload WWMI and save mods settings


Mod Developer Hotkeys:
[F9]: Disable WWMI while held
[Ctrl]+[F9]: Toggle Perfomance Monitor
[Ctrl]+[F12]: Toggle Hunting Mode Guide
Numpad [0]: Toggle Hunting Mode (green text)


You can find more mods at:
https://gamebanana.com/games/20357
https://discord.com/invite/agmg


Credits:
Chiri, Bo3b, DarkStarSword - creators of original 3dmigoto, huge thanks to those guys!
SilentNightSound - custom 3dmigoto fork, initial WuWa research, AGMG legend (ary Sucrose enjoyer)
SpectrumQT, SinsOfSeven - WWMI Development
Leotorrez, Petrascyll, Zlevir, caverabbit - WWMI Contribution
