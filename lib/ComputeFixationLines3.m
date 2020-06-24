function [fixationLines,fixationDots,isTargetLocationMarked]=ComputeFixationLines3(fix)
% [fixationLines,fixationDots,isTargetLocationMarked]=ComputeFixationLines3(fix);
%
% Now enhanced to support many targets at once. Thus eccentricityXYPix and
% targetHeightPix have one row per target. All targets are blanked by the
% same rules. For n targets, the input argument struct "fix" must have
% these fields:
% with n rows: eccentricityXYPix targetHeightPix
% with 1 or n rows: targetMarkPix isTargetLocationMarked
% with 1 row: the rest.
% [Actually, the rule is a bit softer. For items that would have 1 column
% and n rows, it's fine to instead have 1 row and n columns. Only the
% length is checked.]
%
% GROUPS. The need for coping with many targets arises from randomly
% interleaving various conditions with different targets, and the use of
% fix.uncertaintParameter to allow multiple possible targets within each
% condition. Within a group, the fixation mark should not reveal which
% condition (of those in the group) this trial is, so any marking of target
% locations and blanking near target locations must consider all possible
% target locations across the conditions in the group, without regard to
% which condition this trial is. Here we merely accept and process multiple
% target locations.
%
% ComputeFixationLines3 returns an array "fixationLines" suitable for
% Screen('Drawlines',window,fixationLines) to draw a cross at fixation and
% (optionally) an X at each target location, as specified by the parameters
% in the struct argument "fix". It also optionally blanks a square area
% centered on each target. The blanking radius can depend on target size
% and eccentricity, to avoid masking and crowding of the target by the
% fixation marks. This typically leaves several line segments that still
% imply lines intersecting at fixation. Furthermore, blanking is restricted
% to blankingClipRect, which is typically used to protect a screen margin
% from blanking, so some trace of each of the fixation X's four branches
% always remains.
%
%% fix.blankingClipRect
% When there are many possible targets (due to multiple conditions in a
% group and/or uncertainty within each condition) in a group, they would
% they could easily produce complete blanking of the fixation marks, which
% confuses the observer. To address this, iComputeFixationLines3.m now
% accepts fix.blankingClipRect to clip the blanking, sparing the screen
% outside that rect from blanking. (This supports a new parameter
% o.blankingClipRectInUnitSquare in CriticalSpacing.m and
% NoiseDiscrimination.m.) Thus, if fixation is onscreen and
% fix.fixationMarkPix is infinite, then, by protecting all four edges of
% the screen from blanking, you can guarantee a visble on-screen residue
% from each of the 4 radii of the fixation cross. Observer instructions
% typically ask the observer to keep her eyes on the fixation cross, which
% makes no sense if it's entirely blanked. Right now none of my experiments
% mark the target location, and I'm unsure whether we should spare blanking
% of the target marks outside blankingClipRect. I coded it to apply the
% same blankingClipRect to all marks, but perhaps it should apply only to
% the fixation cross.
%
% OUTPUT:
% "fixationLines" has two rows, x and y. Each column is a point. Each pair
% of columns specifies a line.
% "fixationDots"
% "isTargetLocationMarked"
%
% INPUT:
%% ONE FIXATION CROSS
% fix.xy=XYPixOfXYDeg(oo(1),[0 0]);     % screen location of fixation
% if oo(oi).isFixationClippedToStimulusRect
%     fix.clipRect=oo(oi).stimulusRect;
% else
%     fix.clipRect=oo(oi).screenRect;
% end
% r=fix.ClipRect-fix.ClipRect([1 2 1 2]);
% fix.blankingClipRect=oo(oi).blankingClipRectInUnitSquare .* r([3 4 3 4])+...
%     fix.clipRect([1 2 1 2]);
% fix.fixationMarkPix=fixationMarkPix;% Diameter of fixation mark. 0 for none.
% fix.useFixationDots=oo(oi).useFixationDots;
% fix.fixationDotsNumber=oo(oi).fixationDotsNumber;
% fix.fixationDotsWithinRadiusPix=oo(oi).fixationDotsWithinRadiusDeg*oo(oi).pixPerDeg;
%
%% ONE X AND BLANKING PER TARGET. EACH ARRAY HAS ONE ROW PER TARGET.
% for oi=1:length(oo)
%     fix.eccentricityXYPix(oi,1:2)=oo(oi).eccentricityXYPix;  % xy offset of target from fixation.
%     fix.targetHeightPix(oi)=oo(oi).targetHeightPix;
% end
%% PROVIDE ONE ROW FOR ALL TARGETS OR ONE ROW PER TARGET. RETURNS ONE ROW PER TARGET.
% fix.isTargetLocationMarked=true;
% fix.targetMarkPix=targetMarkPix;      % Diameter of target mark X
%% THE blankingRadiusPix FOR EACH TARGET DEPENDS ON THESE, WHICH APPLY TO ALL TARGETS.
% fix.isFixationBlankedNearTarget=true;
% fix.fixationBlankingRadiusReEccentricity=0.5; % Default value.
% fix.fixationBlankingRadiusReTargetHeight=1; % Default value.
%% CALL IT.
% fixationLines=ComputeFixationLines3(fix);
%% DRAW IT AND SHOW IT.
% Screen('DrawLines',window,fixationLines,fix.fixationThicknessPix,black);
% Screen('Flip',window);
%
% The many calls to round() don't noticeably affect the display. They just
% make the values easier to examine while debugging.
%
% History:
% October, 2015. Denis Pelli wrote it.
% November 1, 2015. Enhanced to cope with off-screen fixation or target.
% March 14, 2016. Completely rewritten for arbitrary location of fixation
% and target, using my new ClipLineSegment and ErasePartOfLineSegment
% routines.
% June 28, 2017. The new code is general, and works correctly for any
% locations of fixation and target. The target mark is now an X, to
% distinguish it from the fixation cross.
% February 18, 2020. Now support the logical flag
% fix.isFixationBlankedNearTarget.
% April 12, 2020. Now accept more than one target, and blank for each. The
% main use of this is for randomly interleaving conditions with different
% targets, where we must use the same fixation marks for all, so that
% fixation does not reveal which condition is coming. Thus we blank
% fixation near all the possible targets (not just the one for the current
% condition), and thus the fixation mark may evolve through the block as
% target properties (e.g. size) vary within a condition, but the fixation
% mark still won't reveal which condition this trial will pesent.
% April 17.2020. Add 100 random dots (to aid accomodation) within a square
% area in which the fixation cross is inscribed.
% June 21, 2020. dgp. Supports groups (oo(oi).group) and
% fix.blankingClipRect.

