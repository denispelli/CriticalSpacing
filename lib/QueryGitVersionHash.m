function [hash, s] = QueryGitVersionHash()
% Get the git version tag of currect version
% On systems where git is installed, it will try to use git for the
% query, and update the VERSION file, if necessary.
% On systems where git is absent, it will look for the VERSION file
% Also returns a structure that could be useful for debugging.
%
% Hormet Yiltiz, 2016
%

verbose = false;

[s.GitVersionStatus, cmdout] = system('git version');
switch s.GitVersionStatus
  case 0
    assert(~isempty(regexp(cmdout, 'git version .*')), ...
      'Unknown git version. Please re-install git.');
    s.IsGitExist = true;
    s.GitVersion = cmdout;

  case 127 % system default return for non-existent commands (tested on OSX)
    % Should work on all POSIX compliant systems
    % On Windows, git should be in systems PATH to be able to detected
    % That option is provided when installing git (not Github Desktop)
    s.IsGitExist = false;

  otherwise
    s.IsGitExist = false;
    warning('QueryGitVersionHash:UnknownGitPresence', 'Whether git is installed is unknown. Check system PATH variable.');
end


if s.IsGitExist
  % update the version file
  s.LogStatus = system('git log | head -n 3 > ../VERSION');
  if verbose; disp('Updated VERSION file.');end
  assert(~s.LogStatus, 'Unable to update the VERSION file!');
end


VERSIONfile='../VERSION';
% NOTE: this script should be put under ./lib/ folder
% not top directory, so that the relative path of the
% VERSION file is ../VERSION

if exist(VERSIONfile, 'file')==2
  % look for the VERSION file
  fid = fopen(VERSIONfile);
  firstLine = fgetl(fid);
  fclose(fid);

  hash = firstLine(numel('commit '):end); %the sha512 hash!
end

end
