%Changelogs
%Ver 1.0
%   -> First iteration
%Ver 2.0
%   -> Evalate Ay and not AyBf_SM. Change range to 0.19 to 0.21 g. 2016/11/04 FK

function [Dmin] = YawD_solve(nVehUnits, savePath, runsPath, runKey, matKey, plotOn, isSave)

if nargin == 0  % i.e. program run directly from here
    % Example inputs: 
    % -----------------------------------------------------------------
    nVehUnits = 6;
    savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20151209-Wits-PBS assess-Unitrans-AfritBABquad-Volvo FH86T6HT ver1';
    runsPath = 'C:\Users\Public\Documents\TruckSim_Data\Runs';
    runKey ='AfritBABquad-Volvo FH86T6HT';
    plotOn = true;
    
    % -----------------------------------------------------------------
end

[Data, errorx] = readData(matKey, {'Art_H' 'ArtR_H' 'AVz' 'Ay'}, [nVehUnits-1 nVehUnits-1 nVehUnits 1], {'' '' '_' ''}, [], savePath, runsPath, runKey, zeros(1,4), isSave);

if errorx == 1
    Time    = Data{1};      % convert to vector
    Art_H   = Data(2,:);    % This is still a cell array 
    ArtR_H  = Data(3,:);    % This is still a cell array
    AVz     = Data(4,:);    % This is still a cell array
    Ay      = Data{5};      % convert to vector
else
    return                  % data not loaded correctly
end

maxAy = max(Ay);

%Check to ensure that the lateral acceleration for the steer axle is within
%the correct levels.
if maxAy < 0.19
    error('%s%0.2f%s','Lateral acceleration is below 0.19 g: ', maxAy, ' g -->> Increase STEER_SW_GAIN manoeuvre not harsh enough'); %For this to work, the original definition of error had to be changed to errorx
elseif maxAy > 0.21
    error('%s%0.2f%s','Lateral acceleration is above 0.21 g: ', maxAy, ' g -->> Decrease STEER_SW_GAIN maoneouvre may be too harsh');    
end

A1threshold = 0.25;  % find A1 by looking for first peak with value higher than 1 
                  % - this is not very robust

if plotOn
    figure('name', 'YawD')

    hold on
    legTitles = {};

    for i = 1:nVehUnits
        plot(Time, AVz{i}, 'Color', getColour(i));   % plot next line
        legTitles = [legTitles; ['unit ' int2str(i)]];
    end
    
    xlabel('Time [sec]')
    ylabel('Yaw Rate [deg/s]')
    
    legend(legTitles, 'Location', 'NE');
end

for i = 1:nVehUnits
    Yloc = max(AVz{1})*(1 - i/(nVehUnits+1));
    D(i) = YD(AVz{i}, Time, A1threshold, i, Yloc, plotOn);
end

Dmin = min(D);

if plotOn
    text(3, max(AVz{1})*0.8,['D_m_i_n = ' num2str(floor(Dmin*100)/100)])
    
    temp=axis;
    axis([0 10 temp(3) temp(4)])
    %axis([0 10 floor(min(AVz{end})*2)/2 ceil(max(AVz{1})*2)/2])  %set axis
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'YawD')
    end
    
    title('Yaw Damping')
    hold off
end


function [DR] = YD(YR, Time, A1threshold, count, Yloc, plotOn)

iPeak = 1;
valPeakRaw(iPeak) = 0;
for i=1:(length(YR)-1)      %find peaks
    if (sign(YR(i))*sign(YR(i+1)) == -1 || sign(YR(i)) == 0)       %find sign change - avoids situation where we have an actual 0.00 and sign() returns 0
       iPeak = iPeak + 1;                           %next peak
       valPeakRaw(iPeak) = 0;                       %new start for peak value
    end
    if (abs(YR(i+1)) > abs(valPeakRaw(iPeak)))    %largest found so far
        tPeakRaw(iPeak) = Time(i+1);
        valPeakRaw(iPeak) = YR(i+1); 
    end
end


%clean up tPeaks & valPeaks

% [A1, iA1] = max(abs(valPeakRaw));  %note: may not be first peak if response is divergent - will still only get A's >5% and will be in order

% find A1 by looking for first peak with value higher than 0.4 - this is
% not very robust
iA1 = 1;
while (valPeakRaw(iA1) < A1threshold) && iA1 < numel(valPeakRaw)
    iA1 = iA1 + 1;
end

A1 = valPeakRaw(iA1);

iClean = 1;
for iRaw = 1:length(tPeakRaw)
    if (abs(valPeakRaw(iRaw)) >= 0.05*A1) && (iRaw >= iA1)     %PBS standard prescribes 5% cutoff
        valPeak(iClean) = valPeakRaw(iRaw);
        tPeak(iClean)   = tPeakRaw(iRaw);
        iClean = iClean + 1;
    end
end


%calc Abar
Abar = 0;

if length(valPeak) == 1
    DR = 1;
elseif length(valPeak) < 6                              %eqn C15 p.65
   for i=1:(length(valPeak)-1)
       Abar = Abar + abs(valPeak(i))/abs(valPeak(i+1));
   end
   Abar = Abar/i;
   DR = log(Abar)/sqrt((pi).^2 + log(Abar).^2);
else                                                %eqn C14 p.65
   for i=1:(length(valPeak)-2)
       Abar = Abar + abs(valPeak(i))/abs(valPeak(i+2));
   end
   Abar = Abar/i;
   DR = log(Abar)/sqrt((2*pi).^2 + log(Abar).^2);
end

if plotOn
    plot(tPeak, valPeak, '*r')
    text(0.2, Yloc,['D_' num2str(count) ' = ' num2str(floor(DR*100)/100)])
end


