function o=ShiftPointIntoRect(o,ff,name,xy,radiusDeg,r)
% o=ShiftPointIntoRect(o,ff,name,xy,radiusDeg,r)
radius=o.pixPerDeg*radiusDeg;
r=InsetRect(r,radius,radius);
if ~IsXYInRect(xy,r) % Is fixation off screen?
    if o.okToShiftCoordinates
        % Adjust position of near point visual coordinate so "name" fits on
        % screen. Place it at nearest visible point of screen.
        newXY=LimitXYToRect(xy,r);
        % Update o.nearPointXYDeg.
        oldNearPointXYDeg=o.nearPointXYDeg;
        o.nearPointXYDeg=o.nearPointXYDeg+XYDegOfXYPix(o,newXY)-XYDegOfXYPix(o,xy);
        ffprintf(ff,['NOTE: Adjusting o.nearPointXYDeg from ' ...
            '[%.1f %.1f] deg to [%.1f %.1f] deg to fit %s ' ...
            '(with %.1f deg radius) on screen.'],...
            oldNearPointXYDeg,o.nearPointXYDeg,name,radiusDeg);
    else
        error(['Sorry, despite your request, %s doesn''t fit on screen ' ...
            'and it''s not o.okToShiftCoordinates. You might try ' ...
            'adjusting o.nearPointXYDeg.'],name);
    end
end