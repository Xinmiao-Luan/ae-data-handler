% Physical Acoustics Corporation Waveform Streaming Data File Reader
% CHANGED 01/09/04, 06/25/08
% Modified by Jason Dong on January 31, 2016

function [Number_of_channels,Sample_rate,Pretrigger,Max_voltage,Header_length,Timestamp,SVersion,ChannelNumbers]=ReadWFSHeader(pathname, filename)

fid = fopen([pathname filename],'r');

% Product ID
Header.Size_table1 = fread(fid,1,'short');
Header.PRODUCTID = fread(fid,1,'uint8');
Header.space = fread(fid,1,'int8');
Header.block1 = fread(fid,1,'short');
Header.SModel=fread(fid,Header.Size_table1-4,'char'); % /r /n
%amodel = char(Header.SModel(1:findstr(char(Header.SModel'),' ')))'
amodel = char(Header.SModel(1:3))';
%Header.SVer=str2num(char(Header.SModel(findstr(char(Header.SModel'),'Version E')+9:findstr(char(Header.SModel'),'Version E')+12'))');
Header.SVer=str2num(char(Header.SModel(findstr(char(Header.SModel'),'.')-1:findstr(char(Header.SModel'),'.')+2'))');
fcoef = 1.0;

% Define Group
Header.Size_table2 = fread(fid,1,'short');  % Message size
Header.ID174 = fread(fid,1,'uint8');        % ID = 174 Always
Header.SubID106 = fread(fid,1,'uint8');     % SubID = 106 Always
Header.Group_number  = fread(fid,1,'int8'); % Group number = 1 Always
Header.Number_of_channels = fread(fid,1,'int8');
%Header.N_Channels = fread(fid,Header.Number_of_channels,'int8');
for k=1:Header.Number_of_channels
    Header.channelList(k) = fread(fid,1,'int8');
end

%How to know it should start a loop for table and ID search?
% Hardware Setup
for i=1:Header.Number_of_channels
    Header.Size_table3(i) = fread(fid,1,'short');
    Header.ID212_2(i) = fread(fid,1,'uint8'); %ID212
    Header.S488ID(i) = fread(fid,1,'uint8'); % S488ID
    Header.Version(i) = fread(fid,1,'short'); % Version
    Header.Adbits(i) = fread(fid,1,'int8'); % Adbits 110? 
    Header.Channel_number(i) = fread(fid,1,'uint8'); % Channel number 
    Header.Hardware_size(i) = fread(fid,1,'ulong'); % Size of data blodk;
    %Header.ChannelNumber = fread(fid,1,'int8');  % Channel number
    Header.Reserved(i) = fread(fid,1,'short'); % fread(fid,1,'ulong')
    Header.sample_rate(i) = fread(fid,1,'short');
    Header.Trigger_mode(i) = fread(fid,1,'short');
    Header.Trigger_type(i) = fread(fid,1,'short');
    Header.pretrigger(i) = fread(fid,1,'int32');
    %Header.ULong_2(i) = fread(fid,1,'short'); % fread(fid,1,'ulong')
    Header.maxvoltage(i) = fread(fid,1,'short');
    Header.Short(i) = fread(fid,1,'short');
end;

if (strcmp(amodel, 'Exp') || strcmp(amodel, 'PCI')) && Header.SVer < 5.0   

% TABLE 4
    Header.Size_table4 =fread(fid,1,'short'); %Message length
    Header.Table4_ID174 = fread(fid,1,'uint8');    % ID 174
    Header.Table4_subID20 = fread(fid,1,'uint8');   %Sub ID 20
    Header.Table4_message_version = fread(fid,1,'short'); % Message version
    Header.Table4_Active_Channels = fread(fid,1,'short'); % Number of active channels
    %Header.Table4_int8 = fread(fid,5,'int8');
    for i=1:Header.Number_of_channels
        Header.Table4_Channel_Number(i) = fread(fid, 1,'int8');
        Header.Table4_Channel_PreGain(i) = fread(fid, 1,'int8');
    end;

% ADDITIONAL HEADER INFO INCLUDED FROM VERSION AEWIN v1.53 ONWARDS
    if Header.SVer>1.53
        Header.Size_table5 =fread(fid,1,'short');
        Header.Table5_ID174 = fread(fid,1,'uint8');    % ID 174
        Header.Table5_subID23 = fread(fid,1,'uint8'); % Sub ID 23
        Header.Table5_message_version = fread(fid,1,'short'); % Message version
        Header.Table5_Active_Channels = fread(fid,1,'short'); % Number of active channels
        %Header.Table5_int8 = fread(fid,5,'int8');
        for i=1:Header.Number_of_channels
            Header.Table5_ch(i) = fread(fid,1,'int8');
            Header.Table5_gain(i) = fread(fid,1,'int8');
        end;
    end;

    for i=1:Header.Number_of_channels
        Header.Table5_short(i) = fread(fid,1,'short');
        Header.Table5_uint8s(i) = fread(fid,1,'uint8');
        Header.Table5_int8s(i, :) = fread(fid,4,'int8');
    end;

else
    Header.Size_table4 =fread(fid,1,'short'); %Message length 22
    Header.Table4_ID174 = fread(fid,1,'uint8');    % ID 174
    %fread(fid,Header.Size_table4 - 1, 'uint8');     % Sub ID 20
    
    Header.Table4_subID20 = fread(fid,1,'uint8');   %Sub ID 20
    Header.Table4_message_version = fread(fid,1,'short'); % Message version
    Header.Table4_Active_Channels = fread(fid,1,'short'); % Number of active channels
    for i=1:Header.Number_of_channels
        Header.Table4_Channel_Number(i) = fread(fid, 1,'int8');
        Header.Table4_Channel_PreGain(i) = fread(fid, 1,'int8');
    end;
    %Header.Table4_Channel_PreGain(:)
    
    Header.Size_table5 =fread(fid,1,'short'); %Message length 22
    Header.Table5_ID174 = fread(fid,1,'uint8');    % ID 174
    %fread(fid,Header.Size_table5 - 1, 'uint8');     % Sub ID 23

    Header.Table5_subID23 = fread(fid,1,'uint8'); % Sub ID 23
    Header.Table5_message_version = fread(fid,1,'short'); % Message version
    Header.Table5_Active_Channels = fread(fid,1,'short'); % Number of active channels
    for i=1:Header.Number_of_channels
        Header.Table5_ch(i) = fread(fid,1,'int8');
        Header.Table5_gain(i) = fread(fid,1,'int8');
    end;    
    %Header.Table5_gain(i)
    
    Header.Preamp_Message =fread(fid,1,'short'); %Message length 62
    Header.Preamp_ID174 = fread(fid,1,'uint8');    % ID 174
    atemp = fread(fid,Header.Preamp_Message - 1, 'uint8');   %Sub ID 33
    %atemp(9)
    if atemp(9) == 5
        fcoef = 0.2;
    end
    if Header.Table5_gain(1) == 6
        fcoef = fcoef / 2;
    elseif Header.Table5_gain(1) == 12
        fcoef = fcoef / 4;
    end
    
    for i=1:Header.Number_of_channels
        Header.AFilter_Message(i) = fread(fid,1,'short'); % Message length 5
        Header.AFilter_IDs(i) = fread(fid,1,'uint8'); % ID 137
        Header.AFilter_Bytes(i, :) = fread(fid,4,'int8'); % 4 Chars
    end;
    
    for i=1:Header.Number_of_channels
        Header.DFilter_Message(i) = fread(fid,1,'short'); % Message length 5
        Header.DFilter_IDs(i) = fread(fid,1,'uint8'); % ID 146
        Header.DFilter_Bytes(i, :) = fread(fid,9,'int8'); % 9 Chars
    end;
    
end % End of if SVer < 50

% TABLE 6
Header.Size_table6 = fread(fid,1,'short'); % Message length 27
Header.Table6_Time_Data_ID = fread(fid,1,'uint8'); %Time and date ID 99
Header.Timestamp=char(fread(fid,Header.Size_table6-1,'char')); % Read 26 bypes.
%char(Header.Timestamp)'

% TABLE 7
Header.Size_table7 = fread(fid,1,'short');  % Length = 0
Header.Table7_uint8 = fread(fid,1,'uint8'); % ID = 11
%fread(fid,1,'short');


% TABLE 8
    Header.Size_table8 = fread(fid,1,'short');  % Length = 6
    Header.Table8_uint8 = fread(fid,1,'uint8'); % "RESUME" CODE 128. ID = 128
    Header.Table8_short = fread(fid,3,'short'); % Skip 6 bytes (3 Shorts)

    %Header.Size_table9 =fread(fid,1,'short'); %Message length
    %Header.Table9_ID174 = fread(fid,1,'uint8');    % ID 174
    %fread(fid,Header.Size_table9 - 1, 'uint8');    

    %Header.Size_table10 =fread(fid,1,'short'); %Message length
    %Header.Table10_ID174 = fread(fid,1,'uint8');    % ID 174
    %fread(fid,Header.Size_table10 - 1, 'uint8');     % Sub ID 1

Header.Length_of_header=ftell(fid);

fclose(fid);

Number_of_channels=Header.Number_of_channels;
Sample_rate=Header.sample_rate;
Pretrigger=Header.pretrigger;
Max_voltage=Header.maxvoltage * fcoef;
Header_length=Header.Length_of_header;
Timestamp=char(Header.Timestamp)';
SVersion=char(Header.SModel)';
ChannelNumbers = Header.channelList;

%Header

