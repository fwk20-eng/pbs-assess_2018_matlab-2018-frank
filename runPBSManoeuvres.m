%% Function Description
%
% Post Processor that processes the results from TruckSim, outputing a summary of results in graphical form as well as
% in an Excel spreadsheet
%
%% Inputs
%
% * variable: description
%
%% Outputs
%
% * variable: description
%
%% Change Log
%% Future Additions
%
% * Do artic angle and artic angle rate for Yaw Damping
%
%
%% Checks and corrections
%
% * Does the programme work for truck trailer combination with dolleys? Yes it looks like it does work
% * Correct STFD
% * Correct SRT for lift of all Fz except steer.
% * Check SRTrrcu
%
% [0.9.0] - 2018-03-05
%
% * Added SRTrrcu edition of SRT where a stabilising mass is placed 1 mm from the ground on all units except for the rrcu
%
% [0.8.0]
%
% * Neaten up the code, to aid in modifications to allow car-carriers
%
% [0.7.0] - 2017-05-13
%
% * Added the ability to write the results to the report.
%
% [0.6.0] - 2017-05-12
%
% *Fixed*
%
% * Improved some variable names. Work still needs to be done in this regard
% * Improved variable pass-through
%
% *Added*
%
% * PBS Assessment copying of template and edition according to Report structure details
%
% [0.5.0] - 2017-05-10
%
% *Added*
%
% * Added Latex Table Generation
%
%
%% [0.4.0] - 2017-05-02
%
% *Added*
%
% * Moved unchanged code from project file to the main postprocess file
%
%% [0.3.0] - 2017-05-01
%
% *Added*
%
% * TruckSim data has now been extracted and no longer needs to be manually entered.
% * Variables to be input have been shortened with the use of structures. (Variables beginning with a capital letter)
%
%% [0.2.0] - Date Unknown
%
% *Added*
%
% * Check for the lateral acceleration in the YawD manoeuvre (Program will now generate an error if the lateral
% acceleration is outside of the range 0.19 < LatAccel < 0.21 for the lead unit)
% * Check for the lateral error in the RA manoeuvre (Program will now generate an error if the lateral error is above
%   30 mm)
% * Added a new function to generate an auto log file with the Project.runNotes which can be appended even if no data is saved

%% [0.1.0] - Date Unknown
%
% * Completely removed PBS functions from the input file
% * Each project will now get its own PostProcess file of the format a000_PostProcess - the a to move it to the top of
%   the folder
% * Added functionality to choose which PBS manoeuvres to run
% * Results will only be saved for a full PBS analysis

%% NOTES:
% 1. List of inputs from TruckSim listed in "Inputs required from TruckSim.xls" file in this folder

%% Beginning of function
function [Project, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions, fullName, Lim, LimReport, resultsPbs,...
    nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Combination] =...
    runPBSManoeuvres(Is, Project, Combination, MatKey, Report)
%% Preamble
%% Generate the required file paths and perform the necessary checks for the assessment

[Project, ParDetails, Is] = createFilePaths(Project, MatKey, Is);

% createRunLog(Is, Project);
copyTruckSimRunFiles(MatKey, Project, Is);

[Tyre, Axle, Hitch, Sprung, Dimensions, PayloadLaden, PayloadUnladen, Dummy, Combination] =...
    runTruckSimDataExtraction(ParDetails, Is, Combination);

[Engine] = getEngineData(Combination, Tyre);
%%	Constants
warning off

