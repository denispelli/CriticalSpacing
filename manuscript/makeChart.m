n=Shuffle(repmat('123456789',1,9));
a=Shuffle(repmat('DHKNORSVZ',1,9));
aa=[];
nn=[];
ii=1;
for row=1:15
   for i=1:2
      aa=[aa a(ii) ' '];
      nn=[nn n(ii) '  '];
      ii=ii+1;
   end
   aa=[aa a(ii) '\r'];
   nn=[nn n(ii) '\r'];
   ii=ii+1;
end
aa=sprintf(aa);
nn=sprintf(nn);
aa
nn