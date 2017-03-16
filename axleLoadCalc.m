function [A1, A2] = axleLoadCalc(grouping, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad)
for i=length(grouping):-1:3
    if i==length(grouping) %if last trailer it cannot receive a hitch load
        %
        wb=sum(xAxle(grouping{i}).*loadshare1(grouping{i}));
        %
        kk=2; %Axle masses
        ma=sum(mAxle(grouping{i}));
        wa=sum(xAxle(grouping{i}).*mAxle(grouping{i}))/ma;
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        %
        kk=3; %Chassis mass
        ma=mChas(i-1);
        wa=xChas(i-1);
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        for jj=1:length(xLoad{i-1})
            kk=kk+1;
            ma=mLoad{i-1}(jj);
            wa=xLoad{i-1}(jj);
            A2{kk,i-1}=wa/wb*ma;
            A1{kk,i-1}=(wb-wa)/wb*ma;
        end
    elseif loadCoupled(i-2) %if loadcoupled to hitch in front
        %
        wb=sum(xAxle(grouping{i}).*loadshare1(grouping{i}));
        %
        kk=1; %Hitch loads
        ma=sum([A1{:,i}]);
        wa=l(i-1);
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        %
        kk=2; %Axle masses
        ma=sum(mAxle(grouping{i}));
        wa=sum(xAxle(grouping{i}).*mAxle(grouping{i}))/ma;
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        %
        kk=3; %Chassis mass
        ma=mChas(i-1);
        wa=xChas(i-1);
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        for jj=1:length(xLoad{i-1})
            kk=kk+1;
            ma=mLoad{i-1}(jj);
            wa=xLoad{i-1}(jj);
            A2{kk,i-1}=wa/wb*ma;
            A1{kk,i-1}=(wb-wa)/wb*ma;
        end
    else
        %
        wb=sum(xAxle(grouping{i}).*loadshare1(grouping{i}));
        %
        kk=2; %Axle masses
        ma=sum(mAxle(grouping{i}));
        wa=sum(xAxle(grouping{i}).*mAxle(grouping{i}))/ma;
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        %
        kk=3; %Chassis mass
        ma=mChas(i-1);
        wa=xChas(i-1);
        A2{kk,i-1}=wa/wb*ma;
        A1{kk,i-1}=(wb-wa)/wb*ma;
        for jj=1:length(xLoad{i-1})
            kk=kk+1;
            A1{kk,i-1}=0;
            A2{kk,i-1}=A1{kk,i};
        end
    end
end
%
% First vehicle Second axle group and first axle group
%
i=2;
wb=sum(xAxle(grouping{i}).*loadshare1(grouping{i}));
%
kk=1; %Hitch loads
ma=sum([A1{:,i}]);
wa=l(i-1);
A2{kk,i-1}=wa/wb*ma;
A1{kk,i-1}=(wb-wa)/wb*ma;
%
kk=2; %Axle masses
ma=sum(mAxle(grouping{i}))+sum(mAxle(grouping{i-1}));
wa=(sum(xAxle(grouping{i}).*mAxle(grouping{i})) + sum(xAxle(grouping{i-1}).*mAxle(grouping{i-1})) )/ma;
A2{kk,i-1}=wa/wb*ma;
A1{kk,i-1}=(wb-wa)/wb*ma;
%
kk=3; %Chassis mass
ma=mChas(i-1);
wa=xChas(i-1);
A2{kk,i-1}=wa/wb*ma;
A1{kk,i-1}=(wb-wa)/wb*ma;

for jj=1:length(xLoad{i-1})
    kk=kk+1;
    ma=mLoad{i-1}(jj);
    wa=xLoad{i-1}(jj);
    A2{kk,i-1}=wa/wb*ma;
    A1{kk,i-1}=(wb-wa)/wb*ma;
end

end