function timeSec=WaitForSpeech(action, arg, saveAudio, saveSpeechGraph, deviceName)
% WaitForSpeech('open' | 'close');
% timeSec=WaitForSpeech('measure',name[,saveAudio=false]...
%      [,saveSpeechGraph=false][,deviceName=[]]);
% WaitForSpeech('storeRating',rating);
% The first argument specifies the desired "action", which can be 'open',
% 'close', 'measure', or 'storeRating'. Actions 'open' and 'close' are used
% to open and close PsychPortAudio. Action 'measure' returns absolute time
% (like GetSecs) at which speech is first detected. The name argument is a
% string used to name the saved recording, e.g. the word and the observer.
% Action 'storeRating' stores the observer's integer "rating" as a
% filename. It is the same filename as used for the data, with the rating
% appended.
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
    saveSpeechGraph=false;
end
if nargin<5
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
switch action
    case 'open'
        if nargin>1
            sca;
            clear PsychPortAudio
            error('Too many arguments. Only one allowed for open.');
        end
        AssertOpenGL; % We need Psychtoolbox 3.
        InitializePsychSound;
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
            error('You must ''measure'' before you ''storeRating''.');
        end
        fclose(fopen(sprintf('%s-%d.log',fileName,rating), 'w'));
        return
    case 'measure'
        name=arg;
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
% disp('-- end recording --');  % Debug use
if success
    % Find exact location of first above-threshold sample.
    idx = min(find(abs(audioData(1,:)) >= voiceTrigger));  %#ok<MXFND>
    idxTotal = offset + idx - 1;
    % Initialize our recordedAudio vector with captured data starting from
    % the sample that exceeded threshold:
    recordedAudio = audioData(:, idx:end);
    if saveSpeechGraph
        discardedAudio = [discardedAudio, audioData(:, 1:idx)];
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
% Plot wave
if ~isempty(fileName) && saveSpeechGraph
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
% Store recorded sound. Use fileName.
if ~isempty(fileName) && saveAudio
    wavFileName = [fileName '.wav'];
    psychwavwrite(transpose(recordedAudio), freq, 16, wavFileName);
end
end
