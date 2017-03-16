%% --------------------------------------------------------------------------------------
%	Change Log
%----------------------------------------------------------------------------------------
%%   2016-10-09
%   * Added isPrint
%       0: Will not plot or save results to excel
%       1: Will plot and save results to excel
%% 2016-11-01
%   *Added print summary for postprocess window
%   *Added radii of gyration to the output for ease of entering into
%   TruckSim
%%  2016-11-02
%   *Added h_bin as a variable to input
%   *Renamed h_off as x_hitch
%% 2016-12-07
%   Changed profile of the bin to the new one sent by SATB
function [m, hcog, xcogPayload] = binCoG_SATB50m3_v2(roh, m, x_hitch, h_bin, fileName, savePath, runKey, sheetName, isPrint, isSave)
% Function calculates the total height, COG height, and inertias of the
% load: htot (heap not included), hcog, Ixx, Iyy, Izz given the bucket profile, length and
% density of the load and mass. The bucket mass and inertias are also
% calculated: m1, Ixx1, Iyy1, Izz2
% The input parameters are roh=density; m=mass of load;x_hitch = distance
% to bin front from 5th wheel position (-ve forward and +ve back)
% Known error when bucket walls are flat and interpolation to find height
% has no solution
%close all
%clear
% Add input data here. Units mm and kg. roh=1000e-9 water. =833e-9 coal. 7810e-9 steel.
% The co-ordinates below are for the inside of the bucket


%% --------------------------------------------------------------------------------------
%	Old Afrit buckets
%----------------------------------------------------------------------------------------
% buc_w=[   1140    1406   2585];
% buc_h=[   0       190    1710];
% L=6332;

%% --------------------------------------------------------------------------------------
%	40 cubic metre Afrit bucket
%----------------------------------------------------------------------------------------
% buc_w = [   565     797    1129    1349    1646    1797    2030     2143    2448];
% buc_h = [   0       133     133     209     685     735     1078    1120    1568];
% L = 7000;

% %% --------------------------------------------------------------------------------------
% %	45 cubic metre Afrit bucket
% %----------------------------------------------------------------------------------------
% buc_w = [   566     794     1132    1347    1549    1682    1964    2069    2444];
% buc_h = [   0       133     133     212     539     627     1090    1136    1767];
% %h_max = buc_h(length(buc_h)) - 150; %Maximum payload load height (150 mm from the top of the bin)
% L = 7000; %[mm]
% 
% % Datums and factors
% f_anc = 1.8; %[-] Ancilliaries loading factor (to take into account the ancilliary equipment such as pistons, mechanicals etc)
% %h_bin = 1621-133; %[mm] Distance from the floor reference to the bottom of the bucket

% % --------------------------------------------------------------------------------------
% %	45 cubic metre SA Truck Bodies bucket
% %----------------------------------------------------------------------------------------
% buc_w = [1123    1352     1559    1788    1857    2017    2086    2269    2418];
% buc_h = [   0      92       92     195     435     481     802     871    1444];
% L = 7500;

%% --------------------------------------------------------------------------------------
%	50 cubic metre SA Truck Bodies bucket
%----------------------------------------------------------------------------------------
% buc_w = [   204     309     1125    1355    1565    1707    1786    1979    2081    2238    2453];
% buc_h = [   0       -45     -45     51      51      111     335     416     757     826     1545];
% L = 7500; %[mm]
% 
% % Datums and factors
% f_anc = 1.8; %[-] Ancilliaries loading factor (to take into account the ancilliary equipment such as pistons, mechanicals etc)

%% --------------------------------------------------------------------------------------
%	50 cubic metre SA Truck Bodies bucket with centre bent down
%----------------------------------------------------------------------------------------
buc_w = [   200     309     1125    1355    1565    1707    1786    1979    2081    2238    2453];
buc_h = [   0       45      45      142     142     201     425     506     847     916     1635];
L = 7500; %[mm]

