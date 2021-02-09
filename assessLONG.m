%% Function Description
%
% Computes the longitudinal performance of a vehicle combination according
% to PBS standards does not include the variation of drive axle vertical
% load with hitch height

%% Change Log
%% [0.2.0] - 2020-02-09
% * Removed standalone operation capability
%% [0.1.0] - 2018-08-08
% * First code
function [START, GRADA, GRADB, ACC] = assessLONG(Combination, Engine, Tyre, Axle, Project, Is,...
    mTotal,Axle1,Axle2, radial,Engine2)
% START: grade; sat = 0 if tyres not saturated and 1 if yes & 2 if over 30%
% GRADA: grade; sat = 0 if tyres not saturated and 1 if yes & 2 if over 30%
% GRADB: speed; sat = 0 if tyres not saturated and 1 if yes & 2 if over 120
% GRADB: gear
% ACC: time to 100; startGear; endGear v(i)*3.6;
% Planned improvements
% Use ode45 rather than use cumtrapz

if isfield(Combination,'engine2Model')
    [Engine2] = getEngineData2(Combination);
    isEngine2 = 1;
    Axle.Driven2 = Engine2.Driven2;
else
    isEngine2 = 0;
end
%-------------------------------------------------
%% *** Startability ***
%-------------------------------------------------

% Assume the engine starts in first gear and calculate the overall gear ratio
G = Engine.difStart * Engine.gearsStart(1);

% Total combination GCM
m = sum(mTotal);

% Calculating the rotational inertia due to the engine and tyres
totalInertia = Engine.It + Engine.Ie * G^2;

% Calculating the effective mass
me = m + totalInertia / Tyre.RollingRadius^2;

% Calculating the force of the engine at the wheels
Fengine = (Engine.engageTNm * Engine.eff_diffStart * Engine.eff_gearStart(1) * G)...
    /Tyre.RollingRadius;
if isEngine2
    Fengine2 = Engine2.TorqueNm(1)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
    Fengine2 = min(Fengine2,Fengine*Engine2.limit);
end
% Calculate the rolling resistance force
Frr = rolling(0, sum(mTotal), Combination.ch, radial);

% Initialise the variables for the loop
grad = [0:0.1:30];
contin = 1;
i = 0;

while contin
    i = i + 1;
    
    th = atan(grad(i)/100);
    
    % ** Check propulsion forces **
    %-------------------------------------------------
    FtotalResist = sin(th)*m*9.81+Frr;
    if isEngine2
        Favail = sum(0.8*9.81*Axle2(Axle.Driven));
        Favail2 = sum(0.8*9.81*Axle2(Axle.Driven2));
        acc(i) = (min([Fengine Favail])+min([Fengine2 Favail2])-FtotalResist) / me;
        % ** Check limiting criterion **
        %-------------------------------------------------
        if FtotalResist>(Fengine+min([Fengine2 Favail2]))
            % The engine force is not big enough to overcome the total resistance
            contin=0;
            saturate=0;
        elseif FtotalResist>(Favail+min([Fengine2 Favail2]))
            % The available force from the tyres is not big enough to overcome the total resistance
            contin=0;
            saturate=1;
        elseif i==length(grad)
            % There is plenty of engine and available tyre force
            contin=0;
            saturate=2;
        end
    else
        Favail = sum(0.8*9.81*Axle2(Axle.Driven));
        acc(i) = (min([Fengine Favail])-sin(th)*m*9.81-Frr) / me;
        % ** Check limiting criterion **
        %-------------------------------------------------
        if FtotalResist>Fengine
            % The engine force is not big enough to overcome the total resistance
            contin=0;
            saturate=0;
        elseif FtotalResist>Favail
            % The available force from the tyres is not big enough to overcome the total resistance
            contin=0;
            saturate=1;
        elseif i==length(grad)
            % There is plenty of engine and available tyre force
            contin=0;
            saturate=2;
        end
    end
end

