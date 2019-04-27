function x=MapEccentrityXYToHorizontalX(x,y)
% Equating fraction of distance from fixation to edge of visual field map,
% for any (x,y) eccentricity, we map to right field field of right eye.
% https://upload.wikimedia.org/wikipedia/commons/4/4c/Traquair_1938_Fig_1_modified.png
% https://en.wikipedia.org/wiki/Visual_field#/media/File:Traquair_1938_Fig_1_modified.png
% Read these off a standard perimeter (Traquair 1938) for right eye.
top=70;
right=110;
left=65;
left=right; % binocular viewing
bottom=77;

% Generate perimeter. Define an ellipse with right length and height and
% then shift it up and right.
xRadius=(left+right)/2;
yRadius=(top+bottom)/2;
xCenter=mean([-left right]);
yCenter=mean([-bottom top]);
a=-180:180;
xPerimeter=xRadius*cosd(a)+xCenter;
yPerimeter=yRadius*sind(a)+yCenter;

% Find nearest angle on perimeter.
angle=ATand2(y,x);
d=abs(angle-a);
[~,ia]=min(d);
xP=xPerimeter(ia);
yP=yPerimeter(ia);
fraction=norm([x y])/norm([xP yP]);
x=fraction*right;

% r=1:1:100;
% xx=cosd(angle)*r;
% yy=sind(angle)*r;
% xy=[xx;yy];
% plot(xx,yy,'-',xPerimeter,yPerimeter,'-',x,y,'x',xP,yP,'o');
% daspect([1 1 1])
