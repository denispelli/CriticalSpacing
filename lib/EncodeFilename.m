function u = EncodeFilename(s)
  u = '';
  for k = 1:length(s)
    if ~isempty(regexp(s(k),'[ a-zA-Z0-9]','once'))
      u(end+1) = s(k);
    else
      u=[u,'%',dec2hex(s(k)+0)];
    end
  end
end
% We allow spaces.