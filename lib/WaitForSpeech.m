function timeSec=WaitForSpeech(deviceName,maxWaitSec)
% timeSec=WaitForSpeech(deviceName,maxWaitSec)
% Return absolute time when speech is detected. If none detected after
% maxWaitSec (default 5 s), then return [].
% Ziyi, November, 2019.
% December 1, 2019. DGP. Polished.
if nargin<2
    maxWaitSec=5;
end
if nargin<1
    % deviceName='JOUNIVO JV601               ';
    deviceName='Default';
end
timeSec=[];
frameSec=0.01; % 10 ms
% frameSec species how much speech data we want in each frame from the
% audio recorder.
record=audioDeviceReader();
% record.OutputDataType='single';
record.Device=deviceName;
record.SampleRate=8000;
record.SamplesPerFrame=round(record.SampleRate*frameSec);
frameSec=record.SamplesPerFrame/record.SampleRate; % Actual value used.
frames=ceil(maxWaitSec/frameSec);
setup(record);
disp(['Using ''' deviceName ''' microphone.']);
VAD_cst_param=vadInitCstParams; % Parameters for Voice Activated Detection.
wholeSpeech=[];
for i=1:frames
    % Get one frame of audio data.
    [speech,overRun]=record();
    t=GetSecs;
    wholeSpeech=[wholeSpeech speech];
    if overRun>0
        warning('OverRun %d, %..0f ms.\n',overRun,...
            1000*overRun*record.SampleRate);
    end
    
    % Call the VAD algorithm.
    isSpeech=vadG729(speech,VAD_cst_param);
    if isSpeech
        timeSec=t;
        break;
    end
end
clear vadG729
end
