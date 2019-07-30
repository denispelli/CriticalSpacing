function AnalyzeCorpusFrequency(o)
% AnalyzeCorpusFrequency(o);
% The globals are computed for CriticalSpacing.m
global corpusFilename corpusText corpusFrequency corpusWord corpusSentenceBegins corpusLineEndings
global ff
switch o.task
    case 'read'
        if ~streq(corpusFilename,o.readFilename) || isempty(corpusLineEndings)
            % corpusWord{i} lists each word in the corpus in order of
            % descending frequency. corpusFrequency(i) is frequency of each
            % word in the corpus.
            ffprintf(ff,'Computing stats of text corpus in ''%s''.',...
                o.readFilename);
            s=GetSecs;
            mainFolder=fileparts(fileparts(mfilename('fullpath')));
            readFolder=fullfile(mainFolder,'read');
            corpusFilename=o.readFilename;
            readFile=fullfile(readFolder,corpusFilename);
            % MATLAB's textscan and readfile both failed to read the
            % unicode characters from my UTF-8 file. This user-written
            % textscanu works. The file type must be UTF-8, which BBEdit
            % allows when you do a Save As. I suppose this is a text file
            % with the first byte indicating the encoding. We specify
            % nonexistent delimiter and linefeed, so the text will come
            % through as one long string.
            corpusText=textscanu(readFile,'UTF-8',2,2);
            if length(corpusText)>1
                assert(isempty(corpusText{2}),'The corpus is broken up into parts.');
            end
            corpusText=corpusText{1};
            words=WordsInString(corpusText);
            % corpusFrequency(i) is frequency of word corpusWord(i) in our corpus.
            corpusWord=unique(words);
            % Remove any trailing punctuation.
            for i=1:length(corpusWord)
                if ~ismember(corpusWord{i}(end),'abcdefghijklmnopqrstuvwxyzABCEDEFGHIJKLMNOPQRSTUVWXYZ')
                    corpusWord{i}=corpusWord{i}(1:end-1);
                    if ~ismember(corpusWord{i}(end),'abcdefghijklmnopqrstuvwxyzABCEDEFGHIJKLMNOPQRSTUVWXYZ')
                        corpusWord{i}=corpusWord{i}(1:end-1);
                    end
                end
            end
            corpusWord=unique(corpusWord);
            corpusFrequency=zeros(size(corpusWord));
            for i=1:length(corpusWord)
                corpusFrequency(i)=sum(ismember(words,corpusWord{i}));
            end
            [corpusFrequency,ii]=sort(corpusFrequency,'descend');
            corpusWord=corpusWord(ii);
            % corpusSentenceBegins lists the character
            % positions where sentences begin. For this purpose, we
            % suppose that the corpus begins with a sentence, and that
            % the character after period space is always a sentence
            % beginning.
            corpusSentenceBegins=[1 strfind(corpusText,'. ')+2];
            corpusLineEndings=find(WrapString(corpusText,o.readCharsPerLine)==newline);
            ffprintf(ff,' (%.0f words took %.0f s).\n',length(words),GetSecs-s);
        end
end