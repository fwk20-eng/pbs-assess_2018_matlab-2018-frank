rev = '200belowSteerRollTest'; %'MaxSG_Final';
projectKey = 'P022_sgCoal-SATB50m3-VolvoFM64T3HBX'; %Include an underscore as the final character 
rootPath = 'C:\Dropbox\PBS Technical Library\3 Combinations\P022_SGCoal-SATruckBodies50m3STI-VolvoFMX440FM64T3HBX\Results\'; %end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Dropbox\witsPBS\Runs';
%% --------------------------------------------------------------------------------------
%	Run Details
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp(strcat('	Run Notes for run titled: ', rev))
disp('-------------------------------------------------------------------------------------')

runNotes = {'-> Spring: Firestone';...
            '-> Testing 1392 mm hitch on prime mover, 1350 hitch height on trailer';...
            '-> Loaded to 200 mm from the top of the bin';...
            '-> Testing -0.087 steer roll coefficient instead of -0.156'} %Do not suppress
%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_v', rev);
runKey = sprintf('%s%s%s',projectKey,'_v',rev);% 'PBS Afrit 45 cube w VolvoFM64T3HTX_Rev 9'; %Rev Letter indicates it is a prelim
fileName = strcat(runKey, '_summary.xlsx');

hloadDesired = 200;
rhoMin = 900e-9;
rho = rhoMin;
[mLead, hcogLead, xcogLead, hload] = binCoG_SATB50m3(rho, 24793-1756, -954, 1650, fileName, savePath, runKey, 'Leader_Payload', 0, 0);

while hload ~= hloadDesired

    [mLead, hcogLead, xcogLead, hload] = binCoG_SATB50m3(rho, 24793-1756, -954, 1650, fileName, savePath, runKey, 'Leader_Payload', 0, 0);
    rho = rho+1e-9;
    
end