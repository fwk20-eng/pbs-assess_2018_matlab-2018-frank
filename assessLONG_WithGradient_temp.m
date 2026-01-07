%% Function Description
%
% Computes the longitudinal performance of a vehicle combination according
% to PBS standards includes the variation of drive axle vertical
% load with hitch height
%% Change Log
%% [0.1.0] - 2020-02-09
% * First code
function [START, GRADA, GRADB, ACC] = assessLONG_WithGradient(mTotal,A,radial,ch,cd,ce,gears,eff_gear,gearsStart,eff_gearStart,eff_diff,dif,eff_diffStart,difStart,Torquerpm,TorqueNm,engageTrpm,engageTNm,changeT,rr,Ie,It,Ndrive,gearshiftregime,savePath, runKey, plotOn, isSave,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadshare2,loadCoupled,Is);
% START: grade; sat = 0 if tyres not saturated and 1 if yes & 2 if over 30%
% GRADA: grade; sat = 0 if tyres not saturated and 1 if yes & 2 if over 30%
% GRADB: speed; sat = 0 if tyres not saturated and 1 if yes & 2 if over 120
% GRADB: gear
% ACC: time to 100; startGear; endGear v(i)*3.6;
% Planned improvements
% Use ode45 rather than use cumtrapz

%%
%Startability
G = difStart*gearsStart(1); %Assume start in first

m = sum(mTotal);
me = m + It/rr^2 + Ie*G^2/rr^2;

grad = [0:0.1:30];
contin = 1;
i = 0;

while contin
    i=i+1;
    th=atan(grad(i)/100);
    
    Axle = computeAxleLoadWithGradient(grad(i),mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled);
    
    FrrD = rolling(0,sum(Axle(Ndrive)),ch,radial); % Rolling resistance at 0 velocity
    FrrN = rolling(0,(sum(mTotal) - sum(Axle(Ndrive))),ch,radial);
    Frr = FrrD + FrrN;
    
    Fengine = (engageTNm*eff_diffStart*eff_gearStart(1)*G/rr) - FrrD;
    Favail=sum(0.8*9.81*Axle(Ndrive)); % Add the gradient to this
    Freq = sin(th)*m*9.81 + FrrN;
    Ftractive = min([Fengine Favail]);
    
    if Favail == Ftractive
        acc(i) = (Ftractive - Freq - Frr)/me; % Need to consider the total rolling resistance
    else if Fengine == Ftractive
            acc(i) = (Ftractive - Freq - FrrN)/me; % Need to consider only the non-driven rolling resistance as the driven rolling resistance is included in the Fengine term
        end
    end
    
    if Freq > Fengine;
        contin = 0; % The engine force is not big enough to generate the required drive
        saturate = 0;
    elseif Freq > Favail
        contin = 0; % The available force from the tyres is not big enough to generate the required drive
        saturate = 1;
    elseif i == length(grad)
        contin = 0; % There is plenty of engine and available tyre force
        saturate = 2;
    end
    
end

START=[grad(i-1)];

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
    
    if isSave
        savePlot(savePath, runKey, 'START')
    end
    
    title('Startability')
    hold off
end

%%
%Gradability A
[maxTorqueNm j]=max(TorqueNm);

N=Torquerpm(j);
v=N*rr/G/60*2*pi;
FA=drag(A,cd,v,ce);
grad=[0:0.1:30];
contin=1;
i=0;

while contin
    i=i+1;
    th=atan(grad(i)/100);
    
    Axle = computeAxleLoadWithGradient(grad(i),mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled);
    
    FrrD = rolling(v,sum(Axle(Ndrive)),ch,radial); % Rolling resistance at 0 velocity
    FrrN = rolling(v,(sum(mTotal) - sum(Axle(Ndrive))),ch,radial);
    Frr = FrrD + FrrN;
    
    Fengine = (maxTorqueNm*eff_gear(1)*eff_diffStart/rr*difStart*gears(1)) - FrrD;
    Favail = sum(0.8*9.81*Axle(Ndrive));
    Freq = sin(th)*m*9.81 + FrrN + FA;
    Ftractive = min([Fengine Favail]);
    
    if Favail == Ftractive
        acc(i) = (Ftractive - Freq - Frr)/me; % Need to consider the total rolling resistance
    else if Fengine == Ftractive
            acc(i) = (Ftractive - Freq - FrrN)/me; % Need to consider only the non-driven rolling resistance as the driven rolling resistance is included in the Fengine term
        end
    end
    
    
    if Freq>Fengine
        contin=0; % The engine force is not big enough to generate the required drive
        saturate=0;
    elseif Freq>Favail
        contin=0; % The available force from the tyres is not big enough to generate the required drive
        saturate=1;
    elseif i==length(grad)
        contin=0; % There is plenty of engine and available tyre force
        saturate=2;
    end
end
GRADA=[grad(i-1)];

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
    
    if isSave
        savePlot(savePath, runKey, 'GRADA')
    end
    
    title('Gradability A')
    hold off
