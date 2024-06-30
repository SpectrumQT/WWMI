<h1 align="center">Wuthering Waves Model Importer</h1>

<h4 align="center">Custom 3d models loader for Wuthering Waves</h4>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#disclaimers">Disclaimers</a> •
  <a href="#wwmi-installation">WWMI Installation</a> •
  <a href="#mod-installation">Mod Installation</a> • 
  <a href="#mod-hot-load">Mod Hot Load</a> • 
  <a href="#mod-user-hotkeys">Mod User Hotkeys</a> • 
  <a href="#mod-development">Mod Development</a> • 
  <a href="#mod-developer-hotkeys">Mod Developer Hotkeys</a> • 
  <a href="#resources">Resources</a> •
  <a href="#license">License</a>
</p>

## For Mod Authors

The 1.1 update has introduced huge changes into the rendering pipeline and 3d assets, to update mods that were made for 1.0 please follow the steps below:
1. Update your [WWMI Tools Blender plugin to 0.8.0](https://github.com/SpectrumQT/WWMI-TOOLS/releases/tag/v0.8.0).
2. Make a new frame dump of modded object (with mod disabled!) and extract it again.
3. Import newly extracted object into Blender (use default Merged Skeleton setting)
4. Make changed Vertex Groups ids in your custom mesh match ones of new import (you may use [Weight Match Blender Addon](https://gamebanana.com/tools/15699) to speed up the process)
5. Export your updated custom model as new mod into new folder (use default Merged Skeleton setting).
6. Check textures one by one and move the ones you've edited from old to new mod folder.

## Features  

- **Highly Optimized** — Built with minimization of performance footprint in mind
- **Cross-Platform** — Works with NVidia and AMD GPUs
- **Modder Friendly** — Enables fully automatic model re-import mod creation with [WWMI Tools](https://github.com/SpectrumQT/WWMI-Tools)
- **No Vertex Limit** — Removes all limitations caused by component layout of original models
- **Shape Keys Support** — Handles original shape keys overrides and enables creation of custom ones
- **Bone Merging** — Dynamically merges skeleton data to allow modders work with unified VG list

## Disclaimers  

- **Alpha-1 Waring** — WWMI is in early alpha testing phase, so you can expect all kinds of issues. Also, please keep in mind that WWMI feature set and formats are not set in stone and may be subject to change.

- **Compatibility Waring** — WWMI uses 3dmigoto settings that may require existing mods to update texture hashes to work correctly. It also uses performance-friendly approach to trigger texture overrides, so some existing texture mods just won't work with it, and others may force WWMI to do excessive calcs degrading performance. Please be patient and wait for said mods to update.

## WWMI Installation

1. Install [**Python**](https://www.python.org/downloads/) (it's widely used for different modding tools)
2. Disable [Hardware-Accelerated GPU Scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/) to force WuWa load in **DX11** mode (loader doesn't work with DX12)
    * Go to **Graphics Settings** of your Windows
    * Set **Hardware-Accelerated GPU Scheduling** to **OFF**
    * **Restart** your PC
3. Change [Character LOD settings](https://gamebanana.com/tuts/17580) in **Engine.ini**:
    * Open `\Wuthering Waves\Wuthering Waves Game\Client\Saved\Config\WindowsNoEditor\Engine.ini`
    * Add following lines to the bottom of the file:
    ```ini
    [ConsoleVariables]
    r.Kuro.SkeletalMesh.LODDistanceScale=20
    r.Streaming.FullyLoadUsedTextures=1
    ```
4. [Extract](https://support.microsoft.com/en-us/windows/zip-and-unzip-files-f6dde0a7-0fec-8294-e1d3-703ed85e7ebc) WWMI archive to any convenient location
5. Open **d3dx.ini** in WWMI folder with text editor of your choise
6. Locate **[Loader]** section in the top of the file
7. Change `launch = ` according to location of your Wuthering Waves folder, for example:
    ```ini
    launch = C:\Games\WutheringWavesj3oFh\Wuthering Waves Game\Client\Binaries\Win64\Client-Win64-Shipping.exe
    ```
8. Double-click **WWMI Loader.exe** to start the game with WWMI

## Mod Installation

1. [Extract](https://support.microsoft.com/en-us/windows/zip-and-unzip-files-f6dde0a7-0fec-8294-e1d3-703ed85e7ebc) mod's archive
2. Put extracted folder into the **Mods** folder

## Mod Hot Load

To properly load newly installed mod without restarting the game:
1. Install mod
2. Hide modded character from screen (switch to another)
3. Press **[F10]** to reload WWMI

## Mod User Hotkeys

- **[F1]**: Toggle User Guide
- **[F6]**: Toggle WWMI dependant mods
- **[F10]**: Reload WWMI and save mods settings

## Mod Development
To get into mod creation refer to the **WWMI Tools** and its [Modder Guide](https://github.com/SpectrumQT/WWMI-TOOLS/blob/main/guides/modder_guide.md):
1. [GitHub](https://github.com/SpectrumQT/WWMI-Tools)
2. [Gamebanana](https://gamebanana.com/tools/17289)

## Mod Developer Hotkeys

- **[F9]**: Disable WWMI while held
- **[Ctrl]+[F9]**: Toggle Perfomance Monitor
- **[Ctrl]+[F1]**: Toggle Hunting Mode Guide
- **Numpad [0]**: Toggle Hunting Mode (green text)

## Resources

- [WWMI Tools](https://github.com/SpectrumQT/WWMI-Tools)
- [WWMI - Gamebanana](https://gamebanana.com/tools/17252)
- [WWMI Tools - Gamebanana](https://gamebanana.com/tools/17289)
- [Wuthering Waves Mods - Gamebanana](https://gamebanana.com/games/20357)
- [Discord Modding Community](https://discord.com/invite/agmg)

## Credits

Chiri, [Bo3b](https://github.com/bo3b), [DarkStarSword](https://github.com/DarkStarSword) - creators of original 3dmigoto, huge thanks to those guys!
[SilentNightSound](https://gamebanana.com/members/2176153) - custom 3dmigoto fork, initial WuWa research, AGMG legend (ary Sucrose enjoyer)
[SpectrumQT](https://gamebanana.com/members/2837527), [SinsOfSeven](https://gamebanana.com/members/2823441) - WWMI Development
[Leotorrez](https://gamebanana.com/members/2419201), [Petrascyll](https://gamebanana.com/members/2644630), [Zlevir](https://gamebanana.com/members/2694449), [Caverabbit](https://gamebanana.com/members/2987570) - WWMI Contribution

## License

WWMI is licensed under the [GPLv3 License](https://github.com/SpectrumQT/WWMI/blob/main/LICENSE).
