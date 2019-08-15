% TestDuration.m
% denis.pelli@nyu.edu, August 15, 2019
% We use the 'when' argument of Screen Flip to request a flip time. Alas
% we reliably get an extra frame beyond what we request. If we reduce our
% request by a frame then we accurately get the desired flip time. 
%
% RESULTS
% iMac (Retina 5K, 27-inch, Late 2014) running macOS Mojave 10.14.6
% Psychtoolbox 3.0.16
% TestDuration
% Reducing "when" argument to Flip by 0 ms.
% duration "200 ms" actually 220±3 ms, range [214 222] ms. Flip
% duration "200 ms" actually 220±3 ms, range [214 222] ms. TIMER
% duration "200 ms" actually 220±3 ms, range [214 222] ms. VBL
% TestDuration
% Reducing "when" argument to Flip by 17 ms.
% duration "200 ms" actually 204±2 ms, range [200 208] ms. Flip
% duration "200 ms" actually 205±3 ms, range [200 208] ms. TIMER
% duration "200 ms" actually 204±2 ms, range [200 208] ms. VBL
%
% RESULTS
% MacBook Air (2014) running macOS High Sierra 10.13.6
% Psychtoolbox 3.0.16
% TestDuration
% Reducing "when" argument to Flip by 0 ms.
% duration "200 ms" actually 217±1 ms, range [216 218] ms. Flip
% duration "200 ms" actually 217±1 ms, range [216 219] ms. TIMER
% duration "200 ms" actually 217±1 ms, range [216 218] ms. VBL
% > TestDuration
% Reducing "when" argument to Flip by 17 ms.
% duration "200 ms" actually 200±0 ms, range [200 201] ms. Flip
% duration "200 ms" actually 201±1 ms, range [200 202] ms. TIMER
% duration "200 ms" actually 200±0 ms, range [200 201] ms. VBL

reductionSec=1/FrameRate; % In fact, this gives most accurate timing.
reductionSec=0; % This ought to give most accurate timing.
clear o
repetitions=10;
plusMinus=char(177);
o.screen=0;
o.durationSec=0.200;
o.actualDurationSec=[];
o.actualDurationTimerSec=[];
o.actualDurationVBLSec=[];
% Detect HiDPI mode, e.g. on a Retina display.
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
o.hiDPIMultiple=RectWidth(screenRect)/RectWidth(screenBufferRect);
white=255;
fprintf('Reducing "when" argument to Flip by %.0f ms.\n',1000*reductionSec);
if true
    PsychImaging('PrepareConfiguration');
    if o.hiDPIMultiple~=1
        PsychImaging('AddTask','General','UseRetinaResolution');
    end
    % Mario says the virtual frame buffer makes the back buffer more
    % reliable, for better performance.
    PsychImaging('AddTask','General','UseVirtualFramebuffer');
    [window,r]=PsychImaging('OpenWindow',o.screen,white);
else
    [window,r]=Screen('OpenWindow',o.screen,white);
end
for i=1:repetitions
    % Draw stimulus.
    Screen('FillRect',window);
    Screen('TextSize',window,50);
    msg=sprintf('Now timing stimulus, nominally %.0f ms, %d of %d times.',...
        1000*o.durationSec,i,repetitions);
    Screen('DrawText',window,msg,100,100);
    % Flip to show stimulus.
    [stimulusBeginVBLSec,stimulusBeginSec]=Screen('Flip',window,[],1);
    stimulusFlipSecs=GetSecs;
    % Flip waits for the next flip after the requested time. This ought to
    % extend our interval by a random sample from the uniform distribution
    % from 0 to 1 frame, with a mean of half a frame. This should give us a
    % mean duration half a frame longer than requested. We assess that in
    % three ways, and print it out at the end of the block.
    Screen('FillRect',window);
    % Flip to erase stimulus.
    [stimulusEndVBLSec,stimulusEndSec]=Screen('Flip',window,...
        stimulusBeginSec+o.durationSec-reductionSec,1);
    % We measure stimulus duration in three slightly different ways. 1. We
    % time the interval between return times of our two calls to Flip. The
    % first Flip displays the stimulus and the second call erases it. 2.
    % and 3. We also use the VBLTimestamp and StimulusOnsetTime values
    % returned by our call to Screen Flip. All of these have the same
    % purpose of recording what the true stimulus duration is, and they are
    % in reasonably close agreement.
    o.actualDurationSec(end+1)=stimulusEndSec-stimulusBeginSec;
    o.actualDurationVBLSec(end+1)=stimulusEndVBLSec-stimulusBeginVBLSec;
    o.actualDurationTimerSec(end+1)=GetSecs-stimulusFlipSecs;
end
fprintf('duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. Flip\n',...
    o.durationSec*1000, ...
    1000*mean(o.actualDurationSec),...
    plusMinus,...
    1000*std(o.actualDurationSec),...
    1000*min(o.actualDurationSec),1000*max(o.actualDurationSec));
if max(o.actualDurationSec)>o.durationSec+2/60
    warning('Duration overrun by %.0f ms. Flip.',...
        1000*(max(o.actualDurationSec)-o.durationSec));
end
sca;
if true
    % Report two other measures of timing, to confirm Flip timing.
    fprintf('duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. TIMER\n',...
        o.durationSec*1000, ...
        1000*mean(o.actualDurationTimerSec),...
        plusMinus,...
        1000*std(o.actualDurationTimerSec),...
        1000*min(o.actualDurationTimerSec),1000*max(o.actualDurationTimerSec));
    if max(o.actualDurationTimerSec)>o.durationSec+2/60
        warning('Duration overrun by %.0f ms. TIMER',...
            1000*(max(o.actualDurationTimerSec)-o.durationSec));
    end
    fprintf('duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. VBL\n',...
        o.durationSec*1000, ...
        1000*mean(o.actualDurationVBLSec),...
        plusMinus,...
        1000*std(o.actualDurationVBLSec),...
        1000*min(o.actualDurationVBLSec),1000*max(o.actualDurationVBLSec));
    if max(o.actualDurationVBLSec)>o.durationSec+2/60
        warning('Duration overrun by %.0f ms. VBL',...
            1000*(max(o.actualDurationVBLSec)-o.durationSec));
    end
end

