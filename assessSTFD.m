function STFD = assessSTFD(Time, nSteer, muPeak, Fx_L, Fy_L, Fz_L, Fx_R, Fy_R, Fz_R, ladentext, savePath, runKey, plotOn, isSave)

numer = zeros(length(Fx_L{1}), 1);
denom = zeros(length(Fx_L{1}), 1);

for i = 1:nSteer
    numer = numer + abs((Fx_L{i}.^2 + Fy_L{i}.^2).^.5 + (Fx_R{i}.^2 + Fy_R{i}.^2).^.5); 
    denom = denom + abs(Fz_L{i} + Fz_R{i});  
end

FricDemand = 100*(numer./denom)./muPeak;
[STFD, iMax] = max(FricDemand);

if plotOn
    figure('name', 'STFD','visible', 'off');
    
    hold on
    
    plot(Time, FricDemand, 'Color', getColour(1));
    plot([0 floor(max(Time)/5)*5], [80 80], '--r');
    plot(Time(iMax), STFD, 'or');
    
    xlabel('Time [sec]');
    ylabel('Friction Demand [%]');
    
    axis([0 floor(max(Time)/5)*5 0 110]);  % y axis settings overwritten next line
    text(Time(iMax) + 5, STFD + 5, ['STFD = ' num2str(ceil(STFD)) '%']);
    legTitles = {'steer axle'; 'max limit'; 'peak friction demand'};
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, ['STFD' ladentext]);
    end
    
    title(['Steer-Tyre Friction Demand' ladentext])
    hold off
end
% figure()
% plot(Time, Fx_L{1}, Time, Fx_R{1})
% figure()
% plot(Time, Fy_L{1}, Time, Fy_R{1})
% figure()
% plot(Time, Fz_L{1}, Time, Fz_R{1})


