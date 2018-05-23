function fixationLines=ComputeFixationLines(fix)
%ComputeFixationLines returns an array suitable for Screen('Drawlines')
% to draw a fixation cross and target cross specified by the parameters in
% the struct argument "fix".
% fix.x=50;                             % x location of fixation on screen.
% fix.y=screenHeight/2;                 % y location of fixation on screen.
% fix.eccentricityXYPix=eccentricityXYPix;  % Offset of target from fixation.
% fix.bouma=0.5;                        % Critical spacing multiple of
%                                       % eccentricity.
% fix.clipRect=screenRect;              % Restrict lines to this rect.
% fix.fixationCrossPix=fixationCrossPix;% Full width & height of fixation
%                                       % cross.
% fix.fixationCrossBlankedNearTarget=1; % 0 or 1. Blank the fixation line
%                                       % near the target. We blank within
%                                       % one critical spacing of the
%                                       % target location, left and right,
%                                       % i.e. from (1-bouma)*ecc to
%                                       % (1+bouma)*ecc, where ecc is
%                                       % target eccentricity We also
%                                       % blank a radius proportional to
%                                       % target radius.
% fix.blankingRadiusReTargetHeight=1.5; % Make vertical blanking radius 1.5
%                                       % times target height.
% fix.blankingRadiusReTargetWidth=1.5;  % Make horizontal blanking radius 
%                                       % 1.5 times target width.
% fix.targetHeightOverWidth=1;          % 1 for Sloan. 5 for Pelli font.
% fix.targetHeightPix=targetHeightPix;  % Blanking radius is proportional
%                                       % to specified target height.
% fix.markTargetLocation=true;                    % Draw vertical line indicating
%                                       % target location.
% fixationLines=ComputeFixationLines(fix);
% Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
if ~isfield(fix,'bouma') || ~isfinite(fix.bouma)
    fix.bouma=0.5;
end
if ~isfield(fix,'markTargetLocation')
    fix.markTargetLocation=false; % Default is no vertical line indicating target location.
end
if ~isfield(fix,'fixationCrossBlankedNearTarget')
    fix.fixationCrossBlankedNearTarget=1; % Default is yes.
end
if ~isfield(fix,'blankingRadiusReTargetHeight')
    fix.blankingRadiusReTargetHeight=1.5; % Blank a radius of 1.5 times target height.
end
if ~isfield(fix,'blankingRadiusReTargetWidth')
    fix.blankingRadiusReTargetWidth=1.5; % Blank a radius of 1.5 times target width.
end
if ~isfield(fix,'targetHeightOverWidth') || ~isfinite(fix.targetHeightOverWidth)
   warning('fix.targetHeightOverWidth is undefined. Assuming it is 1.');
   fix.targetHeightOverWidth=1;
end
%%%%%%%% The rest of this program ought to use XPix and YPix, but currently
%%%%%%%% uses only Pix. We ought to compute a list of lines for fixation
%%%%%%%% and target location (two crosses, a list of four lines), then
%%%%%%%% rotate all the lines so that the target eccentricity is
%%%%%%%% horizontal. Then define a crowding rect around the target and use
%%%%%%%% it to ErasePartOfLineSegment for every line in the list, which may
%%%%%%%% increase or decrease the list length. Finally we should rotate the
%%%%%%%% lines back to the original orientation.

blankingHeightPix=fix.blankingRadiusReTargetHeight*fix.targetHeightPix;
blankingWidthPix=fix.blankingRadiusReTargetWidth*fix.targetHeightPix/fix.targetHeightOverWidth;

% We initially use abs(eccentricity) and assume fixation is at (0,0). At
% the end, we adjust for polarity of eccentricity and the actual location
% of fixation (fix.x,fix.y).

% Shift clipping rect to our new coordinate system in which fixation is
% at (0,0).
r=OffsetRect(fix.clipRect,-fix.x,-fix.y);

