Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference', 'SkipSyncTests', 1);
oldRenderer=Screen('Preference','TextRenderer',1) % Request FGTL DrawText plugin.
renderer=Screen('Preference','TextRenderer',1) % Request FGTL DrawText plugin.
window=Screen('OpenWindow',0);
Screen('TextFont',window,'Arial');
fprintf('%d: renderer %d\n',MFileLineNr,Screen('Preference','TextRenderer'));
Screen('Preference','SuppressAllWarnings',0);
Screen('Preference','Verbosity',2); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('DrawText',window,'Hello',0,200,255,255); % Exercise DrawText.
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
fprintf('%d: renderer %d\n',MFileLineNr,Screen('Preference','TextRenderer'));
Screen('Close',window);