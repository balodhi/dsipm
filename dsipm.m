%This matlab script is for digital photon counting.
%It reads a dpct file in
%[bb,mod1,tile,die,frame_nr,delay,timestamp,p1,p2,p3,p4,temp,status,event_id,frame_counter]
%format and generat an output text file in 
%[die p1 p2 p3 p4 frame_counter
%timestamp(ids)] format. where p is pixel.
% Dated: 30/11/2017
% Author: Bilal (balodhi@gmail.com)
%% clear the environment
clc
clear all 
close all
close all hidden

%% Get the file path and list of files
[fileName,filePath,~] = uigetfile({'*.dpct'}, 'dpct File(*.dpct)');
h = waitbar(0,'Please wait (making directory list)... ');
d = dir(fullfile(filePath, '*.dpct'));
d([d.isdir]) = [];
fNamelist = {d.name}';
dotOccurance = strfind(fileName,'.');
startFileIndex = str2num(fileName(dotOccurance(1)+1:dotOccurance(2)-1)+1);
endFileIndex = size(fNamelist,1);
%endFileIndex = 10;

%% output file settings
outputFileName = '308_9C_Standrd_S2_NL_ON_FL_OFF.txt';
if exist(outputFileName, 'file')==2
    disp('Previous output file found and deleted. \n')
  delete(outputFileName);
end

%% process the data and save it.
waitbar(5,h,'Starting to read, format and save.');
format = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
start_time = clock;
startMsg = sprintf('Starting reading from file number: %d',startFileIndex);
disp(startMsg);
for idx=startFileIndex:endFileIndex
    
    DataFile1=fullfile(filePath,char(fNamelist(idx)));
    [bb,mod1,tile,die,frame_nr,delay,timestamp,p1,p2,p3,p4,temp,status,event_id,frame_counter] = textread(DataFile1,format,'delimiter',',','headerlines',12);
    
    ids = (die==5); %get binary indexes of the dies to extract
    pixel = [die(ids) p1(ids) p2(ids) p3(ids) p4(ids) frame_counter(ids) timestamp(ids)];
    dlmwrite(outputFileName,pixel,'-append','precision', 16);
    if idx ==startFileIndex
      one_iteration = etime(clock,start_time);
      esttime = one_iteration * endFileIndex;
     end
    waitbar(idx/endFileIndex,h,sprintf('%d/%d file(s). Est. completion time =%4.1f sec',idx,endFileIndex,esttime-etime(clock,start_time)));
   
end

%% process completion
delete(h)
disp('Process Completed...')
msgbox('Process completed and file has been written');