% ** Store startability **
%-------------------------------------------------
START = [grad(i-1)];

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
    if (isfield(Is,'plotBackground') & Is.plotBackground)
        figure('name', 'START','visible', 'off');
    else
        figure('name', 'START');
    end
    hold on
    plot(grad(1:i),acc(1:i))
    plot([0 floor(START)],[0 0],'r:')
    
    if saturate==0
        text(0.8*floor(START),0.6*max(acc),['START = ' num2str(floor(START)) '%']);
        text(0.6*floor(START),0.8*max(acc),'Limited by torque');
        plot([floor(START) floor(START)],[min(acc(1:i)) max(acc(1:i))],'r:');
    elseif saturate==1
        text(0.8*floor(START),0.6*max(acc),['START = ' num2str(floor(START)) '%']);
        text(0.6*floor(START),0.8*max(acc),'Tyres saturated');
        plot([floor(START) floor(START)],[min(acc(1:i)) max(acc(1:i))],'r:')
    else
        text(0.8*floor(START),0.6*max(acc),['START >' num2str(floor(max(grad))) '%'])
        START=[floor(max(grad))];
    end
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('Gradient [%]')
    ylabel('Acceleration [m/s^2]')
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'START')
    end
    
    title('Startability')
    hold off
end

%-------------------------------------------------
%% *** Gradeability A ***
%-------------------------------------------------
clear acc
[maxTorqueNm j]=max(Engine.TorqueNm);
Fengine=maxTorqueNm*Engine.eff_gear(1)*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart*Engine.gears(1);
if isEngine2
    Fengine2 = Engine2.TorqueNm(1)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
    Fengine2 = min(Fengine2,Fengine*Engine2.limit);
end
N=Engine.Torquerpm(j);
v=N*Tyre.RollingRadius/G/60*2*pi;
FA=drag(Combination.frontalAreaForDrag,Combination.cd,v,Combination.ce);
grad=[0:0.1:30];
contin=1;
i=0;
Frr=rolling(v,sum(mTotal),Combination.ch,radial);
while contin
    i=i+1;
    th=atan(grad(i)/100);
    FtotalResist=sin(th)*m*9.81+Frr+FA;
    if isEngine2
        Favail = sum(0.8*9.81*Axle2(Axle.Driven));
        Favail2 = sum(0.8*9.81*Axle2(Axle.Driven2));
        acc(i) = (min([Fengine Favail])+min([Fengine2 Favail2])-FtotalResist) / me;
        % ** Check limiting criterion **
        %-------------------------------------------------
        if FtotalResist>(Fengine+min([Fengine2 Favail2]))
            % The engine force is not big enough to overcome the total resistance
            contin=0;
            saturate=0;
        elseif FtotalResist>(Favail+min([Fengine2 Favail2]))
            % The available force from the tyres is not big enough to overcome the total resistance
            contin=0;
            saturate=1;
        elseif i==length(grad)
            % There is plenty of engine and available tyre force
            contin=0;
            saturate=2;
        end
    else
        Favail=sum(0.8*9.81*Axle2(Axle.Driven));
        acc(i)=(min([Fengine Favail])-FtotalResist)/me;
        if FtotalResist>Fengine
            contin=0; % The engine force is not big enough to overcome the total resistance
            saturate=0;
        elseif FtotalResist>Favail
            contin=0; % The available force from the tyres is not big enough to overcome the total resistance
            saturate=1;
        elseif i==length(grad)
            contin=0; % There is plenty of engine and available tyre force
            saturate=2;
        end
    end
end

% ** Store gradeability A **
%-------------------------------------------------
GRADA=[grad(i-1)];

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
    figure('name', 'GRAa','visible', 'off');
  else
    figure('name', 'GRAa');
  end
    hold on
    plot(grad(1:i),acc(1:i))
    plot([0 floor(GRADA)],[0 0],'r:')
    if saturate==0
        text(0.8*floor(GRADA),0.6*max(acc),['GRADA = ' num2str(floor(GRADA)) '%']);
        text(0.6*floor(GRADA),0.8*max(acc),'Limited by torque');
        plot([floor(GRADA) floor(GRADA)],[min(acc(1:i)) max(acc(1:i))],'r:');
    elseif saturate==1
        text(0.8*floor(GRADA),0.6*max(acc),['GRADA = ' num2str(floor(GRADA)) '%']);
        text(0.6*floor(GRADA),0.8*max(acc),'Tyres saturated');
        plot([floor(GRADA) floor(GRADA)],[min(acc(1:i)) max(acc(1:i))],'r:')
    else
        text(0.8*floor(GRADA),0.6*max(acc),['GRADA >' num2str(floor(max(grad))) '%'])
        GRADA=[floor(max(grad))];
    end
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('Gradient [%]')
    ylabel('Acceleration [m/s^2]')
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'GRADA')
    end
    
    title('Gradability A')
    hold off
