function runSummaryChart(name, r, Lim, L, savePath, runKey, isSemi)
if isSemi,
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.MoD name.DoM name.STFD name.LSSPu name.TSu name.FSu name.MoDu name.DoMu name.STFDu};
    res = [r.STA/Lim.STA(L) r.GRAa/Lim.GRAa(L) r.GRAb/Lim.GRAb(L) r.SRTt/Lim.SRT(L) r.YDC/Lim.YDC(L) r.ACC/Lim.ACC(L) r.RA/Lim.RA(L) r.HSTO/Lim.HSTO(L) r.TASP/Lim.TASP(L) r.LSSP/Lim.LSSP(L) r.TS/Lim.TS(L) r.FS/Lim.FS(L) r.MoD/Lim.MoD(L) r.DoM/Lim.DoM(L) r.STFD/Lim.STFD(L) r.LSSPu/Lim.LSSP(L) r.TSu/Lim.TS(L) r.FSu/Lim.FS(L) r.MoDu/Lim.MoD(L) r.DoMu/Lim.DoM(L) r.STFDu/Lim.STFD(L)]*100;
else
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.STFD name.LSSPu name.TSu name.FSu name.STFDu};
    res = [r.STA/Lim.STA(L) r.GRAa/Lim.GRAa(L) r.GRAb/Lim.GRAb(L) r.SRTt/Lim.SRT(L) r.YDC/Lim.YDC(L) r.ACC/Lim.ACC(L) r.RA/Lim.RA(L) r.HSTO/Lim.HSTO(L) r.TASP/Lim.TASP(L) r.LSSP/Lim.LSSP(L) r.TS/Lim.TS(L) r.FS/Lim.FS(L) r.STFD/Lim.STFD(L) r.LSSPu/Lim.LSSP(L) r.TSu/Lim.TS(L) r.FSu/Lim.FS(L) r.STFDu/Lim.STFD(L)]*100;
end

maxX = ceil(max(res)/5)*5+5;
figure()
hold on

% blocks indicating failure region
h1 = barh([100 100 100 100 100 maxX*ones(1,16)], 'r');
set(h1,'EdgeColor','r')
set(h1,'BarWidth',1)
h2 = barh([0 0 0 0 0 100*ones(1,16)], 'w');
set(h2,'EdgeColor','w')
set(h2,'BarWidth',1)

h = barh(res);
set(h, 'FaceColor', [0.15 0.15 0.58])
set(h, 'EdgeColor', [0.15 0.15 0.58])
if isSemi,
    set(gca,'Ytick',[1:1:21])
else
    set(gca,'Ytick',[1:1:17])
end
set(gca,'YTickLabel',Ylabs)

axis ([-0.02 maxX+0.02 0.48 length(res)+.52])
xlabel(strcat('Performance in relation to PBS Level ', {' '}, int2str(L), ' limit [%]'))
set(gca,'YDir','reverse')
set(gca,'box','on')
set(gca,'Linewidth',2)

set(gcf,'PaperPosition',[0 0 16 11])
savePlot(savePath, runKey, 'summary')

hold off
end