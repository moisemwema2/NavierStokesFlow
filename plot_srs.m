function plot_srs(freq, srs_max, srs_pos, srs_neg, damping, method)
% PLOT_SRS - Plot Shock Response Spectrum
%
% Creates publication-quality plots of shock response spectrum data
%
% INPUTS:
%   freq     - Frequency vector [Hz]
%   srs_max  - Maximum absolute response
%   srs_pos  - Maximum positive response  
%   srs_neg  - Maximum negative response
%   damping  - Damping ratio used
%   method   - Plot method ('absolute', 'positive', 'negative', or 'all')

if nargin < 6
    method = 'all';
end

% Create figure
figure('Position', [100, 100, 1000, 600]);

switch lower(method)
    case 'absolute'
        loglog(freq, srs_max, 'b-', 'LineWidth', 2);
        ylabel('Maximum Absolute Response');
        title(sprintf('Shock Response Spectrum (Absolute) - Damping = %.1f%%', damping*100));
        legend('Absolute Maximum', 'Location', 'best');
        
    case 'positive'
        loglog(freq, srs_pos, 'r-', 'LineWidth', 2);
        ylabel('Maximum Positive Response');
        title(sprintf('Shock Response Spectrum (Positive) - Damping = %.1f%%', damping*100));
        legend('Positive Maximum', 'Location', 'best');
        
    case 'negative'
        loglog(freq, srs_neg, 'g-', 'LineWidth', 2);
        ylabel('Maximum Negative Response');
        title(sprintf('Shock Response Spectrum (Negative) - Damping = %.1f%%', damping*100));
        legend('Negative Maximum', 'Location', 'best');
        
    case 'all'
        loglog(freq, srs_max, 'b-', 'LineWidth', 2); hold on;
        loglog(freq, srs_pos, 'r--', 'LineWidth', 1.5);
        loglog(freq, srs_neg, 'g--', 'LineWidth', 1.5);
        ylabel('Response Amplitude');
        title(sprintf('Shock Response Spectrum - Damping = %.1f%%', damping*100));
        legend('Absolute Maximum', 'Positive Maximum', 'Negative Maximum', 'Location', 'best');
        hold off;
end

% Format plot
xlabel('Frequency [Hz]');
grid on;
set(gca, 'FontSize', 12);
set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

% Add frequency guidelines
xlim([min(freq), max(freq)]);
ylim([min(srs_max(srs_max>0))*0.5, max(srs_max)*2]);

% Add annotations
text(0.02, 0.98, sprintf('Damping Ratio: %.1f%%', damping*100), ...
     'Units', 'normalized', 'VerticalAlignment', 'top', ...
     'BackgroundColor', 'white', 'EdgeColor', 'black');

% Add frequency decade markers
decade_freqs = [1, 10, 100, 1000, 10000];
decade_freqs = decade_freqs(decade_freqs >= min(freq) & decade_freqs <= max(freq));
for i = 1:length(decade_freqs)
    xline(decade_freqs(i), '--', 'Alpha', 0.3, 'Color', [0.5 0.5 0.5]);
end

end