end

%-------------------------------------------------
%% *** Gradeability B ***
%-------------------------------------------------
clear acc;
vel=[40:0.1:120]; % speeds in km/h
contin=1;
i=0;
while contin
    if isEngine2
        i=i+1;
        grad=1;
        th=atan(grad/100);
        v=vel(i)/3.6; % convert speed to m/s metric units
        Frr=rolling(v,sum(mTotal),Combination.ch,radial);
        FA=drag(Combination.frontalAreaForDrag,Combination.cd,v,Combination.ce);
        Favail=sum(0.8*9.81*Axle1(Axle.Driven));
        Favail2 = sum(0.8*9.81*Axle2(Axle.Driven2));
        FtotalResist=sin(th)*m*9.81+Frr+FA;
        Nvec=v/Tyre.RollingRadius*Engine.gears*Engine.difStart*60/2/pi;
        G=Engine.difStart*Engine.gears;
        me=m+Engine.It/Tyre.RollingRadius/Tyre.RollingRadius+Engine.Ie*G.^2/Tyre.RollingRadius/Tyre.RollingRadius;
        Fengine=interp1(Engine.Torquerpm,Engine.TorqueNm,Nvec,'linear',0)*Engine.eff_diff/Tyre.RollingRadius*Engine.dif.*Engine.gears.*Engine.eff_gear;
        [Fengine jgear]=max(Fengine);
        me = me(jgear);
        gearvec(i)=jgear;
        Fengine2 = interp1(Engine2.Torquerpm,Engine2.TorqueNm,v/Tyre.RollingRadius*Engine2.gearing*Engine2.tyre_gearing*60/2/pi,'linear',0)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
        Fengine2 = min(Fengine2,Fengine*Engine2.limit);
        acc(i) = (min([Fengine Favail])+min([Fengine2 Favail2])-FtotalResist) / me;
        G=Engine.difStart*Engine.gears(jgear);
        N=v/Tyre.RollingRadius*G*60/2/pi;
        if FtotalResist>(Fengine+min([Fengine2 Favail2]))
            % The engine force is not big enough to overcome the total resistance
            contin=0;
            saturate=0;
        elseif FtotalResist>(Favail+min([Fengine2 Favail2]))
            % The available force from the tyres is not big enough to overcome the total resistance
            contin=0;
            saturate=1;
        elseif i==length(vel)
            % There is plenty of engine and available tyre force
            contin=0;
            saturate=2;
        end
    else
        i=i+1;
        grad=1;
        th=atan(grad/100);
        v=vel(i)/3.6; % convert speed to m/s metric units
        Frr=rolling(v,sum(mTotal),Combination.ch,radial);
        FA=drag(Combination.frontalAreaForDrag,Combination.cd,v,Combination.ce);
        Favail=sum(0.8*9.81*Axle1(Axle.Driven));
        FtotalResist=sin(th)*m*9.81+Frr+FA;
        Nvec=v/Tyre.RollingRadius*Engine.gears*Engine.difStart*60/2/pi;
        G=Engine.difStart*Engine.gears;
        me=m+Engine.It/Tyre.RollingRadius/Tyre.RollingRadius+Engine.Ie*G.^2/Tyre.RollingRadius/Tyre.RollingRadius;
        Fengine=interp1(Engine.Torquerpm,Engine.TorqueNm,Nvec,'linear',0)*Engine.eff_diff/Tyre.RollingRadius*Engine.dif.*Engine.gears.*Engine.eff_gear;
        [acc(i) jgear]=max((Fengine-sin(th)*m*9.81-Frr-FA)./me);
        gearvec(i)=jgear;
        Fengine=Fengine(jgear);
        G=Engine.difStart*Engine.gears(jgear);
        N=v/Tyre.RollingRadius*G*60/2/pi;
        if FtotalResist>Fengine;
            contin=0; % The engine force is not big enough to overcome the total resistance
            saturate=0;
        elseif FtotalResist>Favail
            contin=0; % The available force from the tyres is not big enough to overcome the total resistance
            saturate=1;
        elseif i==length(vel)
            contin=0; % There is plenty of engine and available tyre force
            saturate=2;
        end
    end
