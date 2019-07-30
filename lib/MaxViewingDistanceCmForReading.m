function maxViewingDistanceCm=MaxViewingDistanceCmForReading(o)
% maxViewingDistanceCm=MaxViewingDistanceCmForReading(o);
% You must provide struct o, with fields:
% o.screen, the integer screen number, usually 0 for main screen.
% o.readCharsPerLine, an integer, usually 50.
% o.readLines, an integer, usually 12.
% The leadingOverSpacing scalar is needed to correctly adjust viewing
% distance to prevent overflow at bottom of screen.
leadingOverSpacing=2.7; % For Monaco font.

[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenSizeCm=[screenWidthMm screenHeightMm]/10;
maxSpacingSizeCm=screenSizeCm ./ [o.readCharsPerLine+3 o.readLines*leadingOverSpacing];
maxCmPerDeg=min(maxSpacingSizeCm/o.readSpacingDeg);
maxViewingDistanceCm=0.1/tand(0.1/maxCmPerDeg); % 1 mm subtense.
maxViewingDistanceCm=round(maxViewingDistanceCm);