if isempty(fix.eccentricityXYPix)
    error('fix.eccentricityXYPix is empty.');
end
%% NUMBER OF TARGETS
n=size(fix.eccentricityXYPix,1); % One row per target.
%% JUST ONE
if ~isfield(fix,'isFixationBlankedNearTarget')
    % Default is yes.
    fix.isFixationBlankedNearTarget=true;
end
if ~fix.isFixationBlankedNearTarget
    % A request for no blanking.
    fix.fixationBlankingRadiusReTargetHeight=0;
    fix.fixationBlankingRadiusReEccentricity=0;
    fix.blankingRadiusPix=zeros(1,n);
end
if ~isfield(fix,'fixationBlankingRadiusReEccentricity')
    % Default ratio. This is what I usually want.
    fix.fixationBlankingRadiusReEccentricity=0.5;
end
if ~isfield(fix,'fixationBlankingRadiusReTargetHeight')
    % Default ratio. This is what I usually want.
    fix.fixationBlankingRadiusReTargetHeight=1;
end
if ~isfield(fix,'blankingClipRect') || isempty(fix.blankingClipRect)
    fix.blankingClipRect=fix.clipRect;
end
if ~isfield(fix,'useFixationDots') || isempty(fix.useFixationDots)
    fix.useFixationDots=false;
end
%% fixationMarkPix
if ~isfield(fix,'fixationMarkPix') || isempty(fix.fixationMarkPix)
    fix.fixationMarkPix=100;
end
switch length(fix.fixationMarkPix)
    case 1
        % ok
    otherwise
        error('fix.fixationMarkPix must be a scalar.');
end
if ~isfield(fix,'targetHeightPix')
    fix.targetHeightPix=zeros(1,n);
end
if length(fix.targetHeightPix)~=n
    error('Length of fix.targetHeightPix should be %d, but is %d.',...
        n,length(fix.targetHeightPix));
end
if ~isfield(fix,'isTargetLocationMarked')
    % Default is no marking of target location.
    fix.isTargetLocationMarked=false([n 1]);
end
switch length(fix.isTargetLocationMarked)
    case 1
        for i=2:n
            fix.isTargetLocationMarked(i)=fix.isTargetLocationMarked(1);
        end
    case n
        % Ok
    otherwise
        error('fix.isTargetLocationMarked should have 1 or %d rows, but has %d.',n,size(fix.isTargetLocationMarked,1));
end
if ~isfield(fix,'targetMarkPix')
    % Default size.
    fix.targetMarkPix=100;
end
switch length(fix.targetMarkPix)
    case 1
        for i=2:n
            fix.targetMarkPix(i)=fix.targetMarkPix(1);
        end
    case n
        % Ok
    otherwise
        error('fix.targetMarkPix should have 1 or %d rows, but has %d.',n,size(fix.targetMarkPix,1));