g = 9.81; % [g] CONFIRM WITH FRANK IF THIS IS NECESSARY
nLevels = 4;    % PBS levels - should correspond to size of cell arrays in getPBSLimits function
radial = 1; %radial = 1 for radial tyres else = 0 if bias ply
muPeakSteer = 0.8;       % Updated to 0.8 according to NTC rules. Originally set to 1 for corroboration purposes.
RAinputAy = 0.15;      % [g] normally 0.15 for RA test completed at 88km/h %% CONFIRM WITH FRANK IF THIS IS NECESSARY
SRTrollThresh = 30;    % PBS rules
%%	Execute PBS manoeuvres if required
if Is.pbs
    Sprung.numberOffUnits = length(Sprung.MassArray);      % includes Combination.dollys
    
    fullName = getFullPBSNames();
    [Lim, LimReport] = getPBSLimits(Is);
    
    % Determine sprung mass properties of each vehicle unit
    [mSprung, XcgSprung, HcgSprung] = computeSprungCoG(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition,...
        PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell, PayloadLaden.CoGzPositionCell); 
    
    % Determine sprung mass properties of each vehicle unit in unloaded configuration
    [mSprungU, XcgSprungU, HcgSprungU] = computeSprungCoG(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition,...
        PayloadUnladen.MassCell, PayloadUnladen.CoGxPositionCell, PayloadUnladen.CoGzPositionCell); 
    
    % Determine sprung mass properties of each vehicle unit
    [mTotal x z] = computeOverallCoG(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition,...
        Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Axle.Grouping, PayloadLaden.MassCell,...
        PayloadLaden.CoGxPositionCell, PayloadLaden.CoGzPositionCell); 
    
    % Loaded axles loads for normal operation
    Axle1 = computeAxleLoadWithGradient(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray,...
        Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping, Combination.loadshare1,...
        Hitch.LoadCoupledArray);
    
    % Loaded axles loads for Startability
    Axle2 = computeAxleLoadWithGradient(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray,...
        Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping, Combination.loadshare2,...
        Hitch.LoadCoupledArray); 
    
    % Unloaded axles loads for normal operation
    AxleU1 = computeAxleLoadWithGradient(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray,...
        Hitch.ZPositionArray, mSprungU, XcgSprungU, HcgSprungU, Axle.Grouping, Combination.loadshare1,...
        Hitch.LoadCoupledArray); 
    
    %Unloaded axle loads for Startability, which is not required
    AxleU2 = computeAxleLoadWithGradient(0, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray, Hitch.XPositionArray,...
        Hitch.ZPositionArray, mSprungU, XcgSprungU, HcgSprungU, Axle.Grouping, Combination.loadshare2,...
        Hitch.LoadCoupledArray); 
    
    %Raw axle loading values
    AxleLoading = [[1:Axle.NumberOff]; Combination.loadshare1; Axle1; AxleU1; Combination.loadshare2; Axle2; AxleU2];
    
    %Rounded axle loadings
    roundAxleLoading = [[1:Axle.NumberOff]; Combination.loadshare1; round(Axle1,0); round(AxleU1,0);...
        Combination.loadshare2; round(Axle2,0); round(AxleU2,0)];
    
    if Is.long
        if Is.longSolveWithGradient
            [r.STA, r.GRAa, r.GRAb, r.ACC] = assessLONG_WithGradient(mTotal, Combination.frontalAreaForDrag, radial,...
                Combination.ch, Combination.cd, Combination.ce, Engine.gears, Engine.eff_gear, Engine.gearsStart,...
                Engine.eff_gearStart, Engine.eff_diff, Engine.dif, Engine.eff_diffStart, Engine.difStart,...
                Engine.Torquerpm, Engine.TorqueNm, Engine.engageTrpm, Engine.engageTNm, Engine.changeT,...
                Tyre.RollingRadius, Engine.Ie, Engine.It, Axle.Driven, Engine.gearshiftregime, Project.savePath,...
                Project.runKey, Is.plotOn, Is.save, Axle.UnsprungMassArray, Axle.XPositionArray, Axle.ZPositionArray,...
                Hitch.XPositionArray, Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, Axle.Grouping,...
                Combination.loadshare1, Combination.loadshare2, Hitch.LoadCoupledArray);
        else
            [r.STA, r.GRAa, r.GRAb, r.ACC] = assessLONG(Combination, Engine, Tyre, Axle, Project, Is, mTotal,Axle1,...
                Axle2, radial);
        end
    end
    if Is.yawD
        [r.YDC Project.yawDMaxLatAccel] = assessYAWD(Sprung, Project, Is, MatKey.yawD);
    end
    if Is.hsto
        r.HSTO = assessHSTO(Axle, Combination, Project, MatKey.hsto, Is, Dummy);
    end
    if Is.srt
        [r.SRTt, r.SRTtrrcu] = assessSRTt(Combination, Axle, Hitch, Project, MatKey.srt, Is, Dummy,...
            Lim.SRT(Combination.pbsLevelDesired), SRTrollThresh, mSprung, HcgSprung);
        % SRT is required to determine the limits for the RA maneouvre, hence the RA manoeuvre can only be run along
        % with the SRT manoeuvre
        if Is.ra
            Lim.RA = computePBSLimitsRA(r);
            [r.RA Project.raMaxLatError] = assessRA(Combination, Hitch, Project, MatKey.ra, Is, mSprung, HcgSprung);
        end
    end
    if Is.tasp
        r.TASP = assessTASP(Sprung, Combination, Project, MatKey.tasp, Is);
    end
    if Is.lst
        [r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = assessLST(Sprung, Combination, Axle, Project,...
            MatKey.lst, Is, muPeakSteer, true);
    end
    if Is.lsunt
        [r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = assessLST(Sprung, Combination, Axle, Project,...
            MatKey.lsunt, Is, muPeakSteer, false);
    end
    if Is.axle
      [Axle] = assessAXLE(Axle, MatKey.axle, Project, Is, Dummy);
      
      axleNumbers = AxleLoading(1, :);
      loadShare1AxleLoads = AxleLoading(3, :);
      differenceInAxleLoad = round(Axle.truckSimLoads - loadShare1AxleLoads,3);
      differenceInAxleLoadPerc = round((differenceInAxleLoad./Axle.truckSimLoads)*100,3);
      
      Axle.truckSimLoads = [axleNumbers; Axle.truckSimLoads; loadShare1AxleLoads; differenceInAxleLoad; ...
          differenceInAxleLoadPerc];
    end
    
    disp('-------------------------------------------------------------------------------------')
    disp('	Axle Loads')
    disp('-------------------------------------------------------------------------------------')
    display(num2cell(roundAxleLoading));
    % Calculating the GCM and drive axle load ratio
    Axle.gcm = sum(AxleLoading(3,:));
    Axle.driveAxleLoad = sum(AxleLoading(3,Axle.Driven));
    Axle.driveAxleLoadRatio = Axle.driveAxleLoad/Axle.gcm;
    
    fprintf('%s%0.0f%s\n','Combination GCM: ', Axle.gcm, ' kg');
    fprintf('%s%0.2f%s\n', 'Drive Axle Load Ratio: ', Axle.driveAxleLoadRatio*100, ' %');
    
    %% Check for NRTA regulation 239 (3)
    
    if (Axle.driveAxleLoadRatio) < 0.2 && ~Is.skipManoeuvreChecks
        
        warnAxleLoad = questdlg('Drive axle load does not satisfy the required 20 % of the total vehicle GCM (NRTA regulation 239 (3))',...
            'Would you like to proceed with the assessment?',...
            'Yes', 'End Assessment', 'End Assessment');
        
        switch warnAxleLoad
            case 'Yes'
                uiwait(msgbox('Please note that the assessed combination does not satisfy NRTA regulation 239 (3)'));
            case 'End Assessment'
                uiwait(msgbox('The assessment will now be ended with a manually initialised error'));
                error('Manually initiated error in order to jump out of the script');
        end
        
    end
    
    disp('-------------------------------------------------------------------------------------')
    disp('	Results')
    disp('-------------------------------------------------------------------------------------')
    resultsPbs = r;
    resultsWithLevel = createTableResults(r, Lim, fullName, nLevels, Is);
    
    display(resultsWithLevel(:, 1:4));
    warning on
    
    if Is.log
        addRunToLog(Project, Is, resultsWithLevel, roundAxleLoading, Axle);
    end
    %% Write data to excel
    
    if Is.fullPBS
        % Implimentation of determining PBS level
        Combination = createPBSPerformanceString(Combination, resultsWithLevel);
        printAxleLoads(Project, Sprung, PayloadLaden, Axle, Hitch, Combination, Is);
        runWriteExcelPBSResultsAndAxleLoads(Lim, fullName, nLevels, Project, AxleLoading, Is, roundAxleLoading, r,...
            Combination, resultsWithLevel);
    end
end
end