purr = MakeBeep(200,0.6,22254.5454545454);
   Snd('Open');
   Snd('Play',purr);e=-1:0.1:1;
minD=0.15;
d=0.3*(0.15+abs(e));
dd=d*minD/(0.3*0.15);
a=max(d,minD);
plot(e,d,e,a,e,dd);
semilogy(e,d,e,a,e,dd);