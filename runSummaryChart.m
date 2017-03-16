function runSummaryChart(name, r, lim, L, savePath, runKey, isSemi)
if isSemi,
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.MoD name.DoM name.STFD name.LSSPu name.TSu name.FSu name.MoDu name.DoMu name.STFDu};
    res = [r.STA/lim.STA(L) r.GRAa/lim.GRAa(L) r.GRAb/lim.GRAb(L) r.SRTt/lim.SRT(L) r.YDC/lim.YDC(L) r.ACC/lim.ACC(L) r.RA/lim.RA(L) r.HSTO/lim.HSTO(L) r.TASP/lim.TASP(L) r.LSSP/lim.LSSP(L) r.TS/lim.TS(L) r.FS/lim.FS(L) r.MoD/lim.MoD(L) r.DoM/lim.DoM(L) r.STFD/lim.STFD(L) r.LSSPu/lim.LSSP(L) r.TSu/lim.TS(L) r.FSu/lim.FS(L) r.MoDu/lim.MoD(L) r.DoMu/lim.DoM(L) r.STFDu/lim.STFD(L)]*100;
else
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.STFD name.LSSPu name.TSu name.FSu name.STFDu};
    res = [r.STA/lim.STA(L) r.GRAa/lim.GRAa(L) r.GRAb/lim.GRAb(L) r.SRTt/lim.SRT(L) r.YDC/lim.YDC(L) r.ACC/lim.ACC(L) r.RA/lim.RA(L) r.HSTO/lim.HSTO(L) r.TASP/lim.TASP(L) r.LSSP/lim.LSSP(L) r.TS/lim.TS(L) r.FS/lim.FS(L) r.STFD/lim.STFD(L) r.LSSPu/lim.LSSP(L) r.TSu/lim.TS(L) r.FSu/lim.FS(L) r.STFDu/lim.STFD(L)]*100;
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