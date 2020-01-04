function xyPix=XYPixOfXYDeg(o,xyDeg)
% xyPix=XYPixOfXYDeg(o,xyDeg);
% Convert position from deg (relative to fixation) to (x,y) coordinate in
% o.stimulusRect. Deg increase right and up. Pix are in Apple screen
% coordinates which increase right and down. The geometric perspective
% transformation is relative to location of near point, which is orthogonal
% to line of sight. "location" refers to the near point. We often put the
% target there, but that is not assumed in this routine. In
% spatial-uncertainty experiments, we typically put fixation at the near
% point.
% xyDeg must have two columns, for x and y, and may have any number of
% rows, including none.
% The parameters of the coordinate transformation are specified by
% o.nearPointXYDeg = assigned position in visual field, in deg relative to
%                    fixation.
% o.nearPointXYPix = assigned position on screen, in pixels relative to 
%                    upper left corner.
% o.pixPerCm*o.viewingDistanceCm
% October 4, 2019. Enhanced to accept more than one point.
xyPix=zeros(size(xyDeg));
if isempty(xyDeg)
    return
end
assert(size(xyDeg,2)==2,'xyDeg must have two columns, unless empty.');
assert(isfield(o,'nearPointXYDeg'));
assert(length(o.nearPointXYDeg)==2,'Require that length(o.nearPointXYDeg)==2');
if isempty(o.nearPointXYPix)
    error('You must set o.nearPointXYPix before calling XYPixOfXYDeg.');
end
if isempty(o.pixPerCm) || isempty(o.viewingDistanceCm)
    error('You must set o.pixPerCm and o.viewingDistanceCm before calling XYPixOfXYDeg.');
end
for i=1:size(xyDeg,1)
    % Each row is an x,y point.
    xyDeg1(1:2)=xyDeg(i,1:2);
    xyDeg1=xyDeg1-o.nearPointXYDeg;
    rDeg=norm(xyDeg1);
    rPix=o.pixPerCm*o.viewingDistanceCm*tand(rDeg);
    if rDeg>0
        xyPix1=xyDeg1*rPix/rDeg;
        xyPix1(2)=-xyPix1(2); % Apple y goes down.
    else
        xyPix1=[0 0];
    end
    xyPix1=xyPix1+o.nearPointXYPix;
    xyPix(i,1:2)=xyPix1;
end
