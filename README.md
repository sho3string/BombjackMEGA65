Bombjack for MEGA65
===================

Bombjack is a timeless arcade game brought to life on the MEGA65 platform. 
In this thrilling adventure, you assume the role of Bombjack, a fearless hero 
tasked with the critical mission of defusing bombs scattered throughout a series 
of intricate levels.

The gameplay in Bombjack is a blend of platforming and strategic bomb defusal. 

As Bombjack, you can jump and glide using your cape to reach otherwise unreachable heights.
Your primary objective is to collect all the bombs in each level while evading dangerous enemies and hazards.

The challenge intensifies as you progress through the game. To maximize your score and clear levels efficiently, 
you'll need to employ tactics and quick reflexes. Timing your jumps and movements is crucial to avoid contact 
with adversaries, such as mummies, birds, and other foes.

One of the standout features of Bombjack is the exhilarating sense of accomplishment when successfully clearing 
a level of all its bombs. The anticipation and excitement grow as the number of bombs left to defuse diminishes.

Your performance is rewarded with points, making Bombjack not only an exciting adventure but also a competitive 
endeavor where you can aim for high scores and challenge your friends to beat your best achievements.

As you progress, you'll encounter different environments, each with its unique challenges and enemies. 
The variety in level design keeps the gameplay fresh and engaging, ensuring that you won't tire of Bombjack's 
explosive action.

Prepare to embark on a thrilling journey filled with bombs, adventure, and high-stakes heroism in Bombjack for 
the MEGA65. The fate of the world rests in your hands, and it's up to you to save the day!


This core is based on the
[MiSTer](https://github.com/MiSTer-devel/Arcade-Bombjack_MiSTer)
Bombjack core which itself is based on the work of [many others](AUTHORS).

[Muse aka sho3string](https://github.com/sho3string)
ported the core to the MEGA65 in 2023.

The core uses the [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65)
framework and [QNICE-FPGA](https://github.com/sy2002/QNICE-FPGA) for
FAT32 support (loading ROMs, mounting disks) and for the
on-screen-menu.

How to install the Bombjack core on your MEGA65
-----------------------------------------------

1. **Download ROM**: Download the Bombjack ROM ZIP file (do not unzip!) from
  Search the web for "mame bombjack set 1 or set 2".

2. **Download the Python script**: Download the provided Python script that
   prepares the ROMs such that the Bombjack core is able to use it from
   [Link](https://github.com/sho3string/BombjackMEGA65/blob/master/bombjack_rom_installer.py).

3. **Run the Python script**: Execute the Python script to create a folder
   with the ROMs. 
   Use the command `python bombjack_rom_installer.py <path to the zip file> <output_folder>`.

   ROM files within the zip arhive are automatically evaluated for the correct SHA1 checksums.

5. **Copy the ROMs to your MEGA65 SD card**: Copy the generated folder with
   the ROMs to your MEGA65 SD card. You can use either the bottom SD card tray
   of the MEGA65 or the tray at the backside of the computer (the latter has
   precedence over the first).
   The ROMs need to be in the folder `arcade/bombjack`.
   
   Copy the bjcfg provided in the 'arcade/bombjack` folder.

   The core supports the following versions of Bombjack.

   bombjack          Bomb Jack (set 1)             (Tehkan, 1984)  
   bombjack2         Bomb Jack (set 2)             (Tehkan, 1984)  

7. **Setting up dip switches**

   There are two dip switch banks of 8 switches on Bombjack PCBs.
   Check the following pages to understand how to customise each dip.

   Tehkan
   [Link](https://www.arcade-museum.com/dipswitch-settings/7180.html)

  
   Revision differences:
   
   The extra credit message was corrected in the next board revision from:  
   
   "You are lucy!" to "You are lucky"  
   
   Only 1 rom differs between the two revisions for this small change. 
   
   See https://tcrf.net/Bomb_Jack_(Arcade)#Revision_Differences

9. **Download and run the Bombjack core**: Follow the instructions on
  [this site](https://sy2002.github.io/m65cores/)

10. **Common problems**

    1. Some artefacts/lines may appear when manually resetting the MEGA65 in rot90 mode, this will be fixed in a future release.  
	2. Coin A/Coin B dips aren't implemented in the MiSTer core, these do nothing and are hard coded to '1coin 1 credit'.
	


    
