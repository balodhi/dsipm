%This matlab script is for digital photon counting.
%It reads a dpct file in
%[bb,mod1,tile,die,frame_nr,delay,timestamp,p1,p2,p3,p4,temp,status,event_id,frame_counter]
%format and generat an output text file in 
%[die p1 p2 p3 p4 frame_counter
%timestamp(ids)] format. where p is pixel.
% Dated: 12/12/2017
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
startFileIndex = str2num(fileName(dotOccurance(1)+1:dotOccurance(2)-1))+1;
endFileIndex = size(fNamelist,1);
%endFileIndex = 10;

%% output file settings
outputFileName = '308_9B_Standrd_S2_NL_ON_FL_OFF.txt';
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
dieToSearch = [5,6,9,10];
dieToSearchLength = length(dieToSearch);
dieSize = length(dieToSearch)*4; %it has 4 sub sections
for idx=startFileIndex:endFileIndex
    
    DataFile1=fullfile(filePath,char(fNamelist(idx)));
    [bb,mod1,tile,die,frame_nr,delay,timestamp,p1,p2,p3,p4,temp,status,event_id,frame_counter] = textread(DataFile1,format,'delimiter',',','headerlines',12);
    
    ids = ismember(die,dieToSearch); %get binary indexes of the dies to extract
    
    if (length(dieToSearch)>1)
        %remove last lines to equaly devide the rows
        lastn = length(bb)-floor(length(bb)/dieSize)*dieSize;
        %bb = bb(1:end-lastn,:);
        %mod1 = mod1(1:end-lastn,:);
        %tile = tile(1:end-lastn,:);
        die = die(1:end-lastn,:);
        %frame_nr = frame_nr(1:end-lastn,:);
        %delay = delay(1:end-lastn,:);
        timestamp = timestamp(1:end-lastn,:);
        p1 = p1(1:end-lastn,:);
        p2 = p2(1:end-lastn,:);
        p3 = p3(1:end-lastn,:);
        p4 = p4(1:end-lastn,:);
        %temp = temp(1:end-lastn,:);
        %status = status(1:end-lastn,:);
        %event_id = event_id(1:end-lastn,:);
        frame_counter = frame_counter(1:end-lastn,:);
        ids = ids(1:end-lastn,:);
    end
    pixel = [die(ids) p1(ids) p2(ids) p3(ids) p4(ids) frame_counter(ids) timestamp(ids)];
    idx2=1;
    idxinside =1;
    while( idxinside<=(size(pixel,1)-dieToSearchLength))
        data = pixel(idxinside:idxinside+(dieToSearchLength-1),:);
        equalFramesBin = (pixel(idxinside+1:idxinside+(dieToSearchLength-1),6)==pixel(idxinside,6)); 
        equalFrames = sum(equalFramesBin);%3 means all 4 are same numbers
        %values = unique(pixel(idxinside:idxinside+3,6));
        %counts = histc(pixel(idxinside:idxinside+3,6), values);
        diesAfterCountsAll = pixel(idxinside:idxinside+(dieToSearchLength-1),1);
        diesforHit = diesAfterCountsAll(logical([1;equalFramesBin]));
        diesforMiss = diesAfterCountsAll(~logical([1;equalFramesBin]));
        %uniNums=unique(diesAfterCounts);
        %[countsDies, DiesIdx] = histc(diesAfterCounts, uniNums);
        if ((equalFrames+1)==numel(unique(diesforHit)))
            hitCount = (equalFrames+1);
            missCount = length(dieToSearch)-hitCount;
            if (hitCount>0)
                %[maxval, maxidx] = max(countsDies);
                %for i=idx2:max(countsDies)
                Active_array(idx2:idx2+(hitCount-1),:) = data(logical([1;equalFramesBin]),:);
                idx2=idx2+hitCount;
                idxinside=idxinside+hitCount;
                %end
            end
            if (missCount>0)
                miss_die = data(~logical([1;equalFramesBin]),1);
                % for i=idx2:sum(countsDies>1)
                Active_array(idx2:idx2+(length(miss_die)-1),:) = [miss_die,zeros(length(miss_die),1),zeros(length(miss_die),1),zeros(length(miss_die),1),zeros(length(miss_die),1),zeros(length(miss_die),1), data(~logical([1;equalFramesBin]),7)];
                %end
                idx2=idx2+length(miss_die);
            end
        else
            idxinside=idxinside+4;
        end
        
        %what if equal
        %for(
        %what if not-equal
        
        
    end
    Active_array(:,6) = []; %remove the frame count column
    dlmwrite(outputFileName,Active_array,'-append','precision', 16);
    clear Active_array; 
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
