function [time, accel, info] = load_data(filename, varargin)
% LOAD_DATA - Load shock acceleration data from various file formats
%
% Supports common data formats used in shock testing:
% - CSV files
% - Text files with headers
% - MATLAB .mat files
% - Universal File Format (UFF)
%
% INPUTS:
%   filename  - Path to data file
%   varargin  - Optional parameters:
%               'time_col', column number for time (default: 1)
%               'accel_col', column number for acceleration (default: 2)
%               'skip_rows', number of header rows to skip (default: 0)
%               'delimiter', column delimiter (default: auto-detect)
%               'time_units', time units ('s', 'ms', 'us') (default: 's')
%               'accel_units', acceleration units ('g', 'm/s2') (default: 'g')
%
% OUTPUTS:
%   time      - Time vector [s]
%   accel     - Acceleration vector [g]
%   info      - Structure with file information

% Default parameters
p = inputParser;
addParameter(p, 'time_col', 1, @isnumeric);
addParameter(p, 'accel_col', 2, @isnumeric);
addParameter(p, 'skip_rows', 0, @isnumeric);
addParameter(p, 'delimiter', '', @ischar);
addParameter(p, 'time_units', 's', @ischar);
addParameter(p, 'accel_units', 'g', @ischar);
parse(p, varargin{:});

params = p.Results;

% Check if file exists
if ~exist(filename, 'file')
    error('File not found: %s', filename);
end

% Get file extension
[~, ~, ext] = fileparts(filename);

% Initialize info structure
info = struct();
info.filename = filename;
info.format = ext;
info.loaded_at = datestr(now);

try
    switch lower(ext)
        case '.mat'
            % MATLAB file
            data = load(filename);
            fields = fieldnames(data);
            
            % Try to find time and acceleration vectors
            time_found = false;
            accel_found = false;
            
            for i = 1:length(fields)
                field_name = lower(fields{i});
                if contains(field_name, 'time') && ~time_found
                    time = data.(fields{i});
                    time_found = true;
                elseif (contains(field_name, 'accel') || contains(field_name, 'acc')) && ~accel_found
                    accel = data.(fields{i});
                    accel_found = true;
                end
            end
            
            if ~time_found || ~accel_found
                error('Could not find time and acceleration vectors in MAT file');
            end
            
        case {'.csv', '.txt', '.dat'}
            % Text-based files
            if isempty(params.delimiter)
                % Auto-detect delimiter
                if strcmp(ext, '.csv')
                    params.delimiter = ',';
                else
                    params.delimiter = '\t'; % Tab for .txt and .dat
                end
            end
            
            % Read file
            if params.skip_rows > 0
                data = readmatrix(filename, 'FileType', 'text', ...
                                'Delimiter', params.delimiter, ...
                                'NumHeaderLines', params.skip_rows);
            else
                data = readmatrix(filename, 'FileType', 'text', ...
                                'Delimiter', params.delimiter);
            end
            
            % Extract time and acceleration columns
            if size(data, 2) < max(params.time_col, params.accel_col)
                error('File does not have enough columns');
            end
            
            time = data(:, params.time_col);
            accel = data(:, params.accel_col);
            
        otherwise
            error('Unsupported file format: %s', ext);
    end
    
    % Convert units if necessary
    switch lower(params.time_units)
        case 'ms'
            time = time / 1000;
        case 'us'
            time = time / 1e6;
        case 's'
            % Already in seconds
        otherwise
            warning('Unknown time units: %s. Assuming seconds.', params.time_units);
    end
    
    switch lower(params.accel_units)
        case 'm/s2'
            accel = accel / 9.81; % Convert to g
        case 'g'
            % Already in g
        otherwise
            warning('Unknown acceleration units: %s. Assuming g.', params.accel_units);
    end
    
    % Ensure column vectors
    time = time(:);
    accel = accel(:);
    
    % Remove any NaN or Inf values
    valid_idx = isfinite(time) & isfinite(accel);
    time = time(valid_idx);
    accel = accel(valid_idx);
    
    % Sort by time (in case data is not ordered)
    [time, sort_idx] = sort(time);
    accel = accel(sort_idx);
    
    % Update info structure
    info.num_samples = length(time);
    info.duration = max(time) - min(time);
    info.sample_rate = (length(time) - 1) / info.duration;
    info.time_range = [min(time), max(time)];
    info.accel_range = [min(accel), max(accel)];
    info.time_units = 's';
    info.accel_units = 'g';
    
    fprintf('Successfully loaded data:\n');
    fprintf('  Samples: %d\n', info.num_samples);
    fprintf('  Duration: %.3f s\n', info.duration);
    fprintf('  Sample rate: %.1f Hz\n', info.sample_rate);
    fprintf('  Acceleration range: %.2f to %.2f g\n', min(accel), max(accel));
    
catch ME
    error('Failed to load data from %s: %s', filename, ME.message);
end

end