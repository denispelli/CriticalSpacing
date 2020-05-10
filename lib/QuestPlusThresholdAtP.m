function thresholdP=QuestPlusThresholdAtP(o,p)
% thresholdP=QuestPlusThresholdAtP(o,p);
% We assume that the QuestPlus parameters specify a Weibull function. We
% return the "contrast" (or whatever) at the specified proportion correct
% p. This is the inverse of the Weibull function. Thus it's more or less
% equivalent to 
%% stimContrast = qpPFWeibullInv(proportionCorrect,psiParams)
% but takes different arguments. The Weibull function is:
%% predictedProportions = qpPFWeibull(stimParams,psiParams)
% In Mathematica
% QpPFWeibull[{c_}, {threshold_, slope_, guess_, lapse_}] = {#, 1 - #} &@(lapse - (guess þ lapse - 1) Exp[-10^(slope (c - threshold)/20) ])
% QpPFWeibull[{c_}, {threshold_, slope_, guess_, lapse_}]=1-(lapse-(guess+lapse-1)*Exp[-10^(slope*(c-threshold)/20)])
%     stimParams     Matrix, with each row being a vector of stimulus parameters.
%                    Here the row vector is just a single number giving
%                    the stimulus contrast level in dB.  dB defined as
%                    20*log10(x).
%
%     psiParams      Row vector or matrix of parameters
%                      threshold  Threshold in dB
%                      slope      Slope
%                      guess      Guess rate
%                      lapse      Lapse rate
% denis.pelli@nyu.edu, April 8, 2020
if nargin~=2
  error('Both arguments are required: thresholdP=QuestPlusThresholdAtP(o,p).');
end
thresholdP=o.qpThreshold*...
    (-log(1-(p-o.qpGuessing)/(1-o.qpGuessing-o.qpLapse)))...
    ^(1/o.qpSteepness);