end
%%
%Gradability B
vel=[40:0.1:120]; % speeds in km/h
contin=1;
i=0;

grad=1;
th=atan(grad/100);
Axle = computeAxleLoadWithGradient(grad,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled);

while contin
    i=i+1;
    v=vel(i)/3.6; % convert speed to m/s metric units
    
    FrrD = rolling(v,sum(Axle(Ndrive)),ch,radial); % Rolling resistance at 0 velocity
    FrrN = rolling(v,(sum(mTotal) - sum(Axle(Ndrive))),ch,radial);
    Frr = FrrD + FrrN;
    
    FA = drag(A,cd,v,ce);
    
    Favail = sum(0.8*9.81*Axle(Ndrive));
    Freq = sin(th)*m*9.81 + FrrN + FA;
    
    Nvec=v/rr*gears*difStart*60/2/pi;
    G=difStart*gears;
    me=m+It/rr/rr+Ie*G.^2/rr/rr;
    
    Fengine = (interp1(Torquerpm,TorqueNm,Nvec,'linear',0)*eff_diffStart/rr*difStart.*gears.*eff_gear) - FrrD;
    
    [acc(i) jgear]=max((Fengine-sin(th)*m*9.81-FrrN-FA)./me);
    
    gearvec(i)=jgear;
    Fengine=Fengine(jgear);
    G=difStart*gears(jgear);
    N=v/rr*G*60/2/pi;
    if Freq>Fengine;
        contin=0; % The engine force is not big enough to generate the required drive
        saturate=0;
    elseif Freq>Favail
        contin=0; % The available force from the tyres is not big enough to generate the required drive
        saturate=1;
    elseif i==length(vel)
        contin=0; % There is plenty of engine and available tyre force
        saturate=2;
    end
end

GRADB=vel(i-1);

if Is.plotOn
    if (isfield(Is,'plotBackground') & Is.plotBackground)
        figure('name', 'GRAb','visible', 'off');
    else
        figure('name', 'GRAb');
    end
    
    hold on
    plot(vel(1:i),acc(1:i)*10.0,vel(1:i),gearvec(1:i));
    if saturate==0
        text(0.8*floor(GRADB),0.6*max(acc*10.0),['GRADB = ' num2str(floor(GRADB)) ' km/h']);
        text(0.6*floor(GRADB),0.8*max(acc*10.0),'Limited by torque');
        plot([floor(GRADB) floor(GRADB)],[0 max(gearvec)],'r:');
    elseif saturate==1
        text(0.8*floor(GRADB),0.6*max(acc*10.0),['GRADB = ' num2str(floor(GRADB)) ' km/h']);
        text(0.6*floor(GRADB),0.8*max(acc*10.0),'Tyres saturated');
        plot([floor(GRADB) floor(GRADB)],[0 max(gearvec)],'r:')
    else
        text(0.8*floor(GRADB)-8,0.6*max(acc*10.0),['GRADB >' num2str(floor(max(vel))) ' km/h'])
        GRADB=floor(max(vel));
    end
    xlabel('Velocity [km/h]')
    ylabel('Acceleration x 10 [m/s^2] ; gear')
    legTitles = {'acceleration'; 'gear'; 'GRADB'};
    legend(legTitles, 'Location', 'Best');
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'GRADB')
    end
    
    title('Gradability B')
    hold off
end

%%
%Acceleration Capability
% Axle loads
Axle = computeAxleLoadWithGradient(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled);
%Determine start gear

