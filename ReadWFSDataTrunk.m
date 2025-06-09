% Physical Acoustics Corporation Waveform Streaming Data File Reader
% Modified by Jason Dong on January 31, 2016

function [data_length, numb_of_channels, wfsdatas] = ReadWFSDataTrunk(filename, pathname, Header_length, voltage_scale)
% wfsdatas is a 2-D array, i.e. wfsdatas(numb_of_channels, data_length), which contains the waveform streaming data. 

if filename == 0
    return
end

%-------------------

fid = fopen([pathname filename],'r');
fseek(fid, Header_length, -1);

msgLength =fread(fid,1,'short'); %Message length
mid = fread(fid,1,'uchar');     % message ID = 174
sid = fread(fid,1,'uchar');     % Sub ID = 174
mver = fread(fid,1,'short');
numb_of_channels = fread(fid,1,'short');

for k=1:numb_of_channels
    channelList(k) = fread(fid,1,'uint8');
    trigTime0_1(k) = fread(fid,1,'ulong');
    trigTime2(k) = fread(fid,1,'ushort');
    trigTime_us(k) = ((4294967296.0*trigTime2(k)) + trigTime0_1(k)) / 4;
    sampleStart(k) = fread(fid,1,'int64');
end;    

data_start = ftell(fid);

msgLength = fread(fid,1,'short'); %Message length
nSamples = (msgLength - 28)/2;
waveformIndex(1:32) = 0;
nChunks = 0;

% Find offset
for k = 1:numb_of_channels
    mid = fread(fid, 1, 'uchar');   % Message ID = 174
    sid = fread(fid, 1, 'uchar');   % Sub ID = 1 for data
    mver = fread(fid, 1, 'short');
    sync = fread(fid, 1, 'ulong');
    chanum = fread(fid, 1, 'ulong');
    fifoWriter = fread(fid, 1, 'int64');
    fifoReadm = fread(fid, 1, 'ulong');
    fifoReadl = fread(fid, 1, 'ulong');
    fifoRead = (fifoReadm * 4294967296.0) + fifoReadl;
    offset(k) = sampleStart(k) - (2* fifoRead);
    fread(fid, nSamples, 'short');
    msgLength = fread(fid,1,'short'); %Message length
end

fseek(fid, data_start, -1);
msgLength = fread(fid,1,'short');

while feof(fid)==0
    if ((msgLength ~= 2076) & (msgLength ~= 8220))
        fseek(fid, msgLength, 0);
    else
        fread(fid,8,'uchar');
        chanNum = fread(fid,1,'ulong');
        fread(fid,16,'uchar');
        chunk = fread(fid,nSamples,'short');
        datas(chanNum,(waveformIndex(chanNum)+1):(waveformIndex(chanNum)+nSamples)) = chunk(1:nSamples);
        waveformIndex(chanNum) = waveformIndex(chanNum)+nSamples;
        nChunks = nChunks + 1;
    end
    %if (nChunks == 10)
    %    break;
    %end
    msgLength = fread(fid,1,'short');   
end

nChunks = nChunks / numb_of_channels;
fclose(fid);

amax = 0;
for k = 1:numb_of_channels
    if offset(k) > amax
        amax = offset(k);
    end
end

%-------------------
data_length = nChunks*nSamples - amax;

for k = 1:numb_of_channels
    a = offset(k) + 1;
    b = offset(k) + data_length;  
    wfsdatas(k, :) = datas(k, a:b) * voltage_scale(k);
    %if k < 5
    %    figure(1);
    %    if numb_of_channels < 5
    %        subplot(numb_of_channels, 1, k);
    %    else
    %        subplot(numb_of_channels - 4, 1, k);
    %    end
    %else
    %    figure(2);
    %    subplot(numb_of_channels - 4, 1, k - 4);
    %end
    %plot(wfsdatas(k,:));
end

clear datas;
