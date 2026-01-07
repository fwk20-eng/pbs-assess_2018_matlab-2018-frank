function savePlot(savePath, runKey, figName)

figPath = strcat(savePath,'\', runKey, '_figures');

if exist(figPath, 'dir') == 0 %If directory does not exist, make directory
    mkdir(figPath)
end

set(gcf,'Renderer','painters'); % ensures vector graphics
ax = gca;
ax.LooseInset = max(ax.TightInset, 0.02); % Force tight layout so legend is included in bounding box
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 4.25]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 4.25]);
print(gcf, '-dpdf', '-painters', '-r600', fullfile(figPath, figName));

end