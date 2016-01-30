for i=1:3
   clear PsychHID; % Force new enumeration of devices.
   clear KbCheck; % Clear persistent cache of keyboard list.
   [kb,~,devices]=GetKeyboardIndices;
   fprintf('%d keyboards\n',length(kb));
   KbStrokeWait(-1);
   fprintf('ok\n');
   WaitSecs(5); % Allow time to atach or detach keyboard.
end