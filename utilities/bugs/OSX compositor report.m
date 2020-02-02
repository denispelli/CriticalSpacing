Screen('Preference', 'SkipSyncTests', 1);
OSXCompositorIdiocyTest


PTB-INFO: This is Psychtoolbox-3 for Apple OS X, under Matlab 64-Bit (Version 3.0.16 - Build date: Dec  7 2019).
PTB-INFO: OS support status: OSX 10.14 minimally supported and tested.
PTB-INFO: Type 'PsychtoolboxVersion' for more detailed version information.
PTB-INFO: Most parts of the Psychtoolbox distribution are licensed to you under terms of the MIT License, with
PTB-INFO: some restrictions. See file 'License.txt' in the Psychtoolbox root folder for the exact licensing conditions.

PTB-WARNING: Pageflipping wasn't used at all during refresh calibration [0 of 31].
PTB-WARNING: Visual presentation timing is broken on your system and all followup tests and workarounds will likely fail.
PTB-WARNING: On this Apple macOS system you probably don't need to even bother asking anybody for help.
PTB-WARNING: Just upgrade to Linux if you care about trustworthy visual timing and stimulation.



PTB-INFO: OpenGL-Renderer is ATI Technologies Inc. :: AMD Radeon Pro 560 OpenGL Engine :: 2.1 ATI-2.11.20
PTB-INFO: Renderer has 4096 MB of VRAM and a maximum 3840 MB of texture memory.
PTB-INFO: VBL startline = 2160 , VBL Endline = 2248
PTB-INFO: Measured monitor refresh interval from beamposition = 33.333330 ms [30.000003 Hz].
PTB-INFO: Will use beamposition query for accurate Flip time stamping.
PTB-INFO: Measured monitor refresh interval from VBLsync = 33.337052 ms [29.996654 Hz]. (29 valid samples taken, stddev=0.463006 ms.)
PTB-INFO: Reported monitor refresh interval from operating system = 33.333316 ms [30.000015 Hz].
PTB-INFO: Small deviations between reported values are normal and no reason to worry.

WARNING: Couldn't compute a reliable estimate of monitor refresh interval! Trouble with VBL syncing?!?


----- ! PTB - ERROR: SYNCHRONIZATION FAILURE ! -----

One or more internal checks (see Warnings above) indicate that synchronization
of Psychtoolbox to the vertical retrace (VBL) is not working on your setup.

This will seriously impair proper stimulus presentation and stimulus presentation timing!
Please read 'help SyncTrouble' for information about how to solve or work-around the problem.
You can force Psychtoolbox to continue, despite the severe problems, by adding the command
Screen('Preference', 'SkipSyncTests', 1); at the top of your script, if you really know what you are doing.


PTB-WARNING: GPU reports that pageflipping isn't used - or under our control - for Screen('Flip')! [pflip_status = 1]
PTB-WARNING: Returned Screen('Flip') timestamps might be wrong! Please fix this now (read 'help SyncTrouble').
PTB-WARNING: The most likely cause for this is that some kind of desktop compositor is active and interfering.
PTB-WARNING: GPU reports that pageflipping isn't used - or under our control - for Screen('Flip')! [pflip_status = 1]
PTB-WARNING: Returned Screen('Flip') timestamps might be wrong! Please fix this now (read 'help SyncTrouble').
PTB-WARNING: The most likely cause for this is that some kind of desktop compositor is active and interfering.
