function machine=ComputerModel
switch computer
    case 'MACI64'
% https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        s = evalc(['!'...
            'curl -s https://support-sp.apple.com/sp/product?cc=$('...
            'system_profiler SPHardwareDataType '...
            '| awk ''/Serial/ {print $4}'' '...
            '| cut -c 9- '...
            ') | sed ''s|.*<configCode>\(.*\)</configCode>.*|\1|''']);
        s=strrep(s,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        if s(end)==' '
            s=s(1:end-1);
        end
        machine.manufacturer='Apple Inc.';
        machine.model=s;
    case 'PCWIN64'
        s = evalc('!wmic computersystem get manufacturer, model');
        % s=sprintf(['    ''Manufacturer  Model            \r'...
        % '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(s,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9));
        for i=1:length(fields)
            ok(i)=~isempty(fields{i});
        end
        fields=fields(ok);
        for i=1:2
            machine.(fields{i})=fields{i+2};
        end
    case 'GLNXA64'
        machine.manufacturer='';
        machine.model='linux';
end