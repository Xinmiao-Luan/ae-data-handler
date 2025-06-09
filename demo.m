% read in original files and merge data
basePath = '/Users/xluan3/Dropbox (ASU)/WANG Group/Projects/AM data_acoustic_3_20231117/1dry print/';
filePattern = 'STREAM20230822*';
readMultipleFiles(basePath, filePattern, 0, 1);

% select data and save it to the selected data
csvFilePath = '/Users/xluan3/Dropbox (ASU)/WANG Group/Projects/AM data_acoustic_3_20231117/1dry print/mergedData.csv';
selectedData = selectData(csvFilePath, 20230822172029, 20230822172041);

% plot waveform
plotWaveform(selectedData);
% % if you want to plot all merged data
% plotWaveform(mergedData); 