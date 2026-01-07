function [] = checkOverwrite(savePath, fileName)

if exist(savePath,'dir')
    disp('The run already exists and will be overwritten.');
else
    mkdir(savePath); %Creates directory
end

end