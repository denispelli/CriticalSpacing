function [word,frequency]=WordFrequency(text)
% [word,frequency]=WordFrequency(text);
% frequency(i) = frequency of word{i} in the text.
% Given a text, returns a unique word list, ordered by frequency, and a
% list of their frequencies. The words are cleaned up by removing any
% leading or trailing non-alphabetic characters. Empty words are discarded.
words=WordsInString(text);
word=unique(words);
for i=length(word):-1:1
    % Remove any trailing punctuation.
    while ~isempty(word{i})
        if ismember(word{i}(end),'abcdefghijklmnopqrstuvwxyzABCEDEFGHIJKLMNOPQRSTUVWXYZ')
            break
        else
            word{i}=word{i}(1:end-1);
        end
    end
    % Remove any leading punctuation.
    while ~isempty(word{i})
        if ismember(word{i}(1),'abcdefghijklmnopqrstuvwxyzABCEDEFGHIJKLMNOPQRSTUVWXYZ')
            break
        else
            word{i}=word{i}(2:end);
        end
    end
end
word=unique(word);
if isempty(word{1})
    word=word(2:end);
end
frequency=zeros(size(word));
for i=1:length(word)
    frequency(i)=sum(ismember(words,word{i}));
end
[frequency,ii]=sort(frequency,'descend');
word=word(ii);
