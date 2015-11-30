% testUseRetinaResolution
screenBufferRect=Screen('Rect',0)
screenRect=Screen('Rect',0,1)
resolution=Screen('Resolution',0)
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
[window,r]=PsychImaging('OpenWindow',0,255);
screenBufferRect=Screen('Rect',0)
screenRect=Screen('Rect',0,1)
resolution=Screen('Resolution',0)
sca

>> testUseRetinaResolution
screenBufferRect =
           0           0        1280         800
screenRect =
           0           0        2560        1600
resolution = 
        width: 2560
       height: 1600
    pixelSize: 24
           hz: 0
One or more internal checks (see Warnings above) indicate that synchronization
of Psychtoolbox to the vertical retrace (VBL) is not working on your setup.
screenBufferRect =
           0           0        1280         800
screenRect =
           0           0        2560        1600
resolution = 
        width: 2560
       height: 1600
    pixelSize: 24
           hz: 0
>> 