letters = '123456789';

for i=1:numel(letters)
    figure('Position', [0 0 800 800]);
    text(0,0, letters(1));
    print this.tiff -dtiffnocompression;
    ss = imread('this.tiff');
    close;
end