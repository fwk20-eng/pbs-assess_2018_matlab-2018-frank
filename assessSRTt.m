function [SRTt, SRTtrrcu] = assessSRTt(Combination, Axle, Hitch,  Project, MatKey,...
  Is, Dummy, LIM_SRT, SRT_ROLL_THRESH, mSprung, HcgSprung)
nVehUnits = length(mSprung);
%-------------------------------------------------
%% *** Extract the data from the mat file ***
%-------------------------------------------------  
  [Data, error] = readSimulationVariables(...
    MatKey(1,:),...
    {'Roll' 'Ay' 'Fz_L' 'Roll_Tab'},...
    [nVehUnits nVehUnits Axle.NumberOff 1],...
    {'_' '_' '' ''},...
    [],...
    Project.savePath,...
    Project.truckSimRunsDirectory,...
    Project.runKey,...
    [0 0 1 0]);
%-------------------------------------------------
%% *** Calculate PBS SRT Performance ***
%-------------------------------------------------

[Time, AYrcu, SRTt, indiC, ind, SRTreason, SRTtrrcu] = ...
  assessSRTtWithSRTrrcu(Data, error, SRT_ROLL_THRESH, nVehUnits, Axle, Hitch, Combination,...
  mSprung, HcgSprung);

%-------------------------------------------------
%% *** Recalculate SRTrrcu performance if a second script with stabilising mass was run ***
%-------------------------------------------------

if Is.srtRrcu
  
  clear SRTtrrcu; % ignore the original SRTrrcu calculated without a stabilising mass
  
  %% Running again with the rearmost roll coupled unit matlab file
    
    [Data, error] = readSimulationVariables(...
      MatKey(2,:),...
      {'Roll' 'Ay' 'Fz_L' 'Roll_Tab'},...
      [nVehUnits nVehUnits Axle.NumberOff 1],...
      {'_' '_' '' ''},...
      [],...
      Project.savePath,...
      Project.truckSimRunsDirectory,...
      Project.runKey,...
      [0 0 1 0]);
  
  [Time_rrcu, AYrcu_rrcu, ~, ~, ind_rrcu, ~, SRTtrrcu] = assessSRTtWithSRTrrcu(Data, error, SRT_ROLL_THRESH, ...
    nVehUnits, Axle, Hitch, Combination,...
    mSprung, HcgSprung);
  
end

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'SRT','visible', 'off');
  else
      figure('name', 'SRT');
  end  
  hold on
  legTitles = {};
  
  % ** Plot the lateral acceleration for all of the roll-coupled units **
  % if rrcu is run, then rrcu must be plotted with the data that was extracted in the rrcu script
  %-------------------------------------------------
  
  if Is.srtRrcu & MatKey{1,2}~=MatKey{2,2}
    %-------------------------------------------------
    %% *** Plot for if a second rrcu SRT manoeuvre was run ***
    %-------------------------------------------------
    
    % ** Plot all units before the rrcu with the original manoeuvre data **
    %-------------------------------------------------
    
    xMax = max(ceil(Time(max(ind))), ceil(Time_rrcu(max(ind_rrcu))));
    yMax = max(SRTt, SRTtrrcu);
    
    axis([floor(Time(min(ind))/2) xMax 0 ceil((yMax+0.01)*10)/10])  %set axis
    
    for i = 1:(length(AYrcu) - 1)
      
      plot(Time(1:ind(i)), AYrcu{i}(1:ind(i)), 'Color', getColour(i));
      legTitles = [legTitles; ['roll-coupled unit ' int2str(i)]];
      
    end
    
    % ** Plot the rrcu with the rrcu data **
    %-------------------------------------------------
    iRrcu = length(AYrcu); % rearmost roll-coupled unit
    plot(Time_rrcu(1:ind_rrcu(iRrcu)), AYrcu_rrcu{i}(1:ind_rrcu(iRrcu)), 'Color', getColour(iRrcu));
    legTitles = [legTitles; ['roll-coupled unit ' int2str(iRrcu)]];

    
    PBSlimX = [0 Time_rrcu(end)];
    PBSlimY = [SRTtrrcu SRTtrrcu];
    plot(PBSlimX, PBSlimY, '--y')
    legTitles = [legTitles; 'SRTrrcu achieved'];
    
    text([floor(Time(min(ind))/2)+1], 0.02 + 0.03,...
      ['SRTrrcu = ' num2str(floor(SRTtrrcu*100)/100) ' g'])
    
    text([floor(Time(min(ind))/2)+1], 0.02 + 0.06,...
      ['SRT = ' num2str(floor(SRTt*100)/100) ' g'])
    
  else
    %-------------------------------------------------
    %% *** Plot for if a single SRT manoeuvre was run ***
    %-------------------------------------------------
    
    axis([floor(Time(min(ind))/2) ceil(Time(max(ind))) 0 ceil((SRTt+0.01)*10)/10])  %set axis
    
    for i = 1:length(AYrcu)
      
      plot(Time(1:ind(i)), AYrcu{i}(1:ind(i)), 'Color', getColour(i));
      legTitles = [legTitles; ['roll-coupled unit ' int2str(i)]];
      
    end
    
    PBSlimX = [0 Time(end)];
    
    text([floor(Time(min(ind))/2)+1], 0.02 + 0.06,...
      ['SRT = ' num2str(floor(SRTt*100)/100) ' g'])
    
  end
  
  %-------------------------------------------------
  %% *** Continue the plot ***
  %-------------------------------------------------
  
  PBSlimY = [LIM_SRT LIM_SRT];
  plot(PBSlimX, PBSlimY, '--r')
  legTitles = [legTitles; 'min requirement'];
  
  PBSlimY = [SRTt SRTt];
  plot(PBSlimX, PBSlimY, '--k')
  legTitles = [legTitles; 'SRT achieved'];
  
  xlabel('Time [s]')
  ylabel('Lateral Acceleration [g]')
  
  % ** Write the limiting reason for the SRT performance **
  %-------------------------------------------------
  if (SRTreason(indiC)==1)
    
    text([floor(Time(min(ind))/2) + 1], 0.02,...
      ['SRT when threshold roll angle reached']);
    
  elseif (SRTreason(indiC)==2)
    
    text([floor(Time(min(ind))/2) + 1], 0.02,...
      ['SRT when all tyres (excluding steer) of roll-coupled unit in the air']);
    
  else
    
    text([floor(Time(min(ind))/2) + 1], 0.02,...
      ['SRT when lateral acceleration decreases with roll angle']);
    
  end
  
  legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
  
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');
  
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'SRTt_time')
  end
  
  title('Static Rollover Threshold')
  hold off
end

end
