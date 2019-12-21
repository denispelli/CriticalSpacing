function timeSec=WaitForSpeech(action, targetWord, saveAudio, plotWave, deviceName, maxWaitSec)
% timeSec=WaitForSpeech(action,targetWord[,saveAudio=false]...
%      [,plotWave=false][,deviceName=[]][,maxWaitSec=5]);
% Return absolute time at which speech is first detected. If no speach
% detected after maxWaitSec (default 5 s), then return [].
% Written by Ziyi Zhang, December, 2019.
% Polished by DGP, December, 2019.

if nargin<1
    action='open';
end
if nargin<2
    targetWord=[];
end
if nargin<3
    saveAudio=false;
end
if nargin<4
    plotWave = false;
end
if nargin<5
    deviceName='';
end
if nargin<6
    maxWaitSec=5;
end
if isempty(deviceName)
    if ismember(action,{'open'}) 
        disp('Using default microphone.');
    end
    deviceName=[];
else
    disp(['Using ''' deviceName ''' microphone.']);
end
persistent pahandle
% Set voiceTrigger: the threshold amplitude
voiceTrigger = 0.05;
% Set recordSecs: the time span in seconds recorded and stored
recordSecs = 0.2;
switch(action)
    case 'open'
        if nargin>1
            error('Too many arguments. Only one allowed for open.');
        end
        % Running on PTB-3? Abort otherwise.
        AssertOpenGL;
        % Perform basic initialization of the sound driver:
        InitializePsychSound;
        % Open audio device 'device', with mode 2 (== Only audio capture),
        % and a required latencyclass of 1 == low-latency mode, with the preferred
        % default sampling frequency of the audio device, and 1 sound channel
        % for monaural capture. This returns a handle to the audio device:
        pahandle = PsychPortAudio('Open', deviceName, 2, 1, [], 1);
        % Preallocate an internal audio recording buffer
        PsychPortAudio('GetAudioData', pahandle, maxWaitSec+recordSecs);
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        PsychPortAudio('Stop', pahandle);
        return
    case 'close'
        if nargin>1
            sca;
            error('Too many arguments. Only one allowed for close.');
        end
        if ~isempty(pahandle)
            % Close the audio device:
            PsychPortAudio('Close', pahandle);
            pahandle=[];
        end
        return
    case 'measure'
        % Run code below.
    otherwise
        error('Unknown "action" ''%s''.',action);
end
if isempty(pahandle)
    sca;
    error('You must call PsychPortAudio(''open'') before using it.');
end
s = PsychPortAudio('GetStatus', pahandle);
% Get what frequency we are actually using:
freq = s.SampleRate;
% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);
disp('-- start recording --');  % Debug use
level = 0;
success = true;
discardedAudio = [];
while level < voiceTrigger
    % Fetch current audiodata:
    [audioData offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle);
    if GetSecs-tCaptureStart>maxWaitSec
        % maxWaitSec reached without sound
        success = false;
        break;
    end
    if overflow>0
        warning('Audio data exceeds buffer size. Data lost.');
    end
    % Compute maximum signal amplitude in this chunk of data:
    if ~isempty(audioData)
        level = max(abs(audioData(1,:)));
    else
        level = 0;
    end

    % Below trigger threshold?
    if level < voiceTrigger
        if plotWave
            discardedAudio=[discardedAudio, audioData];  %#ok
        end
        % Wait before next scan:
        WaitSecs(0.0001);
    end
end
if success
    % Find exact location of first above threshold sample.
    idx = min(find(abs(audioData(1,:)) >= voiceTrigger));  %#ok<MXFND>
    idxTotal = offset + idx - 1;
    % Initialize our recordedaudio vector with captured data starting from
    % triggersample:
    recordedAudio = audioData(:, idx:end);
    if plotWave
        discardedAudio = [discardedAudio, audioData(:, 1:idx)];
    end
    % For the fun of it, calculate signal onset time in the GetSecs time:
    timeSec = tCaptureStart + ((offset + idx - 1) / freq);
    % Record 'recordSec' more seconds for the whole word.
    while tCaptureStart + offset/freq < timeSec + recordSecs
        [audioData offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle);
        if overflow
            warning('Audio data exceeds buffer size. Data lost.');
        end
        recordedAudio = [recordedAudio audioData];  %#ok
    end
end
% Stop capture
PsychPortAudio('Stop', pahandle);
% If no voice found
if ~success
    timeSec = [];
    return;
end
% Perform a last fetch operation to get all remaining data from the capture engine
audioData = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector
recordedAudio = [recordedAudio audioData];
% Plot wave
if plotWave
    plotData = [discardedAudio, recordedAudio];
    plot((1:size(plotData, 2)) ./ freq, plotData(1, :), 'b');
    hold on
    plot([idxTotal/freq, idxTotal/freq+0.4], [0, voiceTrigger], 'r');  % onset point in line
    scatter(idxTotal/freq, 0, 3, 'r', 'Marker', 'x');
    text(idxTotal/freq+0.41, voiceTrigger, 'onset');
    xlabel('Time (s)');
    ylabel('Amplitude');
end
% Store recorded sound. Use 'targetWord' to name the file.
if ~isempty(targetWord) && saveAudio
    wavFileName = [datestr(datetime('now')), '-', targetWord, '.wav'];
    folder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    psychwavwrite(transpose(recordedAudio), freq, 16,fullfile(folder,wavFileName));
end
end