end
if ~isfield(fix,'blankingRadiusPix') || isempty(fix.blankingRadiusPix)
    % Default is max of specified blanking re target height and blanking re
    % eccentricity. Separately for each of n targets. This is what I usually
    % want.
    fix.blankingRadiusPix=zeros(1,n);
    for i=1:n
        eccentricityPix=norm(fix.eccentricityXYPix(i,1:2));
        r(1)=fix.fixationBlankingRadiusReEccentricity*eccentricityPix; % 0 for no blanking.
        r(2)=fix.fixationBlankingRadiusReTargetHeight*fix.targetHeightPix(i);
        fix.blankingRadiusPix(i)=round(max(r));
    end
end
if length(fix.blankingRadiusPix)~=n
    error('length(fix.blankingRadiusPix) should be %d, but is %d.',...
        n,length(fix.blankingRadiusPix));
end
fix.xy=round(fix.xy); % Printout is more readable for integers.

%% FIXATION
x0=fix.xy(1);
y0=fix.xy(2);

%% SCATTER RANDOM DOTS TO HELP OBSERVER FOCUS ON SCREEN.
if fix.useFixationDots
    if fix.fixationDotsNumber~=round(fix.fixationDotsNumber) || fix.fixationDotsNumber<0
        error('fix.fixationDots must be a positive integer.');
    end
    % Rect r is the requested dot region, which might extend far beyond
    % screen.
    r=fix.fixationDotsWithinRadiusPix*[-1 -1 1 1];
    r=OffsetRect(r,x0,y0); % Center on fixation.
    % Clip to allowed area (typically full screen).
    r=ClipRect(r,fix.clipRect);
    % Size of dot region rect.
    [rSizeXY(1),rSizeXY(2)]=RectSize(r);
    % Uniform samples, range 0 to 1.
    fixationDots=rand([2 fix.fixationDotsNumber]);
    % Scale and shift, so dots are uniformly scattered over rect.
    fixationDots=fixationDots .* rSizeXY'+r(1:2)';
    fixationDots=round(fixationDots); % Easier to view integers when debugging.
else
    fixationDots=[];
end

% Compute a list of 2+2*n lines to draw a cross at fixation and an X at
% each of the n target locations. We clip with the (screen) fix.clipRect. We
% then define a blanking rect around each target (which we clip with
% fix.blankingClipRect) and use it to
% ErasePartOfLineSegment for all the lines in the line list (and all the
% dots in the dot list). This may increase or decrease the list length.
% Two lines create a cross at fixation.
x=[x0-fix.fixationMarkPix/2 x0+fix.fixationMarkPix/2 x0 x0];
y=[y0 y0 y0-fix.fixationMarkPix/2 y0+fix.fixationMarkPix/2];
for i=1:n
    % Mark each of n target locations.
    tXY=fix.xy+fix.eccentricityXYPix(i,1:2);
    tX=tXY(1);
    tY=tXY(2);
    assert(isfinite(fix.blankingRadiusPix(i)));
    if fix.isTargetLocationMarked
        % Add two lines forming X to mark target location.
        r=0.5*fix.targetMarkPix(i)/2^0.5;
        r=min(r,1e8); % Need finite value to draw tilted lines.
        % Add the "X" to the lines already in x and y.
        x=[x tX-r tX+r tX-r tX+r]; % Make an X.
        y=[y tY-r tY+r tY+r tY-r];
    end
end
%    'Fixation, and marks (at fixation and target), before clipping'
%    x0,y0
%    x
%    y
% Clip to active part of screen.
[x,y]=ClipLineSegment(x,y,fix.clipRect);
x=round(x);
y=round(y);
for i=1:n
    % Blank each target location.
    if fix.blankingRadiusPix(i)>0
        % Blank near target.
        tXY=fix.xy+fix.eccentricityXYPix(i,1:2);
        tX=tXY(1);
        tY=tXY(2);
        blankingRect=[-1 -1 1 1]*fix.blankingRadiusPix(i);
        blankingRect=OffsetRect(blankingRect,tX,tY);
        blankingRect=round(blankingRect);
        %    'fixation cross pix'
        %    fix.fixationMarkPix
        %    'Fixation, and marks (at fixation and target), before blanking'
        %    x0,y0
        %    x
        %    y
        if ~isempty(x)
            % Limit blanking to blankingClipRect.
            blankingRect=ClipRect(blankingRect,fix.blankingClipRect); % dgp June 21, 2020
            [x,y]=ErasePartOfLineSegment(x,y,blankingRect);
        end
        %    'Marks, after blanking'
        %    x
        %    y
        %    blankingRect
        
        %% BLANK THE DOTS
        for iDot=size(fixationDots,2):-1:1
            if IsInRect(fixationDots(1,iDot),fixationDots(2,iDot),blankingRect)
                % Delete this point because it's in blankingRect.
                fixationDots(:,iDot)=[];
            end
        end
    end
end
fixationLines=[x;y];
% fixationDots;
isTargetLocationMarked=fix.isTargetLocationMarked;
return
