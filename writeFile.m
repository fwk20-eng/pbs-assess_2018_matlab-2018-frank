%This function received details on a file and writes to it
    %filename = the name of the file that you want to write to
    %File = the variable containing the data to be written to file
function [] = writeFile(filename, File, printConf)
    
    numRows = length(File);
    fid = fopen(filename, 'w'); %Open the file to be written to
 
    for row = 1:numRows %Loop through each row of the File variable
         fprintf(fid, '%s\n', File{row, :}); %Write a row of the File to the open file and then move to the next line
    end

    fclose(fid); %close the file
    
    if printConf %if desired, display when the file is written
        display(sprintf('%s%s', filename ,' successfully written')); %Indicate that the file has been successfully written
    end
end