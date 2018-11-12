% BUG. After calling Screen Close the window persists for several minutes.
% The delay only affects small windows. There is no problem with
% full-screen windows.
disp(PsychtoolboxVersion);
computer=Screen('Computer');
disp(computer.system);
disp(computer.machineName);

o.screen=0;
o.useFractionOfScreen=0.3;
% o.useFractionOfScreen=0; % Use full-screen window.
white=255;
screenBufferRect=Screen('Rect',o.screen);
if o.useFractionOfScreen==0
    r=screenBufferRect;
else
    r=round(o.useFractionOfScreen*screenBufferRect);
end
window=Screen('OpenWindow',o.screen,white,r);
Screen('Close',window);
