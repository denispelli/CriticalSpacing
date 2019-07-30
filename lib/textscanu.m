function C = textscanu(filename, encoding, del_sym, eol_sym, wb)
% C = textscanu(filename, encoding, del_sym, eol_sym, wb);
% TEXTSCANU Reads Unicode strings from a file and outputs a cell array of strings
% 
% -------------
% INPUT
% -------------
% filename - string with the file's name and extension
%            - example: 'textscanu.m.txt'
% encoding - encoding of the file
%            - default: UTF-16LE
%            - examples: UTF-16LE (little Endian), UTF-8.
%            - See http://www.iana.org/assignments/character-sets
%            - MS Notepad saves in UTF-16LE ('Unicode'), 
%              UTF-16BE ('Unicode big endian'), UTF-8 and ANSI.
% del_sym - column delimitator symbol in ASCII numeric code
%            - default: 9 (tabulator)
% eol_sym - end of line delimitator symbol in ASCII numeric code
%            - default: 13 (carriage return) [Note: line feed=10]
%            - on MS Windows use 13, on Unix 10
% wb - displays a waitbar if wb = 'waitbar'
% 
% Defaults:
% -------------
% BOM - the first character of the file is assumed to be a 
%       Byte Order Mark and removed, if it's unicode2native()
%       value is 26
% byte_encoding - this value is read from the last two characters
%       of the encoding input variable if they are 'LE' or 'BE',
%       otherwise 'little endian' is the default for Windows and
%       'big endian' for Unix
% eol_len - number of characters used as end of line markers; 
%       for a Windows AND a value of 13, eol_len is 2, 
%       otherwise 1
% 
% -------------
% OUTPUT
% -------------
% C - cell array of strings
% 
% -------------
% EXAMPLE
% -------------
% C = textscanu('textscanu.txt', 'UTF-8', 9, 13, 'waitbar');
% Reads the UTF-8 encoded file 'textscanu.m.txt', which has
% columns and lines delimited by tabulators, respectively 
% carriage returns. Shows a waitbar to make the progress 
% of the function's action visible.
%
% -------------
% NOTES
% -------------
% 1. Matlab's textscan function doesn't seem to handle 
% properly multiscript Unicode files. Characters 
% outside the ASCII range are given the \u001a or 
% ASCII 26 value, which usually renders on the 
% screen as a box.
% 
% Additional information at "Loren on the Art of Matlab":
% http://blogs.mathworks.com/loren/2006/09/20/
% working-with-low-level-file-io-and-encodings/#comment-26764
% 
% 2. Text editors such as Microsoft Notepad or Notepad++ use 
% a carriage return (CR, ascii 13) and a line feed (LF, ascii 10) 
% to mark line ends (when you hit the enter key for example), 
% instead of just carriage return as usual on Unix or 
% Microsoft Word.
% 
% In textscanu use ascii 13 as delimitator in the case of 
% end lines marked with the CR/LF combination. Since the LF
% is beyond the end of a given line and not part of the next,
% it is disregarded by the function.
% 
% 3. If you get spaces inbetween characters, try changing
% the encoding parameter.
% 
% -------------
% BUG
% -------------
% When inspecting the output with the Array Editor, 
% in the Workspace or through the Command Window,
% boxes might appear instead of Unicode characters.
% Type C{1,1} at the prompt or in Array Editor click 
% on C then C{1,1}: you will see the correct string 
% if you have an a Unicode font for the appropriate
% character ranges installed and enabled for the Command 
% Window and Array Editor (File > Preferences > Fonts).
% 
% However, up to Matlab R2010a at least, Unicode
% characters display as boxes in figures, even if
% data is correctly stored in Matlab as Unicode.
%
% -------------
% REQUIREMENTS
% -------------
% Matlab version: starting with R2006b
%
% See also: textscan
%
% -------------
% REVISIONS LOG
% -------------
% 2015.01.06 - [fix] eol_len now set for all number of input arguments
% 2014.05.04 - [fix] attempt to close figure only if it exists
% 2011.01.17 - [new] support for Unix
%            - [new] automatic detection of BOM presence
% 2010.12.31 - [new] no requirement anymore not to end the
%                    file with end of line marks 
%            - [fix] define default waitbar handle value 
%                    and make the message more informative
% 2010.10.04 - [fix] upgrade to Matlab version 2007a
% 2009.06.13 - [new] added option to display a waitbar
% 2008.02.27 - function creation
%
% -------------
% CREDITS
% -------------
% Vlad Atanasiu
% atanasiu@alum.mit.edu, http://www.waqwaq.info/atanasiu/

