function savePlot(savePath, runKey, figName)

figPath = strcat(savePath,'\', runKey, '_figures');

if exist(figPath, 'dir') == 0 %If directory does not exist, make directory
    mkdir(figPath)
end

%print('-depsc', '-tiff', '-r600', strcat(figPath, '\', figName))
%print('-dpsc', '-r600', strcat(figPath, '\', figName))
%print('-dtiff', '-r600', strcat(figPath, '\', figName))
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 4.25]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 4.25]);
print('-dpdf', '-r600', strcat(figPath, '\', figName))