%% To download CHESS Data (about 4.9 TB in total) - 306 x4 x4

% on my home wifi I can download 83 files equivalent to 8.3 GB of data in
% 5min.

% Last used 22/06/2024 - TO RUN WHEN SERVER IS BACK UP +++++++++

% Define base URL and save directory to then work on below
baseURLTemplate = 'https://dap.ceda.ac.uk/badc/deposited2021/chess-scape/data/rcp%s_bias-corrected/';
%saveDirTemplate = 'C:\\Users\\jordi\\OneDrive - Imperial College London\\Desktop\\Paper 2\\CHESS_example\\CHESS\\rcp%s_bias-corrected\\';

saveDirTemplate = 'D:\\CHESS_example\\CHESS\\rcp%s_bias-corrected\\';


% Loop through the RCP climate scenarios, we have four in total (RCP 2.6,
% 4.5,6 and 8.5)
for scenario = {'85','45'} % = {'26', '45', '60', '85'}
    % Build base URL and save directory 
    baseURL = sprintf(baseURLTemplate, scenario{1});
    saveDir = sprintf(saveDirTemplate, scenario{1});
    
    for EM = {'01', '04', '06', '15'} % they give us 4 EM... out of the 12 available ( I think...)
            % Build base URL and save directory 
        baseURL2= [baseURL EM{1} '/daily/'];
        saveDir2 = [saveDir EM{1} '\']; % '\daily\'

        for variable = { 'huss', 'pr', 'rlds','rsds','sfcWind','tas'} % 'hurs',
                baseURL3= [baseURL2 variable{1} '/chess-scape_rcp',scenario{1}, '_bias-corrected_',EM{1},'_',variable{1},'_uk_1km_daily_'];
                saveDir3 =[saveDir2 variable{1} '\'];

                for year = 1981:2079
                    for month = 1:12
                        % Construct URL for each file
                        startDate = sprintf('%d%02d01', year ,month);
                        endDate = sprintf('%d%02d30', year, month); % assuming all months have 30 days
                        fileURL = [baseURL3 startDate '-' endDate '.nc?download=1'];
                       
                        % Construct filename
                        filename = sprintf('chess-scape_rcp%s_%02d_%s_uk_1km_daily_%d%02d01-%d%02d30.nc', scenario{1}, str2double(EM{1}), variable{1}, year, month, year, month);
                                               
                        %pause(10); % depending on the day this can help !
                        disp(['Downloading ' filename '...'])
                        while true % the CEDA website can be a bit moody, so this is a just in case...
                            try
                                % Download the file
                                websave(fullfile(saveDir3, filename), fileURL);
                                disp(['Saved ' filename]);
                                % Exit the loop if download is successful
                                break;
                            catch
                                % Display error message % important as lag
                                % with the server
                                disp(['Error downloading ' filename]);
                                % Wait for 30 seconds before next attempt
                                disp('Retrying in 20 seconds...');
                                pause(20);
                            end
                        end
                    end
                end
        end
    end
end

%% Sanity Check to make sure we are doing the right thing...

automatic_file = 'C:\Users\jordi\OneDrive - Imperial College London\Desktop\Paper 2\CHESS_example\CHESS\rcp26_bias-corrected\01\hurs\chess-scape_rcp26_01_hurs_uk_1km_daily_19811101-19811130.nc';
hurs_data = ncread(automatic_file, 'hurs');
first_slice = squeeze(hurs_data(234, :, :)); % just this dimension
plot(first_slice(:,13),'k')
hold on
manualfile = "C:\Users\jordi\OneDrive - Imperial College London\Desktop\Paper 2\CHESS_example\CHESS\test\chess-scape_rcp26_bias-corrected_01_hurs_uk_1km_daily_19811101-19811130.nc";
hurs_data1 = ncread(manualfile, 'hurs');
first_slice1 = squeeze(hurs_data1(234, :, :)); % just this dimension
plot(first_slice1(:,13),'r','LineStyle','-.')

%Check to see they are the same... test passed !!! wahooo ! 

%%

% Define the file path
filePath = 'D:\CHESS DATA\Pr\chess-scape_rcp26_01_pr_uk_1km_daily_19810101-19810130.nc';

% Read longitude, latitude, and precipitation data
lon = ncread(filePath, 'lon');
lat = ncread(filePath, 'lat');
pr = ncread(filePath, 'pr');

% Load the indices table
csvFilePath = 'D:\CHESSSCAPE\indices_table.csv';
indices = readtable(csvFilePath);

delete all values in the .nc file which are not in one of the indices then resave the .nc file



%%
% Define the file paths
ncFilePath = 'D:\CHESS DATA\Pr\chess-scape_rcp26_01_pr_uk_1km_daily_19810101-19810130TEST.nc';
csvFilePath = 'D:\CHESSSCAPE\indices_table.csv';

% Read precipitation data
pr = ncread(ncFilePath, 'pr');

% Load the indices table
indices = readtable(csvFilePath);

% Create a logical mask to identify the indices that are not present in the 'indices_table.csv'
mask = true(size(pr, 1), size(pr, 2)); % Initialize mask as true
for i = 1:height(indices)
    x_index = indices.x_indices(i);
    y_index = indices.y_indices(i);
    mask(x_index, y_index) = false; % Set indices in mask corresponding to 'indices_table.csv' to false
end

% Set the unwanted values in 'pr' to NaN
pr(mask) = NaN;
non_nan_count = sum(~isnan(pr(:, :, 1)), 'all') % seems to have worked

% Resave the NetCDF file with the updated 'pr' variable
nccreate(ncFilePath, 'pr', 'Dimensions', {'lon', size(pr, 1), 'lat', size(pr, 2), 'time', size(pr, 3)});
ncwrite(ncFilePath, 'pr', pr);

disp('NetCDF file updated and resaved.');

% The new file I made was 5 times larger in size... didnt work ... need
% plan b 


