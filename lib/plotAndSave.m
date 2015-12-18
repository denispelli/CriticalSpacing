letters = '123456789';

for i=1:1%numel(letters)
%     figure('Units', 'pixels', 'Position', [0 0 800 800]);
figure('Units', 'pixels', 'Position', [0 0 1200 1200]);
    text(0.2,0.5, letters(1), 'FontName', 'Sloan','FontUnits', 'pixels', 'FontSize', 800);
    box off
    axis off
%     box off
    print this.tiff -dtiffnocompression;
    ss = imread('this.tiff');
   % close;
end