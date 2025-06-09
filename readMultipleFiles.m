%  by Xinmiao Luan on December 13, 2023 
%  modified from Jason Dong on January 31, 2016

%% readMultipleFiles: Process and optionally save data from multiple files
% This function processes multiple data files in a specified directory that
% match a given filename pattern. It reads each file's header and data, transposes 
% the data, and optionally saves each file's data into separate CSV files. Additionally, 
% it can merge all the processed data into a single CSV file and include a timestamp
% extracted from each file's name. The merged data is also saved to the MATLAB workspace.

% Inputs:
    %  basePath - The directory path where the files are located.
    %  filePattern - The pattern that the filenames start with.
    %  saveCSV - to determine whether to save output as multiple CSV files.
    %  mergeCSV - to determine whether to save output as one merged CSV file.
    %  0 - do not save; 1 - save.
      
% e.g.
% basePath = '/Users/xluan3/Dropbox (ASU)/WANG Group/Projects/AM data_acoustic_3_20231117/1dry print/';
% filePattern = 'STREAM20230822*';
% readMultipleFiles(basePath, filePattern, 0, 1);

function readMultipleFiles(basePath, filePattern, saveCSV, mergeCSV)
    % Initialize variables to store all data and timestamps for merging
    allData = [];
    allTimestamps = [];

    % Construct the full file pattern
    fullPattern = fullfile(basePath, filePattern);

    % Find all files that match the pattern
    files = dir(fullPattern);

    % Check if any files are found
    if isempty(files)
        disp('No files found matching the pattern.');
        return;
    end

    % Process each file
    for k = 1:length(files)
        fullFileName = fullfile(files(k).folder, files(k).name);
        fprintf('Processing %s...\n', fullFileName);

        % Extract filename and path
        [pathname, name, ext] = fileparts(fullFileName);
        filename = [name, ext];
        pathname = [pathname, filesep];

        % Read file header and data
        [Number_of_channels, sample_rate, Pretrigger, Max_voltage, Header_length, Timestamp, SVersion, ChannelNumbers] = ReadWFSHeader(pathname, filename); 
        voltage_scale = 1000 * Max_voltage / 32767;
        fs = sample_rate * 1e3;
        [data_len, nchannels, datas] = ReadWFSDataTrunk(filename, pathname, Header_length, voltage_scale);
        p_data = transpose(datas);

        % Extract timestamp from the filename
        % filename format is 'STREAMYYYYMMDD-HHMMSS-XXX.wfs'
        timestampStr = regexp(filename, '\d{8}-\d{6}', 'match');
        if ~isempty(timestampStr)
            timestampStr = strrep(timestampStr{1}, '-', '');
            timestamp = repmat(str2double(timestampStr), size(p_data, 1), 1);
        else
            timestamp = zeros(size(p_data, 1), 1);
        end

        % Concatenate the current timestamp and data for merging
        if mergeCSV
            allData = [allData; [timestamp, p_data]];
            allTimestamps = [allTimestamps; timestamp];
        end

        % Save each file's data to a separate CSV file, if requested
        if saveCSV
            csvFileName = fullfile(pathname, [filename, '.csv']);
            writematrix(p_data, csvFileName);
        end

%         % Optionally, plot the first channel data
%         figure(k);
%         plot(datas(2,:));
%         grid;
%         title(['Data Plot for ', filename]);
    end

    % Save the combined data to a single CSV file and MATLAB workspace if merging is requested
    if mergeCSV
        mergedCSVFileName = fullfile(basePath, 'MergedData.csv');
        writematrix(allData, mergedCSVFileName);
        disp(['Merged data saved to ', mergedCSVFileName]);

        % Assign the merged data to the MATLAB workspace
        assignin('base', 'mergedData', allData);
        assignin('base', 'mergedTimestamps', allTimestamps);
    end
end
