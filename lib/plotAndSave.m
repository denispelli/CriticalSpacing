letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

for i=1:numel(letters)
    figure('Units', 'pixels', 'Position', [0 0 600 600]);
    text(0,300, letters(i), 'Units', 'pixels', 'FontName', 'Sloan','FontUnits', 'pixels', 'FontSize', 600);
    box off
    axis off
    set(gca,'XTick',[]) % Remove the ticks in the x axis!
    set(gca,'YTick',[]) % Remove the ticks in the y axis
    %     print this.tiff -dtiffnocompression -r0 -noui -opengl;
    %     saveas(gcf, 'this.tiff',' -tiffn');
    %     export_fig this.png;
    F = getframe(gcf);
    [ss, Map] = frame2im(F);
    
%     ss = imread('this.png');
    close; 
    
       
    % we just use the ss here, dont actually need to plot the stuff as
    % below
    figure;image(ss);pause;close; % see the coordinates, for programming the clipping
%     figure;imshow(ss);pause;close; % this is what we see
    
end