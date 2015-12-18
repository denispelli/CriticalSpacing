function testResponse
ListenChar(2);
% emulates CriticalSpacing procedure for response collection and processing
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]);
Screen('Preference','SkipSyncTests',1);
escapeKey=KbName('ESCAPE');
spaceKey=KbName('space');

oo.useSpeech=1;
oo.speakEachLetter=1;
oo.speakEncouragement=0;
oo.beepPositiveFeedback=1;
oo.beepNegativeFeedback=0;
rightBeep=MakeBeep(2000,0.05,44100);
rightBeep(end)=0;
wrongBeep=MakeBeep(500,0.5,44100);
wrongBeep(end)=0;
purr=MakeBeep(140,1.0,44100);
purr(end)=0;
Snd('Open');

condition = 1;
oo.deviceIndex = -3;
oo.alphabet='!7ij:()[]/|'; % Sloan alphabet, excluding C
oo.validKeys = {'1!','7&','i','j',';:','9(','0)','[{',']}','/?','\|'};
oo.borderLetter='!';

stimulus=Shuffle(oo(condition).alphabet);
stimulus=stimulus(1:3); % three random letters, all different.
targets=stimulus(1:2);


terminate=0;
responseString='';
% for i=1:length(oo(condition).alphabet)
for i=1:length(oo(condition).validKeys)
  oo(condition).responseKeys(i)=KbName(oo(condition).validKeys{i}); % this returns keyCode as integer
end
fprintf('Targets are: ==>%s<==\n', targets);
disp('Checking for the responseKeys list below:');
disp(oo(condition).responseKeys);
disp(KbName(oo.responseKeys));
disp('-----------------------------------------');

for i=1:length(targets)
  while(1)
    answer=GetKeypress([escapeKey oo(condition).responseKeys],oo.deviceIndex,0); % no filtering!
    % answer=upper(answer); % be loyal to values; we will filter reported
    % target from true response soon

    % if already recorded, then wait for press for the next target!
    if ~ismember(answer,responseString);break;end

  end

    if streq(answer,'ESCAPE')
    ListenChar(0);
    ffprintf('*** Observer typed escape. Run terminated.\n');
    terminate=1;
    break;
    end

  reportedTarget = oo.alphabet(ismember(oo.alphabet, answer));
  fprintf('Target seen ==>%s<==\n', reportedTarget);

  if oo(condition).speakEachLetter && oo(condition).useSpeech
    % speak the target 1 observer saw, not the keyCode '1!'
    Speak(reportedTarget);
  end

  if ismember(reportedTarget,targets)
    if oo(condition).beepPositiveFeedback
      Snd('Play',rightBeep);
    end
  else
    if oo(condition).beepNegativeFeedback
      Snd('Play',wrongBeep);
    end
  end
  responseString=[responseString reportedTarget];
end

if oo(condition).speakEncouragement && oo(condition).useSpeech && ~terminate
  switch randi(3);
    case 1
      Speak('Good!');
    case 2
      Speak('Nice');
    case 3
      Speak('Very good');
  end
end
%   if terminate
%     break;
%   end
assert(length(targets)==length(responseString))
responses=sort(targets)==sort(responseString);
fprintf('Recorded responses are:%d %d\n', responses(1), responses(2));
ListenChar(1);
end
