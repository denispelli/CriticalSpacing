function timeSec=WaitForSpeech(action, arg, saveAudio, deviceName)
% WaitForSpeech('open' | 'close');
% timeSec=WaitForSpeech('measure',name[,saveAudio=false][,deviceName=[]]);
% WaitForSpeech('storeRating',rating);
% The first argument specifies the desired "action", which can be 'open',
% 'close', 'measure', or 'storeRating'. Actions 'open' and 'close' are used
% to open and close PsychPortAudio. Action 'measure' returns absolute time
% (like GetSecs) at which speech is first detected. The name argument is a
% string used to name the saved recording, e.g. the word and the observer.
% Action 'storeRating' stores the observer's integer "rating" as a
% filename. It is the same filename as used for the data, with the rating
% appended.
%
% CAUTION: Under macOS, MATLAB requires the user's permission to use the
% microphone. The user grants permission by going to
%      System Preferences : Security & Privacy : Privacy
% and clicking the checkbox next to "MATLAB". 
% https://support.apple.com/guide/mac-help/control-access-to-your-microphone-on-mac-mchla1b1e1fe/mac
% Note that each time you upgrade MATLAB, the user will again have to grant
% permission to the new MATLAB application. If you call
% WaitForSpeech('Open') while MATLAB does not yet have permission, then
% either InitializePsychSound or PsychPortAudio puts up a modal dialog
% asking the user to grant permission. Alas, if this comes up while we have
% a full-screen window from Screen, then the dialog is displayed behind our
% window and cannot be seen. MATLAB waits forever for the user to click the
% invisible dialog box. I think the only way for the user to recover
% control is to kill MATLAB.
%
% An easy way to avoid the hang up is to always call WaitForSpeech('open')
% and 'close' once, very early, the first time CriticalSpacing runs, before
% the Screen window is open. Then, if permission is needed, the dialog will
% open and the user will see it and grant permission. The only downside is
% that the roughly 1 s taken by these calls will be wasted in experiments
% that never use the microphone. To avoid needlessly checking for
% microphone permission we'd have to check not just this block for
% o.task=='readAloud', but the whole experiment, because once the window is
% open, we keep it open for the whole experiment.
%
% The two calls together take roughly 1 sec.
% WaitForSpeech('open');
% WaitForSpeech('close');
%
% Denis Pelli raised this as a Psychtoolbox issue in January 2020,
% suggesting a fix inside InitializePsychSound or PsychPortAudio, whichever
% opens the modal dialog.
% https://github.com/Psychtoolbox-3/Psychtoolbox-3/issues/637
% 
% Written by Ziyi Zhang, December, 2019. Polished by denis.pelli@nyu.edu.

if nargin<1
    action='open';
end
if nargin<2
    arg=[];
end
if nargin<3
    saveAudio=false;
end
if nargin<4
    deviceName='';
end
if isempty(deviceName)
    if ismember(action,{'open'})
        disp('Using default microphone.');
    end
    deviceName=[];
