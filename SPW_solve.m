function [SPWmax] = SPW_solve(Project, Is, PinnerX, PinnerY, PouterXvec1, PouterYvec1, PouterXvec2, PouterYvec2,...
    PouterXvec3, PouterYvec3, plotTitle, ladentext)

SPWmax = 0;
SPW = SPWmax;
PouterXvec={PouterXvec1 PouterXvec2 PouterXvec3};
PouterYvec={PouterYvec1 PouterYvec2 PouterYvec3};
for ii=1:3,
    PouterX=PouterXvec{ii};
    PouterY=PouterYvec{ii};
    for i = 1:(length(PinnerX)-1)
        mBisectI = -(PinnerX(i+1) - PinnerX(i))/(PinnerY(i+1) - PinnerY(i));    %-ve reciprocal of the slope of the tangent
        XinBi = (PinnerX(i) + PinnerX(i+1))/2;
        YinBi = (PinnerY(i) + PinnerY(i+1))/2;
        cBisectI = YinBi - mBisectI*XinBi;
        
        errorMin = 9999999;
        for j = 1:(length(PouterX)-1)
            mOuterJ = (PouterY(j+1) - PouterY(j))/(PouterX(j+1) - PouterX(j));
            cOuterJ = PouterY(j) - mOuterJ*PouterX(j);                       %tangent passes through point j
            
            %find intercept point
            if PinnerY(i) == PinnerY(i+1) && PouterX(j) == PouterX(j+1) % both bisector and outer tangent lines are vertical
                Xint = XinBi;
                Yint = -9999;                                      % high value to ensure this point is never chosen
            elseif PinnerY(i) == PinnerY(i+1)                       %bisector is vertical (ie mBisectorI is inf)
                Xint = XinBi;
                Yint = mOuterJ*Xint + cOuterJ;                  %find pt on outer tangent
            elseif PouterX(j) == PouterX(j+1)                    %outer tangent is vertical (ie mOuterJ is inf)
                Xint = PouterX(j);
                Yint = mBisectI*Xint + cBisectI;                %find pt. on bisector
            else                                                %normal situation
                Xint = (cOuterJ-cBisectI)/(mBisectI-mOuterJ);
                Yint = mOuterJ*Xint + cOuterJ;                  %find pt on outer tangent
            end
            
            SPWij = sqrt((Yint-YinBi).^2 + (Xint-XinBi).^2);    %length of line from bisector of inner tangent and intercept with outer tangent
            
            %find closest tangent to being perpendicular to bisector
            if PinnerY(i) == PinnerY(i+1) && PouterX(j) == PouterX(j+1) % both bisector and outer tangent lines are vertical
                error = 99999999;
            elseif PinnerY(i) == PinnerY(i+1)                       %bisector is vertical (ie mBisectorI is inf)
                error = abs( atan(mOuterJ) );
            elseif PouterX(j) == PouterX(j+1)                   %outer tangent is vertical (ie mOuterJ is inf)
                if mBisectI == 0
                    error = 0;
                else
                    error = abs( pi/2 - atan(-1/mBisectI) );
                end
            else                                                %normal situation
                error = abs( atan(-1/mBisectI) - atan(mOuterJ) );
            end
            
            if error < errorMin && (Xint >= PouterX(j) && Xint <= PouterX(j+1)) && (Yint >= PouterY(j) && Yint <= PouterY(j+1)) % for checking if bisector passes between j & j+1
                %         if error < errorMin                 %lowest error on this pass so far
                errorMin = error;
                SPW = SPWij;
                XbisetorTemp = [XinBi Xint];    %store this set of coords as potential SPWmax for final plot
                YbisetorTemp = [YinBi Yint];                
                %XouterTanTemp = [PouterX(j)-1 PouterX(j) Xint PouterX(j+1) PouterX(j+1)+1];
                %YouterTanTemp = [mOuterJ*(PouterX(j)-1)+cOuterJ PouterY(j) Yint PouterY(j+1) mOuterJ*(PouterX(j+1)+1)+cOuterJ];
                %plot(PinnerX, PinnerY,'-o', PouterX, PouterY, '-*', XbisetorTemp, YbisetorTemp, '-x', XouterTanTemp, YouterTanTemp, '-o')
                %print = [mBisectI mOuterJ error SPW]
                %pause
            end
            
        end
        
        if SPW > SPWmax
            SPWmax = SPW;
            Xbisetor = XbisetorTemp;    %coords for best solution so far
            Ybisetor = YbisetorTemp;
            %XouterTan = XouterTanTemp;
            %YouterTan = YouterTanTemp;
            %print = [SPWij SPW SPWmax]
            %plot(PinnerX, PinnerY,'-o', PouterX, PouterY, '-*', Xbisetor, Ybisetor, '-x', XouterTan, YouterTan, '-o')
            %pause
        end
    end
end
% SPWmax = SPWmax   % to print result

if Is.plotOn
    figure('name', 'LSSP')
%     figure(1)
%     if strcmp(plotTitle, 'LSSP')
%         if strcmp(ladentext, '_laden')
%                 subplot(5,4,10)
%         else
%                 subplot(5,4,16)
%         end
%     else
%         if strcmp(ladentext, '_laden')
%                 subplot(5,4,11)
%         else
%                 subplot(5,4,17)
%         end
%     end
    hold on
    plot(PinnerX, PinnerY, 'Color', getColour(1))
    plot(PouterXvec1, PouterYvec1, 'Color', getColour(2))
    plot(PouterXvec2, PouterYvec2, 'Color', getColour(3))
    plot(PouterXvec3, PouterYvec3, 'Color', getColour(4))
    plot(Xbisetor, Ybisetor, '-or')
    set(gca,'DataAspectRatio',[1 1 1]) % to get image to scale
    XplotMin = -10; %floor(PinnerX(1)/5)*5; * Changed for a more focused graph
    XplotMax = ceil(max(PinnerX)/5+1)*5;
    YplotMin = floor(min(PouterY)/5)*5;
    YplotMax = YplotMin + (XplotMax - XplotMin);
    axis([XplotMin XplotMax YplotMin YplotMax])
    %     axis square          %so picture is to scale
    xlabel('X [m]')
    ylabel('Y [m]')
    text(XplotMin + (XplotMax - XplotMin)*.3, YplotMin + (YplotMax - YplotMin)*.45,['max SPW = ' num2str(ceil(SPWmax*10)/10,'%5.1f') ' m'])
    legTitles = {'inner path'; 'outer p1'; 'outer p2'; 'outer p3'; 'maximum width'};
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    set(gca,'box','on')
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, [plotTitle ladentext])
    end
    
    title([plotTitle ladentext])
    hold off
end
%pause