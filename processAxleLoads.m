%% Function Description
% 
% Calculates axle loads and provides them in a format suitable for excel
% 
%% Inputs
% 
% * To be updated when the need arises
% 
%% Outputs
% 
% * To be updated when the need arises
% 
%% Change Log
%
% [0.3.0] - 2017-06-20
%
% *Added*
%
% * Check for NRTA regulation 239 (3) to ensure appropriate axle loads are present
%
% [0.2.0] - Date not recorded
% 
% *Fixed*
% 
% * Accounted for if a dolly is present
% * dLoad is parameterised for each unit, includes dollys which are empty
% * dgaLoad is parameterized for each table in a GA drawing
% 
% [0.1.0] - Date not recorded
% 
% *Added*
% 
% * First code


%Changelogs
%Ver 1.0
%   -> First iteration
%Ver 2.0
%   -> Accounted for if a dolly is present
% dLoad is parameterised for each unit, includes dollys which are empty
% dgaLoad is parameterized for each table in a GA drawing
function [] = processAxleLoads(fileName, savePath, grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, zAxle, h, mSprung, XcgSprung, HcgSprung, mChas, xChas, mLoad, xLoad, dLoad, isPrint)

[A1, A2] = axleLoadCalc(grouping, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad);

% First vehicle Second axle group and first axle group
ii=1;
loadHeadings = {'Description' 'Steer Axle' 'Total' 'Drive axles'};
if isempty(loadCoupled)||~loadCoupled(1) %not receiving hitch load
    dgaLoad{:,1} = {'Axle' 'Chassis' dLoad{:,1}{:} 'Total'}';
else %receive hitch load
    dgaLoad{:,1} = {'Hitch' 'Axle' 'Chassis' dLoad{:,1}{:} 'Total'}';
end
loadMat{:,1} = {dgaLoad{:,1} [A1{:,1} sum([A1{:,1}])]' ([A1{:,1} sum([A1{:,1}])]' + [A2{:,1} sum([A2{:,1}])]') [A2{:,1} sum([A2{:,1}])]'}; % Unit 1 Forward pivot loads | total loads | rear pivot loads
Acomb(1) = sum([A1{:,1}]);
Acomb(2) = sum([A2{:,1}]);

for i=3:1:length(grouping)
    if loadCoupled(i-2) %axle group is not a dolley
        ii=ii+1;
        if (i==3)||loadCoupled(i-3) %axle group in front is not a dolley
            loadHeadings = [loadHeadings {'' 'Description' 'Hitch' 'Total' 'Trailer axles'}];
            dgaLoad{:,ii} = {'Axle' 'Chassis' dLoad{:,i-1} 'Total'}';
            if (i==length(grouping)) %cannot receive hitch load
                dgaLoad{:,ii} = {'Axle' 'Chassis' dLoad{:,i-1}{:} 'Total'}';
                loadMat{:,ii} = {dgaLoad{:,ii} [A1{2:end,i-1} sum([A1{2:end,i-1}])]' ([A1{2:end,i-1} sum([A1{2:end,i-1}])]' + [A2{2:end,i-1} sum([A2{2:end,i-1}])]') [A2{2:end,i-1} sum([A2{2:end,i-1}])]'}; % Unit Forward pivot loads | total loads | rear pivot loads
            elseif loadCoupled(i-1) %if receiving hitch load
                dgaLoad{:,ii} = {'Hitch' 'Axle' 'Chassis' dLoad{:,i-1}{:} 'Total'}';
                loadMat{:,ii} = {dgaLoad{:,ii} [A1{:,i-1} sum([A1{:,i-1}])]' ([A1{:,i-1} sum([A1{:,i-1}])]' + [A2{:,i-1} sum([A2{:,i-1}])]') [A2{:,i-1} sum([A2{:,i-1}])]'}; % Unit Forward pivot loads | total loads | rear pivot loads
            else %not receiving hitch load
                dgaLoad{:,ii} = {'Axle' 'Chassis' dLoad{:,i-1}{:} 'Total'}';
                loadMat{:,ii} = {dgaLoad{:,ii} [A1{2:end,i-1} sum([A1{2:end,i-1}])]' ([A1{2:end,i-1} sum([A1{2:end,i-1}])]' + [A2{2:end,i-1} sum([A2{2:end,i-1}])]') [A2{2:end,i-1} sum([A2{2:end,i-1}])]'}; % Unit Forward pivot loads | total loads | rear pivot loads
            end
            Acomb(i) = sum([A2{:,i-1}]);
        else %axle group in front is a dolley
            loadHeadings = [loadHeadings {'' 'Description' 'Dolley' 'Total' 'Trailer axles'}];
            dgaLoad{:,ii} = {'Axle' 'Chassis' dLoad{:,i-1} 'Total'}';
            if loadCoupled(i-1) %if receiving hitch load
                dgaLoad{:,ii} = {'Hitch' 'Axle' 'Dolley' 'Chassis' dLoad{:,i-1}{:} 'Total'}';
                loadMat{:,ii} = {dgaLoad{:,ii} [A1{1,i-1} A2{2,i-2} A2{3,i-2} A1{3:end,i-1} sum([A1{1,i-1} A2{2,i-2} A2{3,i-2} A1{3:end,i-1}])]' ...
                    ([A1{1,i-1} A2{2,i-2} A2{3,i-2} A1{3:end,i-1} sum([A1{1,i-1} A2{2,i-2} A2{3,i-2} A1{3:end,i-1}])]' + [A2{1:2,i-1} 0 A2{3:end,i-1} sum([A2{1:2,i-1} 0 A2{3:end,i-1}])]') ...
                    [A2{1:2,i-1} 0 A2{3:end,i-1} sum([A2{1:2,i-1} 0 A2{3:end,i-1}])]'}; % Unit Forward pivot loads | total loads | rear pivot loads
            else %not receiving hitch load
            dgaLoad{:,ii} = {'Axle' 'Chassis' 'Dolley' dLoad{:,i-1}{:} 'Total'}';
            loadMat{:,ii} = {dgaLoad{:,ii} [A2{2,i-2} A2{3,i-2} A1{3:end,i-1} sum([A2{2,i-2} A2{3,i-2} A1{3:end,i-1}])]' ...
                ([A2{2,i-2} A2{3,i-2} A1{3:end,i-1} sum([A2{2,i-2} A2{3,i-2} A1{3:end,i-1}])]' + [0 A2{3:end,i-1} sum(A2{3:end,i-1})]') [0 A2{3:end,i-1} sum(A2{3:end,i-1})]'}; % Unit Forward pivot loads | total loads | rear pivot loads
            end
            Acomb(i) = sum([A2{:,i-1}]);
        end
    else %axle group is a dolley
        Acomb(i) = sum([A2{:,i-1} A1{:,i}]);
    end
end

Axle1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled); %Check

for i=1:length(grouping)
    Acomb(2,i)=sum(Axle1(grouping{i})); %Calculated using AxleLoade and combined masses
end

if isPrint
    printResultsAxleLoads(fileName, savePath, loadMat, loadHeadings, Acomb, groupingHeadings);
end
    
end