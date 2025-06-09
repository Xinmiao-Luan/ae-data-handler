% This function is to read data from a CSV file, selects a specific timestamp range,
% and saves the selected data to the workspace as 'selectedData'.
function [selectedData] = selectData(csvFilePath, startTimeStamp, endTimeStamp)

    % Read data from the CSV file
    mergedData = readmatrix(csvFilePath);

    % Extract timestamps from the first column
    timestamps = mergedData(:, 1);

    % Select data within the specified timestamp range
    inRange = timestamps >= startTimeStamp & timestamps <= endTimeStamp;
    selectedData = mergedData(inRange, :);

end
