function [A] =  computeAxleLoadWithGradient(grad,mA,xA,zA,l,h,mSpr,xSpr,zSpr,grouping,loadshare,loadCoupled)

% ver a
%     Axle loads calculated on flat

% ver b
%     Axle loads calculated on gradient
%
% ver c
%     Only axle loads are outputted
%
% ver d
%     Uses new wheelbase definition
%
% ver e
%     Uses loadCoupled
%
% Note presently it is assumed the drive force is given by the first
% trailer unit
%
% ver f
%   Added the ability to calculate axle load with multiple steer axles
%
% ver g
%
% Fixed an erroneous calculation when the axle load distribution is not equal in an axle group
%
th=atan(grad/100);
%
%
for i=length(grouping):-1:3
    if i==length(grouping) %if last trailer it must be loadcoupled to hitch in front
        WB=sum(xA(grouping{i}).*loadshare(grouping{i}));
        Agroup=(sum(((cos(th)*xA(grouping{i})-sin(th)*(h(i-2)-zA(grouping{i}))).*mA(grouping{i})))+(cos(th)*xSpr(i-1)-sin(th)*(h(i-2)-zSpr(i-1)))*mSpr(i-1))/WB;
        % Multiply the total axle group load with the load distribution vector
        A(grouping{i})=Agroup*loadshare(grouping{i});
        X=sum(sin(th)*mA(grouping{i}))+sin(th)*mSpr(i-1);
        Z=sum(cos(th)*mA(grouping{i}))+cos(th)*mSpr(i-1)-Agroup;
    elseif loadCoupled(i-2) %if loadcoupled to hitch in front
        WB=sum(xA(grouping{i}).*loadshare(grouping{i}));
        Agroup=(sum(((cos(th)*xA(grouping{i})-sin(th)*(h(i-2)-zA(grouping{i}))).*mA(grouping{i})))+(cos(th)*xSpr(i-1)-sin(th)*(h(i-2)-zSpr(i-1)))*mSpr(i-1)+l(i-1)*Z+(h(i-1)-h(i-2))*X )/WB;
        % Multiply the total axle group load with the load distribution vector
        A(grouping{i})=Agroup*loadshare(grouping{i});
        X=sum(sin(th)*mA(grouping{i}))+sin(th)*mSpr(i-1)+X;
        Z=sum(cos(th)*mA(grouping{i}))+cos(th)*mSpr(i-1)-Agroup+Z;
    else % if not loadcoupled to the hitch in front
        Agroup=Z+sum(cos(th)*mA(grouping{i}))+cos(th)*mSpr(i-1);
        % Multiply the total axle group load with the load distribution vector
        A(grouping{i})=Agroup*loadshare(grouping{i});
        X=sum(sin(th)*mA(grouping{i}))+sin(th)*mSpr(i-1)+X;
        Z=0;
    end
end
%
% Second axle group
% Need to adjust the wheelbase if there are multiple steer axles. The centre of the steer axle group will be the datum
steerGroupCentre = sum(xA(grouping{1}).*loadshare(grouping{1}));
WB=sum(xA(grouping{2}).*loadshare(grouping{2}))-steerGroupCentre;
if isempty(h)
    Agroup=(sum(((cos(th)*(xA(grouping{2})-steerGroupCentre)-sin(th)*(0-zA(grouping{2}))).*mA(grouping{2})))...
    +(cos(th)*(xSpr(1)-steerGroupCentre)-sin(th)*(0-zSpr(1)))*mSpr(1) )/WB;
    Z = 0;
else
    Agroup=(sum(((cos(th)*(xA(grouping{2})-steerGroupCentre)-sin(th)*(0-zA(grouping{2}))).*mA(grouping{2})))...
    +(cos(th)*(xSpr(1)-steerGroupCentre)-sin(th)*(0-zSpr(1)))*mSpr(1)+(l(1)-steerGroupCentre)*Z+(h(1)-0)*X )/WB;
end    

% Multiply the total axle group load with the load distribution vector
A(grouping{2})=Agroup*loadshare(grouping{2});
%
% First axle group
i=1;
Agroup=Z+sum(cos(th)*mA(grouping{2}))+sum(cos(th)*mA(grouping{1}))+cos(th)*mSpr(1)-Agroup;
% Multiply the total axle group load with the load distribution vector
A(grouping{1})=Agroup*loadshare(grouping{1});


