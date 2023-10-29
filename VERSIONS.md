Version 0.5.0 - October 29, 2023
================================

Bombjack for the MEGA65 version 0.5.0 is based on this version 1.0.0 of the MiSTer2MEGA65 framework.

Despite being labeled as a "beta" release, the game is entirely playable with no major issues however, users will encounter a lower framerate in rotate mode. It's important to note that this is not due to any limitations in the Mega65's hardware, but rather a constraint in the M2M framework. Presently, screen rotation is only supported at 50hz, whereas Bombjack's video runs at 60hz. For the best experience, it is recommended not ( despite this being the default ) to rotate the display via the OSD (On-Screen Display) but rather to physically rotate your monitor instead. This limitation will be fixed in the future.

## Features
* Screen rotation of 90° is available, although not recommended (please see above for more information)
* Supports various HDMI modes
* Compatible with VGA (standard) and Retro 15Khz modes, with separate HS/VS or CSYNC
* Joystick ports can be flipped via the OSD
* Ability to save OSD/Menu settings
* Fully configurable DIP switches

## Constraints 
* Core does not support dynamic ROM loading yet
* No Vsync/Hsync adjustment
* Aspect ratio is currently fixed
* No autosave of highscores is supported


## Bugs
* Some artefacts/lines may appear when manually resetting the MEGA65 in rot90 mode, this will be fixed in a future release.
* Coin A/Coin B dips aren't implemented in the MiSTer core, these do nothing and are hard coded to '1coin 1 credit'










