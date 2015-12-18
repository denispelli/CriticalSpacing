function SaveStickLettersToDisk
s = [ ...
  '111'
  '211'
  '311'
  '121'
  '221'
  '321'
  '131'
  '231'
  '331'
  '122'
  '113'
  '213'
  '313'
  '133'];
h = 10;

for i=1:size(s,1)
  m = zeros(3*h,2);
  
  for j=1:size(m,1)/h
    if ismember(s(i,j),'12') %ignore 3
      m((j-1)*h+1:j*h,str2num(s(i,j)))=1;
    end
  end
  
  figure
  imshow(m);
  print(['stick' num2str(i) '.png'], '-dpng');
  close
  
end