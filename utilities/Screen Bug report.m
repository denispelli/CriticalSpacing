Screen Bug report
MacBook Pro with external LG Screen attached through USB C port. When I
try to open a full-screen window on screen one, without a rect, I get a
full screen window, as expected. However, when I add the rect argument,
specifying the full screen, i get a window of the right size, but offset
left by half a screen, so i only see the right half of the window, and
the right half of the screen remains black. Weirdly, from software, I
can't tell that anything's wrong, as the Screen('Rect',window) and
Screen('GlobalRect',window) are the same as for a proper full screen
window.

% Without the rect argument, it works as expected.
r=Screen('Rect',screen);
screen=1;
white=255;
window=Screen('OpenWindow',screen,white);
sca
% However, using the rect argument gives a window
% that is only half on the screen.
window=Screen('OpenWindow',screen,white,r);
r =

           0           0        3840        2160
Screen('Rect',window)

ans =

           0           0        3840        2160
           Screen('Rect',window)

ans =

           0           0        3840        2160

Screen('GlobalRect',window)

ans =

           0           0        3840        2160

By the way, providing an empty rect, crashes MATLAB.
           

         model: 'MacBookPro14,3'
            modelDescription: 'MacBook Pro (15-inch, 2017)'
                manufacturer: 'Apple Inc.'
                psychtoolbox: 'Psychtoolbox 3.0.16'
                      matlab: 'MATLAB 9.6 (R2019a)'
                      system: 'macOS 10.14.6'
                   screenMex: 'Screen.mexmaci64 07-Aug-2019'
                     screens: [0 1]
                      screen: 0
                        size: [2100 3360]
                  nativeSize: [2100 3360]
                          mm: [206 330]
              openGLRenderer: 'AMD Radeon Pro 560 OpenGL Engine'
                openGLVendor: 'ATI Technologies Inc.'
               openGLVersion: '2.1 ATI-2.11.20'
    psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
              drawTextPlugin: 1
              psychPortAudio: 1
                     summary: 'MacBookPro14,3-macOS-10.14.6-PTB-3.0.16'