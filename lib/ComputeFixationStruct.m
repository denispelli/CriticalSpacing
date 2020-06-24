function fix=ComputeFixationStruct(oo,oi)
% fix=ComputeFixationStruct(oo,oi);
% For condition oi, collects all the necessary information from the oo
% struct to create the fixation marks (possibly including marking target
% positions) which is all returned as a struct "fix", which is meant to be
% passed to ComputeFixationLines3 to compute the fixation lines.
%
% GROUPS. A new feature of this code is to implement condition groups.
% Every condition has a "group" field, oo(oi).group, which is a string.
% Empty strings are ignored, but otherwise each condition belongs to a
% group consisting of all conditions (in oo) with the same group. I.e.
% ismember({oo.group},oo(oi).group).
%
% CriticalSpacing and NoiseDiscrimination always randomly interleave all
% conditions in oo. Typically, each condition has a unique fixation which
% gives away which condition's target is coming. Within a group, we hide
% which condition (within the group) is coming. Thus we locally blank the
% fixation markings near every possible target within the group.
%
% Group support requires that we here itemize all the possible targets and
% include them in the fix struct. This only affects a few fields, which
% formerly held data for one target and now are extended to each hold data
% for several possible targets. 
%
% ComputeFixationStruct makes some trivial modifications of oo, which we do
% NOT return to the main program. (We could, but it hardly matters.)
%
% This routine is used by both NoiseDiscrimination (which uses
% o.targetHeightDeg) and CriticalSpacing (which uses o.targetDeg), so, if
% necessary, we convert targetDeg to targetHeightDeg, taking into account
% whether o.targetSizeIsHeight and o.targetHeightOverWidth.
%
% denis.pelli@nyu.edu June 23, 2020

for oj=1:length(oo)
    if isfield(oo,'targetDeg')
        if oo(oj).targetSizeIsHeight
            heightDeg=oo(oj).targetDeg;
        else
            heightDeg=oo(oj).targetDeg*oo(oj).targetHeightOverWidth;
            if ~isfinite(oo(oj).targetHeightOverWidth)
                warning('oo(%d).targetHeightOverWidth is empty or nan.',oj);
            end
        end
    elseif isfield(oo,'targetHeightDeg')
        heightDeg=oo(oj).targetHeightDeg;
    else
        error('Neither o.targetDeg nor o.targetHeightDeg is defined.');
    end
    oo(oj).targetHeightPix=round(heightDeg*oo(oj).pixPerDeg);
    oo(oj).targetXYPix=round(XYPixOfXYDeg(oo(oj),oo(oj).eccentricityXYDeg));
end
if ~isempty(oo(1).window)
    fixationMarkPix=round(oo(oi).fixationMarkDeg*oo(oi).pixPerDeg);
    fix.fixationThicknessPix=round(oo(oi).fixationThicknessDeg*oo(oi).pixPerDeg);
    [~,~,lineWidthMinMaxPix(1),lineWidthMinMaxPix(2)]=Screen('DrawLines',oo(1).window);
    fix.fixationThicknessPix=round(max([min([fix.fixationThicknessPix lineWidthMinMaxPix(2)]) lineWidthMinMaxPix(1)]));
    oo(oi).fixationThicknessDeg=fix.fixationThicknessPix/oo(oi).pixPerDeg;
    fixationDotsWeightPix=round(oo(oi).fixationDotsWeightDeg*oo(oi).pixPerDeg);
    [~,~,dotPixMinMaxPix(1),dotPixMinMaxPix(2)]=Screen('DrawDots',oo(1).window);
    fixationDotsWeightPix=round(max([min([fixationDotsWeightPix dotPixMinMaxPix(2)]) dotPixMinMaxPix(1)]));
    oo(oi).fixationDotsWeightDeg=fixationDotsWeightPix/oo(oi).pixPerDeg;
else
    fixationMarkPix=100;
    oo(oi).useFixation=false;
    oo(oi).useFixationDots=false;
end

%% LIST ALL TARGETS.
% List all locations of possible targets. All conditons with the same
% nonempty string in oo(oi).group are considered a group. Within a group
% the fixation display should not allow the observer to tell which which
% condition, within the group, this trial will present. If the current
% condition belongs to a group, then we first make a list of all target
% locations specified by any condition in the group. Usually there is one
% target per condition, but a condition can include many possible targets
% if it specifies uncertainParameter.

