function timeSec=SpeechTimer(action, deviceName, filename, maxWaitSec, plotWave)
% SpeechTimer('open',[, deviceName=[]])
% timeSec=SpeechTimer('listen'[, [], filename][, maxWaitSec=5][, plotWave=false])
% SpeechTimer('close')
% Return absolute time, from GetSecs, when speech is detected. If none
% detected after maxWaitSec (default 5 s), then return []. The deviceName
% argument is used solely by action 'open'; it is ignored when action is
% 'listen'. If 'filename' is not empty then two seconds of speech are
% recorded in a file of that name, in the same folder as this M file.
% Ziyi Zhang, November 30, 2019.
% December 1, 2019. DGP. Polished.

if nargin<1
    error('You must provide an ''action'' argument: ''open'', ''listen'', or ''close''.');
end
if nargin<2
    deviceName='';
end
if nargin<3
    filename=[];
end
if nargin<4
    maxWaitSec = 5;
end
if nargin<5
    plotWave = false;
end
if isempty(deviceName)
    disp('Using default microphone.');
    deviceName=[];
else
    disp(['Using ''' deviceName ''' microphone.']);
end

persistent pahandle
% Set the threshold amplitude.
voiceTrigger = 0.01;
% Set the time span in seconds recorded and saved to disk.
recordSecs = 2;

switch(action)
    case 'open'
        if nargout>0
            error('No output for action ''open''.');
        end
        if nargin>2
            error('Too many arguments. Only two allowed for ''open''.');
        end
        % Running on PTB-3? Abort otherwise.
        AssertOpenGL;
        % Initialize the sound driver.
        InitializePsychSound;
        % Open audio device 'device', with mode 2 (== Only audio capture),
        % and a required latencyclass of 1 == low-latency mode, with the
        % preferred default sampling frequency of the audio device, and 1
        % sound channel for monaural capture. 
        devices=PsychPortAudio('GetDevices');
        if isempty(deviceName)
            deviceId=[];
        else
            ii=[devices.NrInputChannels]>0;
            if ismember(deviceName,{devices(ii).DeviceName})
                ii=ismember({devices(ii).DeviceName},deviceName);
                deviceId=find(ii);
            else
                for i=1:length(devices)
                    if devices(i).NrInputChannels>0
                        fprintf('Available: ''%s''\n',devices(i).DeviceName);
                    end
                end
                error('deviceName ''%s'' is not available.',deviceName);
            end
        end
        % This returns a handle to the audio device:
        pahandle = PsychPortAudio('Open', deviceId, 2, 1, [], 1);
        % Preallocate an internal audio recording buffer
        PsychPortAudio('GetAudioData', pahandle, maxWaitSec+recordSecs);
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        PsychPortAudio('Stop', pahandle);
        return
    case 'close'
        if nargout>0
            error('No output for action ''close''.');
        end
        if nargin>1
            error('Too many arguments. Only one allowed for ''close''.');
        end
        if ~isempty(pahandle)
            % Close the audio device:
            PsychPortAudio('Close', pahandle);
            pahandle=[];
        end
        return
    case 'listen'
        if isempty(pahandle)
            error('You must first call with action ''open''.');
        end
        % Run code below.
    otherwise
        error('Unknown "action" ''%s''.',action);
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
    [audioData,offset,overflow,tCaptureStart] = ...
        PsychPortAudio('GetAudioData', pahandle);
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
            discardedAudio=[discardedAudio, audioData];  % #ok
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
        [audioData,offset,overflow,tCaptureStart] =...
            PsychPortAudio('GetAudioData', pahandle);
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
if ~isempty(filename)
    wavFileName = [datestr(datetime('now')), '-', filename, '.wav'];
    folder=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    psychwavwrite(transpose(recordedAudio), freq, 16,fullfile(folder,wavFileName));
end
end