end

% ** Store gradeability B **
%-------------------------------------------------
GRADB=vel(i-1);

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'GRAb','visible', 'off');
  else
      figure('name', 'GRAb');
  end
    hold on
    plot(vel(1:i),acc(1:i)*10.0,vel(1:i),gearvec(1:i))
    xlabel('Velocity [km/h]')
    ylabel('Acceleration x 10 [m/s^2] ; gear')
    legTitles = {'acceleration'; 'gear'};
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    if saturate==0
        text(0.8*floor(GRADB),0.6*max(acc*10.0),['GRADB = ' num2str(floor(GRADB)) ' km/h']);
        text(0.6*floor(GRADB),0.8*max(acc*10.0),'Limited by torque');
        h_limit = plot([floor(GRADB) floor(GRADB)],[0 max(gearvec)],'r:');
    elseif saturate==1
        text(0.8*floor(GRADB),0.6*max(acc*10.0),['GRADB = ' num2str(floor(GRADB)) ' km/h']);
        text(0.6*floor(GRADB),0.8*max(acc*10.0),'Tyres saturated');
        h_limit = plot([floor(GRADB) floor(GRADB)],[0 max(gearvec)],'r:');
    else
        text(0.8*floor(GRADB)-8,0.6*max(acc*10.0),['GRADB >' num2str(floor(max(vel))) ' km/h'])
        GRADB=floor(max(vel));
    end
    set(get(get(h_limit,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'GRADB')
    end
    
    title('Gradability B')
    hold off
end


%-------------------------------------------------
%% *** Acceleration Capability ***
%-------------------------------------------------

%Determine start gear
Fengine=Engine.engageTNm*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart.*Engine.gears.*Engine.eff_gear;
Frr=rolling(0,sum(mTotal),Combination.ch,radial);
maxFthrust=sum(0.8*9.81*Axle1(Axle.Driven))-sin(0)*sum(mTotal)*9.81-Frr;
%startGear=find(Fengine<maxFthrust,1,'first');
startGear=2;
Fengine = Engine.engageTNm*Engine.eff_gear(startGear)*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart*Engine.gears(startGear);
if isEngine2
    Fengine2 = Engine2.TorqueNm(1)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
    Fengine2 = min(Fengine2,Fengine*Engine2.limit);
    Fdrive = Fengine + Fengine2;
else
    Fdrive = Fengine;
end
%1 Start gear and release clutch
% Allow a linear increase up to engageTNm in 1 s
%"The slip time of a friction clutch, for example, is normally
%less than 1 sec." 700194 Commercial Vehicle Performance and Fuel Economy
tspan=[0:0.01:1];
dt=tspan(2);
v2=0;
v(1)=0;
gearvec(1)=startGear;
G=Engine.gears(startGear)*Engine.difStart;

for i=1:(length(tspan)-1); %-1 for extra i+1
    t2=tspan(i);
    dvdt=veh_start1(t2,v2,Fdrive,Tyre.RollingRadius,G,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=startGear;
    if isEngine2
        Fengine2 = interp1(Engine2.Torquerpm,Engine2.TorqueNm,v(end)/Tyre.RollingRadius*Engine2.gearing*Engine2.tyre_gearing*60/2/pi,'linear',0)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
        Fengine2 = min(Fengine2,Fengine*Engine2.limit);
        Fdrive = Fengine + Fengine2;
    end
end

%2 Get to engageTrpm
% If N>=engageTrpm then move to 3, else keep Torque = engageTNm
N=v(end)/Tyre.RollingRadius*G*60/2/pi;
while N<Engine.engageTrpm,
    i=i+1;
    tspan(i)=tspan(i-1)+dt;
    t2=tspan(i);
    dvdt=veh_start2(t2,v2,Fdrive,Tyre.RollingRadius,Engine.gears(startGear)*Engine.difStart,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=startGear;
    N=v(end)/Tyre.RollingRadius*G*60/2/pi;
    if isEngine2
        Fengine2 = interp1(Engine2.Torquerpm,Engine2.TorqueNm,v(end)/Tyre.RollingRadius*Engine2.gearing*Engine2.tyre_gearing*60/2/pi,'linear',0)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
        Fengine2 = min(Fengine2,Fengine*Engine2.limit);
        Fdrive = Fengine + Fengine2;
    end
end
tspan(i+1)=tspan(i)+dt;

%3 Get to full torque
% If Torque>=engageTNm then move to 4, else take 1 s to allow Torque to
% increase to full value
for j=1:100
    i=i+1;
    FengineA=interp1(Engine.Torquerpm,Engine.TorqueNm,N,'linear',0)*Engine.eff_gear(startGear)*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart*Engine.gears(startGear);
    FengineB=Engine.engageTNm*Engine.eff_gear(startGear)*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart*Engine.gears(startGear);
    Fengine=FengineA*j/100+FengineB*(100-j)/100;
    if isEngine2
        Fengine2 = interp1(Engine2.Torquerpm,Engine2.TorqueNm,v(end)/Tyre.RollingRadius*Engine2.gearing*Engine2.tyre_gearing*60/2/pi,'linear',0)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
        Fengine2 = min(Fengine2,Fengine*Engine2.limit);
        Fdrive = Fengine + Fengine2;
    end
    tspan(i)=tspan(end)+0.01;
    dvdt=veh_start2(t2,v2,Fdrive,Tyre.RollingRadius,G,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
    v(i+1)=v(i)+dvdt*dt;
    N=v(end)/Tyre.RollingRadius*G*60/2/pi;
    gearvec(i+1)=startGear;
end
tspan(i+1)=tspan(i)+dt;

%4 Alter Fdrive with speed of engine accelerate until N matches changeT
%  If yes Gear changes to next and integrate for 1 s with Fdrive=0
Gear=startGear;
changephase=0;
Tchange=0;
while t2<40,
    i=i+1;
    tspan(i)=tspan(i-1)+dt;
    t2=tspan(i);
    if changephase==0 %Assume not in gear change mode
        if (N>Engine.changeT)&Gear<length(Engine.gears), %Change gears
            changephase=1;
            if Engine.gearshiftregime==1,
                Gear=Gear+1;
            else
                if (Gear<length(Engine.gears)-1)
                    Gear=Gear+2;
                else
                    Gear=Gear+1;
                end
            end
            G=Engine.gears(Gear)*Engine.difStart;
            N=v(end)/Tyre.RollingRadius*G*60/2/pi;
            Fdrive=0;
            dvdt=veh_change(t2,v2,Fdrive,Tyre.RollingRadius,Engine.gears(startGear)*Engine.difStart,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
            Tchange=Tchange+dt;
        else
            Fdrive=interp1(Engine.Torquerpm,Engine.TorqueNm,N,'linear',0)*Engine.eff_gear(Gear)*Engine.eff_diffStart/Tyre.RollingRadius*Engine.difStart*Engine.gears(Gear);
            if isEngine2
                Fengine2 = interp1(Engine2.Torquerpm,Engine2.TorqueNm,v(end)/Tyre.RollingRadius*Engine2.gearing*Engine2.tyre_gearing*60/2/pi,'linear',0)*Engine2.eff_motor*Engine2.eff_gear*Engine2.gearing*Engine2.tyre_gearing/Tyre.RollingRadius;
                Fengine2 = min(Fengine2,Fengine*Engine2.limit);
                Fdrive = Fengine + Fengine2;
            end
            dvdt=veh_throttle(t2,v2,Fdrive,Tyre.RollingRadius,Engine.gears(startGear)*Engine.difStart,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
        end
    else
        Tchange=Tchange+dt;
        if Tchange>=1.5,
            Tchange=0;
            changephase=0;
            Fdrive=0;
            dvdt=veh_change(t2,v2,Fdrive,Tyre.RollingRadius,Engine.gears(startGear)*Engine.difStart,sum(mTotal),Engine.Ie,Engine.It,Combination.ch,radial,Combination.frontalAreaForDrag,Combination.cd,Combination.ce);
        end
    end
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=Gear;
    N=v(end)/Tyre.RollingRadius*G*60/2/pi;
end

v=v(1:end-1);
gearvec=gearvec(1:end-1);
s=cumtrapz(tspan,v);
i=find(s>100,1,'first');
endGear=gearvec(i);

% ** Store Acceleration capability **
%-------------------------------------------------
ACC=[tspan(i)];

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)      
    figure('name', 'ACC','visible', 'off');
  else
      figure('name', 'ACC');
  end
    hold on
    plot(tspan(1:i),v(1:i),tspan(1:i),gearvec(1:i))
    xlabel('Time [s]')
    ylabel('Velocity [m/s] ; gear')
    text(tspan(i)-5,2,['ACC = ' num2str(round(tspan(i)*10)/10) ' s'])
    legTitles = {'velocity'; 'gear';};
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'ACC')
    end
    
    title('Acceleration Capability')
    hold off
    
end

if nargin == 0
    disp('==============================');
    disp('LONG PBS Performance');
    disp('==============================');
    disp(['STA: ', num2str(START), ' m']);
    disp(['GRAa: ', num2str(GRADA), ' m']);
    disp(['GRAb: ', num2str(GRADB), ' m']);
    disp(['ACC: ', num2str(ACC), ' m']);
end

end

%ensure t is output every 0.01;
%[t,v]=ode45(@(t,v) veh_start(t,v,Fdrive,rr,gears(startGear)*dif,sum(mTotal),Ie,It,Ch,radial,A,Cd,Ce),tspan,0);
%function dydt = f(t,y)
%dydt = [y(2); -9.8];
%end
% --------------------------------------------------------------------------

%function [value,isterminal,direction] = events(t,y)
%% Locate the time when height passes through zero in a decreasing direction
%% and stop integration.
%value = y;     % detect height = 0
%isterminal = [1; 0];   % stop the integration
%direction = [-1; 0];  % negative direction
%end

%-------------------------------------------------
%% *** Calculate acceleration ***
%-------------------------------------------------
function vdot=veh_start1(t,v,Fdrive,rr,G,m,Ie,It,Ch,radial,A,Cd,Ce)

me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=(t*(Fdrive-rolling(v,m,Ch,radial))-drag(A,Cd,v,Ce))/me;

end

%-------------------------------------------------
%% *** Calculate acceleration 2 ***
%-------------------------------------------------
function vdot=veh_start2(t,v,Fdrive,rr,G,m,Ie,It,Ch,radial,A,Cd,Ce)

me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=((Fdrive-rolling(v,m,Ch,radial))-drag(A,Cd,v,Ce))/me;

end

%-------------------------------------------------
%% *** Calculate acceleration 3 ***
%-------------------------------------------------
function vdot=veh_throttle(t,v,Fdrive,rr,G,m,Ie,It,Ch,radial,A,Cd,Ce)

me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=((Fdrive-rolling(v,m,Ch,radial))-drag(A,Cd,v,Ce))/me;

end

%-------------------------------------------------
%% *** Calculate acceleration 4 ***
%-------------------------------------------------
function vdot=veh_change(t,v,Fdrive,rr,G,m,Ie,It,Ch,radial,A,Cd,Ce)

vdot=((Fdrive-rolling(v,m,Ch,radial))-drag(A,Cd,v,Ce))/m;

end

%-------------------------------------------------
%% *** Rolling resistance ***
% velocity in m/s
% mass in kg
% Ch dimensionless Ch = 1 good road, 1.2  fair road and 1.5 for poor road
% radial = 1 if radial tyre
%-------------------------------------------------
function [Frr] = rolling(v,m,Ch,radial)

if radial==1
    Frr=(0.0041 + 9.1715e-005*v)*m*9.81*Ch; % In Newtons page 13-7 Umtri notes
else
    Frr=(0.0066 + 1.0290e-004*v)*m*9.81*Ch; % In Newtons page 13-8 Umtri notes
end

end

%-------------------------------------------------
%% *** Drag resistance ***
% velocity in m/s
% A in m^2
%-------------------------------------------------
function [Fa] = drag(A,Cd,v,Ce)

Fa=0.5*1.1504*A*Cd*v^2*Ce; % In Newtons page 13-8 Umtri notes

end