% parse inputs & set defaults
h = [];
if nargin < 2
    if ispc
        encoding = 'UTF-16LE';
    else
        encoding = 'UTF-16BE';
    end
end
if ispc
    % Windows defaults
    if strcmp(encoding(end-1:end),'BE')
        byte_order = 'b';
    else
        byte_order = 'l';
    end
else
    % Unix defaults
    if strcmp(encoding(end-1:end),'LE')
        byte_order = 'l';
    else
        byte_order = 'b';
    end
end
if nargin < 3
    del_sym = 9; % column delimitator symbol (TAB=9)
end
if nargin < 4
    if ispc
        eol_sym = 13; % end of line symbol (CR=13, LF=10)
        eol_len = 2; % LF & CR
    else
        eol_sym = 10;
        eol_len = 1; % LF
    end
end
if nargin >= 4
    eol_len = 2;
    t = ispc;
    if (t == 1 && eol_sym ~= 13) || ~t
        eol_len = 1;
    end
end
if nargin > 4
    if strcmp(wb, 'waitbar') == 1;
        h = waitbar(0,''); % display waitbar
        set(h,'name','textscanu')
    end
end
warning off MATLAB:iofun:UnsupportedEncoding;

% read input
fid = fopen(filename, 'r', byte_order, encoding);
S = fscanf(fid, '%c');
fclose(fid);

% remove trailing end-of-line delimitators
while abs(S(end)) == eol_sym || abs(S(end)) == 10
    S = S(1:end-1);
end

% remove Byte Order Marker
BOM = unicode2native(S(1));
if BOM == 26
    S = S(2:end);
end

% add an end of line mark at the end of the file
S = [S char(eol_sym)];

% locates column delimitators and end of lines
del = find(abs(S) == del_sym); 
eol = find(abs(S) == eol_sym);

% get number of rows and columns in input
row = numel(eol);
col = 1 + numel(del) / row;
C = cell(row,col); % output cell array

% catch errors in file
if col - fix(col) ~= 0
    if ishandle(h)
        close(h)
    end
    error(['Error: The file doesn''t have the same number'...
        'of columns per row or row-ends are malformed.'])
end

m = 1;
n = 1;
sos = 1;

% parse input
if col == 1
    % single column input
    for r = 1:row
        if ishandle(h)
            waitbar( r/row, h, [num2str(r), '/', num2str(row)...
                ' file rows processed'] )
        end
        eos = eol(n) - 1;
        C(r,col) = {S(sos:eos)};
        n = n + 1;
        sos = eos + eol_len + 1;
    end
else
    % multiple column input
    for r = 1:row
        if ishandle(h)
            waitbar( r/row, h, [num2str(r), '/', num2str(row)...
                ' file rows processed'] )
        end
        for c = 1:col-1
            eos = del(m) - 1;
            C(r,c) = {S(sos:eos)};
            sos = eos + 2;
            m = m + 1;
        end
        % last string in the row
        sos = eos + 2;
        eos = eol(n) - 1;
        C(r,col) = {S(sos:eos)};
        n = n + 1;
        sos = eos + eol_len + 1;
    end
end
if ishandle(h)
    close(h)
end