% fixationXYPix is xy location of fixation on screen.
fixationXYPix=round(XYPixOfXYDeg(oo(oi),[0 0]));
fix.eccentricityXYPix=[];
fix.targetHeightPix=[];
fix.targetMarkPix=[];
fix.isTargetLocationMarked=[];
for oj=oo(oi).groupConditions
    % eccentricityXYPix is xy offset of target from fixation.
    if isfield(oo,'uncertainParameter') && ~isempty(oo(oj).uncertainParameter)
        iUncertain=find(ismember(...
            oo(oj).uncertainParameter,'eccentricityXYDeg'),1);
    else
        iUncertain=[];
    end
    if ~isempty(iUncertain)
        % Append all the target locations specified by the uncertainty of
        % condition oj.
        values=oo(oj).uncertainValues{iUncertain};
        for j=1:length(values)
            targetXYPix=round(XYPixOfXYDeg(oo(oj),values{j}));
            fix.eccentricityXYPix(end+1,1:2)=...
                targetXYPix-fixationXYPix;
            fix.targetHeightPix(end+1)=oo(oj).targetHeightPix;
            fix.isTargetLocationMarked(end+1)=oo(oj).isTargetLocationMarked;
            if oo(oj).isTargetLocationMarked
                fix.targetMarkPix(end+1)=round(oo(oj).targetMarkDeg*oo(oj).pixPerDeg);
            else
                fix.targetMarkPix(end+1)=0;
            end
        end
    else
        % Append the single target location of condition oj.
        fix.eccentricityXYPix(end+1,1:2)=...
            oo(oj).targetXYPix-fixationXYPix;
        fix.targetHeightPix(end+1)=oo(oj).targetHeightPix;
        fix.isTargetLocationMarked(end+1)=oo(oj).isTargetLocationMarked;
        if fix.isTargetLocationMarked
            fix.targetMarkPix(end+1)=round(oo(oj).targetMarkDeg*oo(oi).pixPerDeg);
        else
            fix.targetMarkPix(end+1)=0;
        end
    end
end % for oj=oo(oi).groupConditions
% The rest of the parameters are shared, having one value for all targets.
fix.xy=fixationXYPix;
fix.fixationMarkPix=fixationMarkPix;% Width & height of fixation cross.
fix.fixationBlankingRadiusReEccentricity=oo(oi).fixationBlankingRadiusReEccentricity;
fix.fixationBlankingRadiusReTargetHeight=oo(oi).fixationBlankingRadiusReTargetHeight;
fix.isFixationBlankedNearTarget=oo(oi).isFixationBlankedNearTarget;
if ~isfield(oo,'useFixationDots') || isempty(oo(oi).useFixationDots)
    fix.useFixationDots=false;
else
    fix.useFixationDots=oo(oi).useFixationDots;
    fix.fixationDotsNumber=oo(oi).fixationDotsNumber;
    fix.fixationDotsWithinRadiusPix=round(oo(oi).fixationDotsWithinRadiusDeg*oo(oi).pixPerDeg);
end
if oo(oi).isFixationClippedToStimulusRect
    fix.clipRect=oo(oi).stimulusRect;
else
    fix.clipRect=oo(oi).screenRect;
end
% Compute blankingClipRect from blankingClipRectInUnitSquare.
r=fix.clipRect-fix.clipRect([1 2 1 2]);
r=oo(oi).blankingClipRectInUnitSquare .* r([3 4 3 4]);
fix.blankingClipRect=round(r+fix.clipRect([1 2 1 2]));

% Prepare to draw fixation cross.
assert(all(all(isfinite(fix.eccentricityXYPix))));
if oo(oi).isFixationBlankedNearTarget
    fix.blankingRadiusPix=[]; % Automatic.
else
    fix.blankingRadiusPix=0; % None.
end
fix.fixationBlankingRadiusReTargetHeight=oo(oi).fixationBlankingRadiusReTargetHeight;
fix.fixationBlankingRadiusReEccentricity=oo(oi).fixationBlankingRadiusReEccentricity;

% [fixationLines,fixationDots,oo(oi).isTargetLocationMarked]=ComputeFixationLines3(fix);