% Horizontal line indicating fixation 
if 0>=r(2) && 0<=r(4) % Fixation is on screen.
    lineStart=-fix.fixationCrossPix/2;
    lineEnd=fix.fixationCrossPix/2;
    lineStart=max(lineStart,r(1)); % clip to fix.clipRect
    lineEnd=min(lineEnd,r(3)); % clip to fix.clipRect
    eccentricityPix=sqrt(sum(fix.eccentricityXYPix.^2));
    if fix.fixationCrossBlankedNearTarget
        blankStart=min(abs(eccentricityPix)*(1-fix.bouma),abs(eccentricityPix)-blankingWidthPix);
        blankEnd=max(abs(eccentricityPix)*(1+fix.bouma),abs(eccentricityPix)+blankingWidthPix);
    else
        blankStart=lineStart-1;
        blankEnd=blankStart;
    end
    fixationLines=[];
    if blankStart>=lineEnd || blankEnd<=lineStart
        % no overlap of line and blank
        fixationLines(1:2,1:2)=[lineStart lineEnd ;0 0];
    elseif blankStart>lineStart && blankEnd<lineEnd
        % blank breaks the line
        fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
        fixationLines(1:2,3:4)=[blankEnd lineEnd;0 0];
    elseif blankStart<=lineStart && blankEnd>=lineEnd
        % whole line is blanked
        fixationLines=[0 0;0 0];
    elseif blankStart<=lineStart && blankEnd<lineEnd
        % end of line is not blanked
        fixationLines(1:2,1:2)=[blankEnd lineEnd ;0 0];
    elseif blankStart>lineStart && blankEnd>=lineEnd
        % beginning of line is not blanked
        fixationLines(1:2,1:2)=[lineStart blankStart ;0 0];
    else
        error('Impossible fixation line result. line %d %d; blank %d %d',lineStart,lineEnd,blankStart,blankEnd);
    end
    if eccentricityPix<0
        fixationLines=-fixationLines;
    end
else
    fixationLines=[];
end

% Vertical fixation line
if 0>=r(1) && 0<=r(3) % Fixation is on screen.
    lineStart=-fix.fixationCrossPix/2;
    lineEnd=fix.fixationCrossPix/2;
    lineStart=max(lineStart,r(2)); % clip to fix.clipRect
    lineEnd=min(lineEnd,r(4)); % clip to fix.clipRect
    fixationLinesV=[];
    if ~fix.fixationCrossBlankedNearTarget || abs(eccentricityPix)>blankingHeightPix
        % no blanking of line
        fixationLinesV(1:2,1:2)=[0 0;lineStart lineEnd];
    elseif lineStart<-blankingHeightPix
        % blank breaks the line
        fixationLinesV(1:2,1:2)=[0 0; lineStart -blankingHeightPix];
        fixationLinesV(1:2,3:4)=[0 0; blankingHeightPix lineEnd];
    else
        % whole line is blanked
        fixationLinesV=[0 0;0 0];
    end
    fixationLines=[fixationLines fixationLinesV];
end

% Vertical target line
if fix.markTargetLocation && eccentricityPix>=r(1) && eccentricityPix<=r(3)
    % Compute at eccentricity zero, and then offset to desired target
    % eccentricity.
    lineStart=-fix.fixationCrossPix/2;
    lineEnd=fix.fixationCrossPix/2;
    lineStart=max(lineStart,r(2)); % vertical clip to fix.clipRect
    lineEnd=min(lineEnd,r(4)); % vertical clip to fix.clipRect
    fixationLinesV=[];
    if ~fix.fixationCrossBlankedNearTarget
        % no blanking of line
        fixationLinesV(1:2,1:2)=[0 0;lineStart lineEnd];
    elseif lineStart<-blankingHeightPix
        % blank breaks the line
        fixationLinesV(1:2,1:2)=[0 0; lineStart -blankingHeightPix];
        fixationLinesV(1:2,3:4)=[0 0; blankingHeightPix lineEnd];
    else
        % whole line is blanked
        fixationLinesV=[0 0;0 0];
    end
    fixationLinesV(1,:)=fixationLinesV(1,:)+eccentricityPix; % target eccentricity
    fixationLines=[fixationLines fixationLinesV];
end

% Shift everything to desired location of fixation.
fixationLines(1,:)=fixationLines(1,:)+fix.x;
fixationLines(2,:)=fixationLines(2,:)+fix.y;
fixationLines=round(fixationLines);
end