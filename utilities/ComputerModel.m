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
            s=s(1:end-1); % Remove trailing space.
        end
        machine.Model=s;
        machine.Manufacturer='Apple Inc.';
    case 'PCWIN64'
        wmicString = evalc('!wmic computersystem get manufacturer, model');
        % Here's a typical result:
%         wmicString=sprintf(['    ''Manufacturer  Model            \r'...
%         '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(wmicString,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Change run of 2+ spaces to a tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9));
        clear ok
        for i=1:length(fields)
            ok(i)=~isempty(fields{i});
        end
        fields=fields(ok); % Discard empty fields.
        % The original had two columns: category and value. We've now got
        % one long column with n categories followed by n values.
        % We asked for Manufacturer and Model so n should be 2.
        n=length(fields)/2;
        for i=1:n
            % Grab each field's name and value.
            machine.(fields{i})=fields{i+n};
        end
        if ~isfield(machine,'Manufacturer') || isempty(machine.Manufacturer)...
                || ~isfield(machine,'Model') || isempty(machine.Model)
            wmicString
            warning('Failed to retrieve Manufacturer and Model from WMIC.');
        end
    case 'GLNXA64'
        machine.Manufacturer='';
        machine.Model='linux';
end