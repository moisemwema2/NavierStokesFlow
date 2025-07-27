function srs_compare(freq_cell, srs_cell, labels, damping_values, title_str)
% SRS_COMPARE - Compare multiple SRS curves
%
% Plots multiple shock response spectra on the same figure for comparison
%
% INPUTS:
%   freq_cell      - Cell array of frequency vectors
%   srs_cell       - Cell array of SRS vectors
%   labels         - Cell array of labels for each curve
%   damping_values - Vector of damping ratios (optional)
%   title_str      - Plot title (optional)

if nargin < 3
    labels = cell(length(srs_cell), 1);
    for i = 1:length(srs_cell)
        labels{i} = sprintf('SRS %d', i);
    end
end

if nargin < 4
    damping_values = [];
end

if nargin < 5
    title_str = 'Shock Response Spectrum Comparison';
end

% Input validation
if length(freq_cell) ~= length(srs_cell) || length(freq_cell) ~= length(labels)
    error('All input cell arrays must have the same length');
end

% Create figure
figure('Position', [100, 100, 1000, 600]);

% Color map for multiple curves
colors = lines(length(srs_cell));
line_styles = {'-', '--', '-.', ':', '-', '--', '-.', ':'};

% Plot each SRS curve
hold on;
for i = 1:length(srs_cell)
    freq = freq_cell{i};
    srs = srs_cell{i};
    
    if ~isempty(damping_values) && length(damping_values) >= i
        label_str = sprintf('%s (ζ=%.1f%%)', labels{i}, damping_values(i)*100);
    else
        label_str = labels{i};
    end
    
    loglog(freq, srs, 'Color', colors(i,:), ...
           'LineStyle', line_styles{mod(i-1, length(line_styles))+1}, ...
           'LineWidth', 2, 'DisplayName', label_str);
end
hold off;

% Format plot
xlabel('Frequency [Hz]');
ylabel('Response Amplitude');
title(title_str);
grid on;
legend('Location', 'best');
set(gca, 'FontSize', 12);
set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

% Set axis limits based on data range
all_freq = [];
all_srs = [];
for i = 1:length(freq_cell)
    all_freq = [all_freq; freq_cell{i}(:)];
    all_srs = [all_srs; srs_cell{i}(:)];
end

xlim([min(all_freq), max(all_freq)]);
ylim([min(all_srs(all_srs>0))*0.5, max(all_srs)*2]);

% Add frequency decade markers
decade_freqs = [1, 10, 100, 1000, 10000];
decade_freqs = decade_freqs(decade_freqs >= min(all_freq) & decade_freqs <= max(all_freq));
for i = 1:length(decade_freqs)
    xline(decade_freqs(i), '--', 'Alpha', 0.2, 'Color', [0.5 0.5 0.5]);
end

end