% Datums and factors
f_anc = 1.8; %[-] Ancilliaries loading factor (to take into account the ancilliary equipment such as pistons, mechanicals etc)
%% --------------------------------------------------------------------------------------
%	Material Properties
%----------------------------------------------------------------------------------------
%roh = 1072e-9; %[kg/mm^-3] Carried material density (chromium)
%m = 25100-1709; %[kg] Load mass required
t = 3; %[mm] Plate thickness acc.to D718-28 SHEET 1 OF 2 21/06/16
roh1 = 7850e-9*f_anc; %[kg/mm^-3] Density of the bucket material - factored for equipment
bet = 0.1; %[deg] Angle of repose

%% --------------------------------------------------------------------------------------
%	Calculations & Plotting
%----------------------------------------------------------------------------------------
[htot, hcog, Ixx, Iyy, Izz, w] = inertia_calc(buc_w,buc_h,roh,m,L,bet); % Load - CoG heights relative to the bottom of the bin
% Estimate approximate bucket mass, cog, Ixx, Iyy and Izz
[hcog1, m1, Ixx1, Iyy1, Izz1] = inertia_calc1(buc_w,buc_h,roh1,t,L); % Bucket - CoG heights relative to the bottom of the bin

%% --------------------------------------------------------------------------------------
%	Combining Inertias for TruckSim
%----------------------------------------------------------------------------------------
vMass = [m m1]; %Mass of each inertial entity [kg]
vIxx = [Ixx Ixx1].*10^-6; %Roll inertia for each inertial entity [kg.m^2]
vIyy = [Iyy Iyy1].*10^-6; %Pitch inertia for each inertial entity [kg.m^2]
vIzz = [Izz Izz1].*10^-6;%; %Yaw inertia for each inertial entity [kg.m^2]
vCoGx = [L*0.5 L*0.5] + x_hitch; %x coordinate of CoG relative to steer axle (if on superstructure) or hitch point (if trailer load) [mm] including hitch offsets (x_hitch)
vCoGy = [0 0]; %y coordinate of CoG relative to centre of vehicle [mm]
vCoGz = [hcog hcog1] + h_bin + t; %z coordinate of CoG relative to the road surface [mm]

xcogPayload = vCoGx(1);
combinedInertias = combineInertias(vMass, vIxx, vIyy, vIzz, vCoGx, vCoGy, vCoGz);
%% --------------------------------------------------------------------------------------
%	Printing results to Excel
%----------------------------------------------------------------------------------------
if isPrint
    figure('name', 'BinCoG');
    axis equal
    hold on;
    plotbucketout(buc_w,buc_h);
    plotload(w,htot,bet);
    
    inputHeadings = {'Payload mass [kg]' 'Payload density [kg/m^3]' 'Loaded Volume [m^3]' 'Bin wall thickness [mm]' 'Bin density [kg/m^3]' 'Ancilliary load factor [-]' 'Angle of ripose [deg]' 'Load height from top of bin [mm]'};
    inputs = [m roh*10^9 (m/(roh*10^9)) t roh1*10^9 f_anc bet (buc_h(length(buc_h))-htot)];
    
    resultsHeadings = {'Payload load height [mm]' 'Payload mass [kg]' 'Payload CoGx [mm]' 'Payload CoGy [mm]' 'Payload CoGz rel. to ground [mm]' 'Payload Ixx [kg.m^2]' 'Payload Iyy [kg.m^2]' 'Payload Izz [kg.m^2]' 'Payload Rx [m]' 'Payload Ry [m]' 'Payload Rz [m]' 'Bucket mass [kg]' 'Bucket CoGz rel. to ground [mm]' 'Bucket Ixx [kg.m^2]' 'Bucket Iyy [kg.m^2]' 'Bucket Izz [kg.m^2]' 'Combined Mass [kg]' 'Combined CoGx rel. to hitch [mm]' 'Combined CoGy [mm]' 'Combined CoGz rel. to ground [mm]' 'Combined Ixx [kg.m^2]' 'Combined Iyy [kg.m^2]' 'Combined Izz [kg.m^2]' 'Combined Rx [m]' 'Combined Ry [m]' 'Combined Rz [m]'};
    results = [htot m vCoGx(1) vCoGy(1) (hcog+h_bin+t) Ixx*10^-6 Iyy*10^-6 Izz*10^-6 ((Ixx*10^-6)/m)^0.5 ((Iyy*10^-6)/m)^0.5 ((Izz*10^-6)/m)^0.5 m1 (hcog1+h_bin+t) Ixx1*10^-6 Iyy1*10^-6 Izz1*10^-6 combinedInertias (combinedInertias(5)/combinedInertias(1))^0.5 (combinedInertias(6)/combinedInertias(1))^0.5 (combinedInertias(7)/combinedInertias(1))^0.5] ;
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        printResultsInertia(fileName, savePath, inputHeadings, resultsHeadings, inputs, results, sheetName);
        savePlot(savePath, runKey, sheetName)
    end
    
