function keyNames=KeyNamesOfCharacters(characters)
%keyNames=KeyNamesOfCharacters(characters);
% Given a string of characters, returns the keyNames that produce them.
% Sometimes more than one key can produce the same character (e.g. space).
% This works for visible symbols, which is all that I need for
% CriticalSpacing.m. I haven't bothered to include whitespace and invisible
% characters: tab, return, escape, etc.
% Denis Pelli, January 2016
KbName('UnifyKeyNames');
keyNamesTable=KbName('KeyNames');
keyNames={};
for j=1:length(keyNamesTable)
   isFKey=length(keyNamesTable{j})>1 && keyNamesTable{j}(1)=='F';
   isCharacterKey=length(keyNamesTable{j})<3 && ~isFKey;
   add=0;
   for i=1:length(characters)
      % character or symbol included in 2-letter key that is not an F-key.
      add=add || (isCharacterKey && ismember(lower(characters(i)),keyNamesTable{j}));
      % space character
      add=add || (characters(i)==' ' && streq('space',keyNamesTable{j}));
   end
   if add
      keyNames{end+1}=keyNamesTable{j};
   end
end