else
    disp(['Using ''' deviceName ''' microphone.']);
end
persistent pahandle fileName
% maxWaitSec is duration after which action 'measure' will return current
% time regardless of audio input.
maxWaitSec = 5;
% voiceTrigger is the threshold amplitude.
voiceTrigger = 0.1;
% recordSecs is the duration recorded and stored on each trial.
recordSecs = 1;
% saveSpeechGraph has been deprecated, but left true on purpsoe
saveSpeechGraph = true;
switch action
    case 'open'
        if nargin>1
            sca;
            clear PsychPortAudio
            error('Too many arguments. Only one allowed for open.');
        end
        AssertOpenGL; % We need Psychtoolbox 3.
        InitializePsychSound(1); % The 1 requests low latentcy. Ignored except on Windows.
        % Open audio device 'device', with mode 2 (== Only audio capture),
        % and a required latencyclass of 1 == low-latency mode, with the
        % preferred default sampling frequency of the audio device, and 1
        % sound channel for monaural capture. This returns a handle to the
        % audio device:
        pahandle = PsychPortAudio('Open', deviceName, 2, 1, [], 1);
        % Preallocate the internal audio recording buffer.
        maxDurationSecs=maxWaitSec+recordSecs;
        PsychPortAudio('GetAudioData', pahandle,maxDurationSecs);
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        PsychPortAudio('Stop', pahandle);
        return
    case 'close'
        if nargin>1
            sca;
            clear PsychPortAudio
            error('Too many arguments. Only one allowed for close.');
        end
        if ~isempty(pahandle)
            % Close the audio device:
            PsychPortAudio('Close', pahandle);
            pahandle=[];
            fileName='';
        end
        return
    case 'storeRating'
        % Store the observer's rating as the filename of an empty file.
        rating=arg;
        if isempty(fileName)
            sca;
            clear PsychPortAudio
            error('You must ''measure'' before you ''storeRating''. A common cause is that the microphone failed to capture your response.');
        end
        fclose(fopen(sprintf('%s-%d.log',fileName,rating), 'w'));
        return
    case 'measure'
        name=arg{1};
        beginSec=arg{2};
        % Run code below.
    otherwise
        sca
        clear PsychPortAudio
        error('Unknown "action" ''%s''.',action);
end
if isempty(pahandle)
    sca;
    clear PsychPortAudio
    error('You must ''open'' before you ''measure''.');
end
s = PsychPortAudio('GetStatus', pahandle);
% Get the frequency we are actually using.
freq = s.SampleRate;
% Start audio capture immediately and wait for the capture to start. We set
% the number of 'repetitions' to zero, i.e. record until recording is
% manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);
% disp('-- start recording --');  % Debug use
level = 0;
success = true;
discardedAudio = [];
while level < voiceTrigger
    % Fetch current audiodata, since last fetch.
    [audioData,offset,overflow,captureStartSec] = PsychPortAudio('GetAudioData', pahandle);
    if GetSecs-captureStartSec>maxWaitSec
        % maxWaitSec reached without sound.
        success = false;
        break;
    end
    if overflow>0
        warning('Audio data exceeds %.1f s buffer. Data lost.',maxDurationSecs);
    end
    % Compute maximum signal amplitude in this chunk of data.
    if ~isempty(audioData)
        level = max(abs(audioData(1,:)));
    else
        level = 0;
    end
    if level < voiceTrigger
        if saveSpeechGraph
            discardedAudio=[discardedAudio audioData];  %#ok
        end
        % Pause before getting next chunk.
        WaitSecs(0.005);
    end
end
if success
    % Find exact location of first above-threshold sample.
    idx = min(find(abs(audioData(1,:)) >= voiceTrigger));  %#ok<MXFND>
    idxTotal = offset + idx - 1;
    % Initialize our recordedAudio vector with captured data starting from
    % the sample that exceeded threshold:
    recordedAudio = audioData(:, idx:end);
    if saveSpeechGraph && idx>1
        discardedAudio = [discardedAudio, audioData(:, 1:idx-1)];
    end
    % Calculate speech onset time:
    timeSec = captureStartSec + ((offset + idx - 1) / freq);
    % Record a further 'recordSec' to capture the rest of the word.
    while captureStartSec + (offset+length(audioData))/freq < timeSec + recordSecs
        [audioData,offset,overflow,captureStartSec] = PsychPortAudio('GetAudioData', pahandle);
        if overflow
            warning('Audio data exceeds %.1f s buffer. Data lost.',maxDurationSecs);
        end
        recordedAudio = [recordedAudio audioData];  %#ok
        WaitSecs(0.005);
    end
end
% disp('-- end recording --');  % Debug use
% Stop capture.
PsychPortAudio('Stop', pahandle);
if ~success
    % No voice detected.
    timeSec = GetSecs;  % if not detected, return current time.
    return;
end
% Perform a last fetch operation to get all remaining data from the capture
% engine.
audioData = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector.
recordedAudio = [recordedAudio audioData];
% Prepare fileName.
if ~isempty(name) && (saveSpeechGraph || saveAudio)
    assert(ischar(name));
    fileName = [datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '-', name];
    % Get out of 'lib'.
    mainPath = fileparts(fileparts(mfilename('fullpath')));
    fileName = fullfile(mainPath,'readAloud',fileName);
else
    fileName='';
end
% Plot wave [deprecated, now plotted in grading.app]
if ~isempty(fileName) && saveSpeechGraph && false
    f = figure('Visible', 'off');
    plotData = [discardedAudio, recordedAudio];
    plot((1:size(plotData, 2)) ./ freq, plotData(1, :), 'b');
    hold on
    % Mark onset.
    plot([idxTotal/freq, idxTotal/freq-0.17], [0, voiceTrigger], 'r');
    scatter(idxTotal/freq, 0, 3, 'r', 'Marker', 'x');
    text(idxTotal/freq-0.3, voiceTrigger, 'onset');
    xlabel('Time (s)');
    ylabel('Amplitude');
    saveas(f,[fileName '.fig']);
end
% Store recorded sound. Use fileName. [deprecated]
if ~isempty(fileName) && saveAudio && false
    wavFileName = [fileName '.wav'];
    psychwavwrite(transpose(recordedAudio), freq, 16, wavFileName);
end
% Store recorded sound and other necessary information
if ~isempty(fileName) && saveAudio
    info = {[discardedAudio, recordedAudio], idxTotal, freq, voiceTrigger, ...
            captureStartSec, beginSec}; %#ok
    save([fileName, '.mat'], 'info');
end
end