end

payloadSummary = {'Payload mass [kg]', m;...
                  'Payload density [kg/m^3]', roh*10^9;...
                  'Load height from top of bin [mm]', (buc_h(length(buc_h))-htot);...
                  'Payload CoGz rel. to ground [mm]', (hcog+h_bin+t);...
                  'Payload CoGx rel. to hitch [mm]', xcogPayload;...
                  'Payload Rx [m]', ((Ixx*10^-6)/m)^0.5;...
                  'Payload Ry [m]', ((Iyy*10^-6)/m)^0.5;...
                  'Payload Rz [m]', ((Izz*10^-6)/m)^0.5;...
                  'Loaded Volume [m^3]', (m/(roh*10^9));...
                  'Angle of repose [deg]', bet;...
                  } %Results to display in PostProcessor
end

function [hcog1, m1, Ixx1, Iyy1, Izz1]=inertia_calc1(buc_w,buc_h,roh,t,L)
%
% Front and back plates
Vbuc=(buc_w(2:end)+buc_w(1:end-1)).*(buc_h(2:end)-buc_h(1:end-1))*t;
Vtot=sum(Vbuc);
mbuc=roh*Vbuc;
mtot=roh*Vtot;
mbuccum=cumsum(mbuc);
h=hc(buc_h(2:end)-buc_h(1:end-1),buc_w(2:end),buc_w(1:end-1))+buc_h(1:end-1);
hcog=sum(h.*mbuc)/mtot;
ixx=Ixxc(buc_h(2:end)-buc_h(1:end-1),buc_w(2:end),buc_w(1:end-1),mbuc);
Ixx=sum(ixx)+sum(mbuc.*(h-hcog).^2);
iyy=Iyyc(buc_h(2:end)-buc_h(1:end-1),buc_w(2:end),buc_w(1:end-1),2*t,mbuc);
Iyy=sum(iyy)+sum(mbuc.*(h-hcog).^2)+mtot*L^2/4;
izz=Izzc(buc_w(2:end),buc_w(1:end-1),2*t,mbuc);
Izz=sum(izz)+mtot*L^2/4;
%
% Bottom and side plates
buc_l=((buc_w(1:end)/2-[0 buc_w(1:end-1)/2]).^2+(buc_h(1:end)-[0 buc_h(1:end-1)]).^2).^0.5;
ltot=sum(buc_l);
buc_hc1=sum(buc_l.*(buc_h(1:end)+[0 buc_h(1:end-1)])/2)/ltot;
buc_dx=(buc_w(1:end)-[0 buc_w(1:end-1)])/2;
buc_dy=(buc_h(1:end)-[0 buc_h(1:end-1)]);
buc_cx=(buc_w(1:end)+[0 buc_w(1:end-1)])/4;
buc_cy=(buc_h(1:end)+[0 buc_h(1:end-1)])/2;
ll=L+2*t;
mbuc1=buc_l*ll*t*roh;
mtot1=sum(mbuc1);
m1=mtot+mtot1*2;
hcog1=(mtot*hcog+mtot1*2*buc_hc1)/m1;
ixx1=sum(1/6*mbuc1.*buc_l.^2+2*mbuc1.*(buc_cx.^2+(buc_cy-buc_hc1).^2));
Ixx1=ixx1+Ixx+mtot*(hcog1-hcog)^2+2*mtot1*(hcog1-buc_hc1)^2;
iyy1=sum(1/6*mbuc1.*(buc_dy.^2+ll^2)+2*mbuc1.*((buc_cy-buc_hc1).^2));
Iyy1=iyy1+Iyy+mtot*(hcog1-hcog)^2+2*mtot1*(hcog1-buc_hc1)^2;
izz1=sum(1/6*mbuc1.*(buc_dx.^2+ll^2)+2*mbuc1.*(buc_cx.^2));
Izz1=izz1+Izz;
end

