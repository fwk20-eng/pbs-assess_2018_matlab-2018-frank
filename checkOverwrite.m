function [] = checkOverwrite(savePath, fileName)

if exist(savePath,'dir')
    warnRunExists = questdlg('The run already exists, are you sure you want to overwrite?', 'Run exists warning', 'Yes', 'Cancel', 'Change', 'Cancel');
    switch warnRunExists
        case 'Yes'
            uiwait(msgbox('Run will be overwritten', 'Run chosen to be overwritten'));
            delete(strcat(savePath, '\',fileName));%Deleting results file to prevent leftover information clash
        case 'Change'
            savePath = uigetdir(savePath,'Please select directory to store results');
            mkdir(savePath); %Creates directory
        case 'Cancel'
            error('Manually initiated error in order to jump out of the script');
    end
else
    mkdir(savePath); %Creates directory
end

end