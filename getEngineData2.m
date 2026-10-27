%% Function Description
%
% This function stores and returns the engine properties depending on the engine model as designated by a string
% Based on getEngineData
%
%% Inputs
%
% * engineModel: string indicating the engine make and model
%
%% Outputs
%
% * Engine: structure containing all of the engine properties required to determine the longitudinal
%
%% Change Log
%
% [0.0.0] - 2020-04-24
function [Engine2] = getEngineData2(Combination)
%% Engine
switch Combination.engine2Model
    
    case 'Lohr Axeal'
        
        Engine2.EngineModelDescription = 'Lohr Axeal Electric Trailer Motor';
        Engine2.Torquerpm = [0      3521	4596	5735	7611	11407	11997];
        Engine2.TorqueNm =  [319	319     249     199     150     100     92];
        
            otherwise
        error('ENGINE DOES NOT EXIST, PLEASE ADD THE ENGINE TO getEngine2Data.m');
end

%% Gearbox
switch Combination.gearing2Model
    
    case 'Lohr Axeal'
        
        Engine2.GearingModelDescription =  'Lohr Axeal Electric Trailer Motor';      
        Engine2.gearing =   12.08; % axle rpm to electic motor rpm - different radii of tyres accounted for below
        Engine2.tyre_gearing =   492/383; % IC driven tyre radius to electric motor drive radius
        Engine2.eff_motor = 0.94; %engine efficiency 
        Engine2.eff_gear =  0.92;
        Engine2.limit = 0.25;
        Engine2.Driven2 = [5];
               
    otherwise
        error('GEARBOX DOES NOT EXIST, PLEASE ADD THE GEARBOX TO getEngine2Data.m');
end

end