function [htot, hcog, Ixx, Iyy, Izz, w]=inertia_calc(buc_w,buc_h,roh,m,L,bet)
Vbuc_nh=(buc_w(2:end)+buc_w(1:end-1)).*(buc_h(2:end)-buc_h(1:end-1))/2*L; % Without heap
% V1heap inside heap or prism
V1heap=(buc_w(2:end)/4*tand(bet).*buc_w(2:end).*(L-buc_w(2:end)))-[0 (buc_w(2:end-1)/4*tand(bet).*buc_w(2:end-1).*(L-buc_w(2:end-1)))];
% V2heap outside heap or cone
V2heap=pi*(buc_w(2:end)/2).^2.*tand(bet).*buc_w(2:end)/2/3-[0 pi*(buc_w(2:end-1)/2).^2.*tand(bet).*buc_w(2:end-1)/2/3];
Vbuc=Vbuc_nh+V1heap+V2heap;
Vtot=sum(Vbuc);
mbuc=roh*Vbuc;
mbuc_nh=roh*Vbuc_nh;
mtot=roh*Vtot;
mbuccum=cumsum(mbuc);
mbuccum_nh=cumsum(mbuc_nh);
ind=find(m<mbuccum,1,'first');
if isempty(ind)
    htot=buc_h(end);
    w=buc_w(end);
    ind=length(mbuccum);
    disp(['Bucket overflows. Maximum m = ' num2str(mbuccum(end))]) ;
    m=mbuccum(end);
else
    if ind==1,
        h1=buc_h(1);
        h2=buc_h(2);
        dh12=h2-h1;
        w1=buc_w(1);
        w2=buc_w(2);
        a=(w2-w1)/dh12;
        b=w1;
        c1=(pi/24-0.25)*tand(bet);
        c2=0.25*tand(bet)*L;
        %
        if (w1^2/4*tand(bet)*(L-w1)+pi*w1^3/24*tand(bet))*roh>m
            disp(['The bucket does not have enough material to fill the floor of the bucket. Expect unreliable results.']) ;
        end
        %
        dhall=roots([c1*a^3 a*L/2+c2*a^2+3*c1*a^2*b b*L/2+w1*L/2+2*c2*a*b+3*c1*a*b^2 -m/roh+c1*b^3+c2*b^2]);
        htot=min(dhall(dhall>0));
        % Check w=a*dh+b v=(w+w1)/2*dh*L+w^2/4*tand(bet)*(L-w)+pi*w^3/24*tand(bet) v=(m-mbuccum_nh(ind-1))/roh
    else
        h1=buc_h(ind);
        h2=buc_h(ind+1);
        dh12=h2-h1;
        w1=buc_w(ind);
        w2=buc_w(ind+1);
        a=(w2-w1)/dh12;
        b=w1;
        c1=(pi/24-0.25)*tand(bet);
        c2=0.25*tand(bet)*L;
        dhall=roots([c1*a^3 a*L/2+c2*a^2+3*c1*a^2*b b*L/2+w1*L/2+2*c2*a*b+3*c1*a*b^2 (-(m-mbuccum_nh(ind-1)))/roh+c1*b^3+c2*b^2]);
        dh=min(dhall(dhall>0));
        htot=dh+buc_h(ind);
        % Check w=a*dh+b v=(w+w1)/2*dh*L+w^2/4*tand(bet)*(L-w)+pi*w^3/24*tand(bet) v=(m-mbuccum_nh(ind-1))/roh
    end
