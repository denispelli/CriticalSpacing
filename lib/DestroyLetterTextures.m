function DestroyLetterTextures(letterStruct)
% Discard textures created by CreateLetterTextures.
for i=1:length(letterStruct)
   % Discard the letter textures, to free graphics memory.
   Screen('Close',letterStruct(i).texture);
end

