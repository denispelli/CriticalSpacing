## You can use the MATLAB program CriticalSpacing.m on your computer to measure an observer's critical spacing and acuity for single and repeated targets.

"CriticalSpacing.m" is a MATLAB program developed by Denis Pelli at NYU, with help from Hörmet Yiltiz. You can read more about this visual test in our
2016 article:

Pelli, D. G., Waugh, S. J., Martelli, M., Crutch, S. J., Primativo, S., Yong, K. X., Rhodes, M., Yee, K., Wu, X., Famira, H. F., & Yiltiz, H. (2016) **A clinical test for visual crowding**. _F1000Research_ 5:81 (doi: 10.12688/f1000research.7835.1) [http://f1000research.com/articles/5-81/v1](http://f1000research.com/articles/5-81/v1)

## To install and run CriticalSpacing on your computer:

1. CLICK the "**Download ZIP**" button (above on right side) or this link to download the CriticalSpacing software:
[https://github.com/denispelli/CriticalSpacing/archive/master.zip](https://github.com/denispelli/CriticalSpacing/archive/master.zip)
1. UNPACK the “zip” archive, producing a folder called CriticalSpacing.
1. INSTALL software. Inside the CriticalSpacing folder, open the Word document "**Install CriticalSpacing.docx**" and follow the detailed instructions to install MATLAB, Psychtoolbox, and CriticalSpacing software.
1. TYPE "**help CriticalSpacing**" in the MATLAB Command Window. 

## Software required:

CriticalSpacing, Psychtoolbox, and MATLAB

## Hardware required:

* A computer running Mac OS X, Windows, or Linux, with the above software installed. 
* A remote keyboard: wireless or with a 10-m-long cable.
* A 10 m measuring tape (or laser) to measure the viewing distance.
* A printed copy of the relevant alphabet page that you select from the CriticalSpacing/pdf/ folder.

## Update:
* June 21, 2017. <b>Enhanced support for peripheral testing.</b> The main change is a better viewing geometry, which I worked out first for my equivalent noise measurements reports at VSS 2017. The point on a plane (the screen) closest to the observer’s eye is the <b>near point</b>. At that point the observer’s line of sight is orthogonal to the screen. Before every run, CriticalSpacing now asks the observer to adjust the position and tilt of the display to attain the specified viewing distance to the near point and adjust the display to be orthogonal to the observer’s line of sight at the near point. To minimize perspective distortion, we now place the target at the near point. If the eccentricity is not too large, then the fixation can also be displayed on the screen. The user-specified eccentricity determines the relative position of fixation and target, and CriticalSpacing tries to place them so that the fixation is on screen and the target is as near as possible to the screen center. Failing that, we  support the use of off-screen fixation, giving the observer instructions on how to measure distances between target and fixation, and from her eye to target and to fixation. The initial control screen of CriticalSpacing, which allows change of designated viewing distance, now reports the maximum viewing distance that will allow on-screen fixation with the user-requested eccentricity.

* June 20, 2017. Bianca Huurneman documented that under Windows the reports of screen size in cm may be wrong. As a work-around, we now allow the user to measure the screen size (with a meter stick) and provide the values in the user-supplied o struct as <b>o.measuredScreenWidthCm</b> and <b>o.measuredScreenHeightCm</b>.

* April 13, 2017. Fixed problem reported by Bianca Huurneman, Nabin Paudel, and Thomas Salazar. The “b.png” letter file in the Pelli font had the wrong image size, which provoked a warning and fatal error. The bad file has now been replaced with a good file of the correct size. And error checking and reporting has been enhanced to give a more specific and explanatory error message should such an error ever recur. Thanks to Bianca, Nabin, and Thomas for reporting the problem. - Denis


&copy; Copyright 2016, 2017, 2018 Denis Pelli, denis.pelli@nyu.edu