end
%
% Non heaped layers first
buc_w(ind+1)=buc_w(ind)+(buc_w(ind+1)-buc_w(ind))*(htot-buc_h(ind))/(buc_h(ind+1)-buc_h(ind));
buc_h(ind+1)=htot;
buc_w=buc_w(1:ind+1);
buc_h=buc_h(1:ind+1);
Vbuc_nh=(buc_w(2:end)+buc_w(1:end-1)).*(buc_h(2:end)-buc_h(1:end-1))/2*L ;
Vtot_nh=sum(Vbuc_nh);
mbuc_nh=roh*Vbuc_nh;
mtot_nh=roh*Vtot_nh;
mbuccum_nh=cumsum(mbuc_nh);
h_nh=hc(buc_h(2:ind+1)-buc_h(1:ind),buc_w(2:ind+1),buc_w(1:ind))+buc_h(1:ind);
%
% Heaped layer on top
w=buc_w(ind+1);
V1heap=w^2/4*tand(bet)*(L-w); % The triangalur prism heap
V2heap=pi*w^3/24*tand(bet); % The split cone heap (makes a full cone) r=w/2
m1heap=V1heap*roh;
m2heap=V2heap*roh;
h1=w*tand(bet)/2/3+htot; % CoG height of prism 1/3 up total height
h2=w*tand(bet)/2/4+htot; % CoG height of cone 1/4 up total height
%
mbuc=[mbuc_nh m1heap m2heap];
mtot=sum(mbuc);
h=[h_nh h1 h2];
hcog=sum(h.*mbuc)/mtot;
%
ixx=[Ixxc(buc_h(2:ind+1)-buc_h(1:ind),buc_w(2:ind+1),buc_w(1:ind),mbuc_nh) Ixxc(w*tand(bet)/2,0,w,m1heap) 3/80*m2heap*(w*tand(bet)/2)^2+3/20*m2heap*(w/2)^2];
Ixx=sum(ixx)+sum(mbuc.*(h-hcog).^2);
iyy=[Iyyc(buc_h(2:ind+1)-buc_h(1:ind),buc_w(2:ind+1),buc_w(1:ind),L,mbuc_nh) Iyyc(w*tand(bet)/2,0,w,L-w,m1heap) m2heap*(3/80*(w*tand(bet)/2)^2+(3/20-1/4/pi^2)+(L/2-w/2+w/2/2/pi)^2)];
Iyy=sum(iyy)+sum(mbuc.*(h-hcog).^2);
izz=[Izzc(buc_w(2:ind+1),buc_w(1:ind),L,mbuc_nh) Izzc(0,w,L-w,m1heap) m2heap*((3/10-4/pi^2)*(w/2)^2+(L/2-w/2+w/2/2/pi)^2)];
Izz=sum(izz);
end

function htrap=hc(h,a,b)
htrap=h/3.*(b+2.*a)./(a+b);
end

function Ixx=Ixxc(h,a,b,m) %trapezoid
Ixx=2*(16*h.^2.*a.*b+4*h.^2.*b.^2+4*h.^2.*a.^2+3*a.^4+6*a.^2.*b.^2+6*a.^3.*b+6*a.*b.^3+3.*b.^4)./(a+b).^2./144.*m;
end

function Iyy=Iyyc(h,a,b,L,m) %trapezoid
Iyy=(h.^2.*(2+4*a.*b./(a+b).^2)/36+L^2/12).*m;
end

function Izz=Izzc(a,b,L,m) %trapezoid
Izz=((6*(a.^2+b.^2))/144+L^2/12).*m;
end


function dummy=plotbucketout(buc_w,buc_h)
sta_w=[0];
sta_h=[0];
for i=1:length(buc_w)
    plot([sta_w(1)/2 buc_w(i)/2],[sta_h(1) buc_h(i)],'k-');
    plot([-sta_w(1)/2 -buc_w(i)/2],[sta_h(1) buc_h(i)],'k-');
    sta_w=buc_w(i);
    sta_h=buc_h(i);
end
axis equal;
dummy=1;
end

function dummy=plotload(w,h,bet)
plot([-w/2 0],[h h+tand(bet)*w/2],'k-');
plot([w/2 0],[h h+tand(bet)*w/2],'k-');
end
