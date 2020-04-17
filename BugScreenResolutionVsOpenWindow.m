% BugScreenResolutionVsOpenWindow.m
% denis.pelli@nyu.edu
% March 29, 2020
% https://github.com/Psychtoolbox-3/Psychtoolbox-3/issues/654

screen=0;
verbose=false;
fractionOfScreenUsed=0.2;
testScreenBug=true;
if testScreenBug
    if false
        width=2880;
        height=1800;
    else
        width=3360;
        height=2100;
    end
    oldResolution=Screen('Resolution',screen,width,height);
    % This second call to Screen Resolution, nominally of no effect, is a
    % work-around for a bug in Screen. Otherwise when we change resolution,
    % subsequent calls to OpenWindow put the window in the wrong place.
    % With the extra call, window placement is correct. Bug reported to
    % Psychtoolbox github March 28, 2020.
    Screen('Resolution',screen,width,height);
    fprintf('oldResolution %.0f %.0f\n',oldResolution.width,oldResolution.height);
    resolution=Screen('Resolution',screen);
    fprintf('new resolution %.0f %.0f\n',resolution.width,resolution.height);
end
screenBufferRect=Screen('Rect',screen);
r=round(fractionOfScreenUsed*screenBufferRect);
r=AlignRect(r,screenBufferRect,'right','bottom');
if ~verbose
    PsychTweak('ScreenVerbosity',0);
    verbosity=Screen('Preference','Verbosity',0);
end
Screen('Preference','SkipSyncTests',1);
window=Screen('OpenWindow',screen,255,r);
if testScreenBug
    fprintf('Screen(''GlobalRect'',0) [%.0f %.0f %.0f %.0f ]\n',Screen('GlobalRect',0));
    fprintf('r requested [%.0f %.0f %.0f %.0f ]\n',r);
    fprintf('Screen(''GlobalRect'',window) [%.0f %.0f %.0f %.0f ]\n',Screen('GlobalRect',window));
end
WaitSecs(3);
sca;