FrrD = rolling(0,sum(Axle(Ndrive)),ch,radial); %Rolling resistance at 0 velocity
FrrN = rolling(0,(sum(mTotal) - sum(Axle(Ndrive))),ch,radial);
Frr = FrrD + FrrN;
Fengine = engageTNm*eff_diffStart/rr*difStart.*gears.*eff_gear - FrrD;
maxFthrust = sum(0.8*9.81*Axle(Ndrive))-sin(0)*sum(mTotal)*9.81 - FrrN;
%startGear=find(Fengine<maxFthrust,1,'first');
startGear=2;
Freq = engageTNm*eff_gear(startGear)*eff_diffStart/rr*difStart*gears(startGear);
%
%1 Start gear and release clutch
% Allow a linear increase up to engageTNm in 1 s
tspan=[0:0.01:1];
dt=tspan(2);
v2=0;
v(1)=0;
gearvec(1)=startGear;
G=gears(startGear)*difStart;
for i=1:(length(tspan)-1); %-1 for extra i+1
    t2=tspan(i);
    dvdt=veh_start1(t2,v2,Freq,rr,G,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=startGear;
end
%
%2 Get to engageTrpm
% If N>=engageTrpm then move to 3, else keep Torque = engageTNm
N=v(end)/rr*G*60/2/pi;
while N<engageTrpm,
    i=i+1;
    tspan(i)=tspan(i-1)+dt;
    t2=tspan(i);
    dvdt=veh_start2(t2,v2,Freq,rr,gears(startGear)*difStart,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=startGear;
    N=v(end)/rr*G*60/2/pi;
end
tspan(i+1)=tspan(i)+dt;
%
%3 Get to full torque
% If Torque>=engageTNm then move to 4, else take 1 s to allow Torque to
% increase to full value
for j=1:100
    i=i+1;
    Freq1=interp1(Torquerpm,TorqueNm,N,'linear',0)*eff_gear(startGear)*eff_diffStart/rr*difStart*gears(startGear);
    Freq2=engageTNm*eff_gear(startGear)*eff_diffStart/rr*difStart*gears(startGear);
    Freq=Freq1*j/100+Freq2*(100-j)/100;
    tspan(i)=tspan(end)+0.01;
    dvdt=veh_start2(t2,v2,Freq,rr,G,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
    v(i+1)=v(i)+dvdt*dt;
    N=v(end)/rr*G*60/2/pi;
    gearvec(i+1)=startGear;
end
tspan(i+1)=tspan(i)+dt;
%
%4 Alter Freq with speed of engine accelerate until N matches changeT
%  If yes Gear changes to next and integrate for 1 s with Freq=0
Gear=startGear;
changephase=0;
Tchange=0;
while t2<40,
    i=i+1;
    tspan(i)=tspan(i-1)+dt;
    t2=tspan(i);
    if changephase==0 %Assume not in gear change mode
        if (N>changeT)&Gear<length(gears), %Change gears
            changephase=1;
            if gearshiftregime==1,
                Gear=Gear+1;
            else
                if (Gear<length(gears)-1)
                    Gear=Gear+2;
                else
                    Gear=Gear+1;
                end
            end
            G=gears(Gear)*difStart;
            N=v(end)/rr*G*60/2/pi;
            Freq=0;
            dvdt=veh_change(t2,v2,Freq,rr,gears(startGear)*difStart,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
            Tchange=Tchange+dt;
        else
            Freq=interp1(Torquerpm,TorqueNm,N,'linear',0)*eff_gear(Gear)*eff_diffStart/rr*difStart*gears(Gear);
            dvdt=veh_throttle(t2,v2,Freq,rr,gears(startGear)*difStart,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
        end
    else
        Tchange=Tchange+dt;
        if Tchange>=1.5,
            Tchange=0;
            changephase=0;
            Freq=0;
            dvdt=veh_change(t2,v2,Freq,rr,gears(startGear)*difStart,sum(mTotal),Ie,It,ch,radial,A,cd,ce);
        end
    end
    v(i+1)=v(i)+dvdt*dt;
    gearvec(i+1)=Gear;
    N=v(end)/rr*G*60/2/pi;
end
v=v(1:end-1);
gearvec=gearvec(1:end-1);
s=cumtrapz(tspan,v);
i=find(s>100,1,'first');
endGear=gearvec(i);

ACC=[tspan(i)];

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
    legend(legTitles, 'Location', 'NE');
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'ACC')
    end
    
    title('Acceleration Capability')
    hold off
    
end
end

%ensure t is output every 0.01;
%[t,v]=ode45(@(t,v) veh_start(t,v,Freq,rr,gears(startGear)*dif,sum(mTotal),Ie,It,ch,radial,A,cd,ce),tspan,0);
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

%%
function vdot=veh_start1(t,v,Freq,rr,G,m,Ie,It,ch,radial,A,cd,ce)
me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=(t*(Freq-rolling(v,m,ch,radial))-drag(A,cd,v,ce))/me;
end

function vdot=veh_start2(t,v,Freq,rr,G,m,Ie,It,ch,radial,A,cd,ce)
me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=((Freq-rolling(v,m,ch,radial))-drag(A,cd,v,ce))/me;
end

function vdot=veh_throttle(t,v,Freq,rr,G,m,Ie,It,ch,radial,A,cd,ce)
me=m+It/rr/rr+Ie*G^2/rr/rr;
vdot=((Freq-rolling(v,m,ch,radial))-drag(A,cd,v,ce))/me;
end

function vdot=veh_change(t,v,Freq,rr,G,m,Ie,It,ch,radial,A,cd,ce)
vdot=((Freq-rolling(v,m,ch,radial))-drag(A,cd,v,ce))/m;
end

function [Frr] = rolling(v,m,ch,radial);
% velocity in m/s
% mass in kg
% ch dimensionless ch = 1 good road, 1.2  fair road and 1.5 for poor road
% radial = 1 if radial tyre
if radial==1,
    Frr=(0.0041 + 9.1715e-005*v)*m*9.81*ch; % In Newtons page 13-7 Umtri notes
else
    Frr=(0.0066 + 1.0290e-004*v)*m*9.81*ch; % In Newtons page 13-8 Umtri notes
end
end

function [Fa] = drag(A,cd,v,ce);
% velocity in m/s
% A in m^2
Fa=0.5*1.1504*A*cd*v^2*ce; % In Newtons page 13-8 Umtri notes
end
