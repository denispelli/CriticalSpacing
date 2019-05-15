function [hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard
% [hasWirelessKeyboard,keyboardNameAndTransport]=HasWirelessKeyboard;
% Forces new enumeration of devices and returns a logical value reporting
% whether there is an active wireless keyboard.
% denis.pelli@nyu.edu, May, 2019.
if IsWin
    hasWirelessKeyboard=[]; % Impossible to find out on Windows.
    keyboardNameAndTransport={};
    return
end
clear PsychHID; % Force new enumeration of devices to detect external keyboard.
clear KbCheck; % Clear cache of keyboard devices.
[~,~,devices]=GetKeyboardIndices;
for i=1:length(devices)
    keyboardNameAndTransport{i}=sprintf('%s (%s)',devices{i}.product,devices{i}.transport);
end
hasWirelessKeyboard=length(GetKeyboardIndices)>=2 ...
    || contains(lower(keyboardNameAndTransport{1}),'wireless') ...
    || contains(lower(keyboardNameAndTransport{1}),'bluetooth');
end
