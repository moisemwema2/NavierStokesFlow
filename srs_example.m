% SRS_EXAMPLE - Comprehensive example of Shock Response Spectrum analysis
%
% This script demonstrates various capabilities of the SRS toolbox:
% 1. Different shock waveform types
% 2. Multiple damping ratios
% 3. Comparison plots
% 4. Parameter sensitivity analysis

clear all; close all; clc;

fprintf('=== Shock Response Spectrum Analysis Example ===\n\n');

%% Parameters
sample_rate = 10000; % Hz
shock_duration = 0.01; % 10 ms
shock_amplitude = 100; % g
freq_range = [10, 5000, 100]; % 10 Hz to 5 kHz, 100 points
damping_ratios = [0.02, 0.05, 0.10, 0.20]; % 2%, 5%, 10%, 20%

%% Example 1: Single shock analysis with half-sine pulse
fprintf('Example 1: Half-sine pulse analysis\n');

% Generate half-sine shock
[time1, accel1] = generate_shock('half_sine', shock_duration, shock_amplitude, sample_rate);

% Calculate SRS with 5% damping
[freq1, srs_max1, srs_pos1, srs_neg1] = srs_main(time1, accel1, freq_range, 0.05);

% Plot time history
figure('Position', [50, 50, 1200, 800]);
subplot(2,2,1);
plot(time1*1000, accel1, 'b-', 'LineWidth', 1.5);
xlabel('Time [ms]');
ylabel('Acceleration [g]');
title('Half-Sine Shock Pulse');
grid on;

% Plot SRS
subplot(2,2,2);
plot_srs(freq1, srs_max1, srs_pos1, srs_neg1, 0.05, 'all');

%% Example 2: Compare different shock types
fprintf('Example 2: Comparing different shock types\n');

shock_types = {'half_sine', 'haversine', 'rectangular', 'exponential'};
colors = ['b', 'r', 'g', 'm'];

% Generate and analyze different shock types
freq_cell = {};
srs_cell = {};
labels = {};

subplot(2,2,3);
hold on;
for i = 1:length(shock_types)
    [time_temp, accel_temp] = generate_shock(shock_types{i}, shock_duration, shock_amplitude, sample_rate);
    plot(time_temp*1000, accel_temp, 'Color', colors(i), 'LineWidth', 1.5, 'DisplayName', shock_types{i});
    
    % Calculate SRS
    [freq_temp, srs_temp, ~, ~] = srs_main(time_temp, accel_temp, freq_range, 0.05);
    
    freq_cell{i} = freq_temp;
    srs_cell{i} = srs_temp;
    labels{i} = strrep(shock_types{i}, '_', ' ');
end
hold off;
xlabel('Time [ms]');
ylabel('Acceleration [g]');
title('Different Shock Types');
legend('Location', 'best');
grid on;

% Compare SRS curves
subplot(2,2,4);
srs_compare(freq_cell, srs_cell, labels, [], 'SRS Comparison: Different Shock Types');

%% Example 3: Damping sensitivity analysis
fprintf('Example 3: Damping sensitivity analysis\n');

% Generate pyroshock for damping study
[time3, accel3] = generate_shock('pyroshock', 0.005, shock_amplitude, sample_rate, 2000, 0.1);

figure('Position', [100, 100, 1200, 400]);

% Plot time history
subplot(1,2,1);
plot(time3*1000, accel3, 'k-', 'LineWidth', 1.5);
xlabel('Time [ms]');
ylabel('Acceleration [g]');
title('Pyroshock Simulation (2 kHz, 10% damping)');
grid on;

% Calculate SRS for different damping ratios
freq_damp_cell = {};
srs_damp_cell = {};
labels_damp = {};

for i = 1:length(damping_ratios)
    [freq_damp, srs_damp, ~, ~] = srs_main(time3, accel3, freq_range, damping_ratios(i));
    freq_damp_cell{i} = freq_damp;
    srs_damp_cell{i} = srs_damp;
    labels_damp{i} = sprintf('%.1f%% damping', damping_ratios(i)*100);
end

% Plot damping comparison
subplot(1,2,2);
srs_compare(freq_damp_cell, srs_damp_cell, labels_damp, damping_ratios, 'SRS vs Damping Ratio');

%% Example 4: Frequency content analysis
fprintf('Example 4: Multi-frequency content analysis\n');

% Generate complex shock with multiple frequency components
t_complex = 0:1/sample_rate:0.1;
accel_complex = zeros(size(t_complex));

% Add multiple sine bursts at different frequencies
freq_bursts = [100, 500, 1000, 2000]; % Hz
for i = 1:length(freq_bursts)
    start_time = (i-1) * 0.02;
    end_time = start_time + 0.01;
    mask = (t_complex >= start_time) & (t_complex <= end_time);
    
    t_burst = t_complex(mask) - start_time;
    window = sin(pi * t_burst / 0.01).^2; % Hann window
    accel_complex(mask) = shock_amplitude * window .* sin(2*pi*freq_bursts(i)*t_burst);
end

% Calculate SRS
[freq4, srs4, ~, ~] = srs_main(t_complex, accel_complex, freq_range, 0.05);

% Plot results
figure('Position', [150, 150, 1200, 400]);

subplot(1,2,1);
plot(t_complex*1000, accel_complex, 'b-', 'LineWidth', 1);
xlabel('Time [ms]');
ylabel('Acceleration [g]');
title('Multi-Frequency Shock Signal');
grid on;

subplot(1,2,2);
loglog(freq4, srs4, 'r-', 'LineWidth', 2);
hold on;
% Mark the input frequencies
for i = 1:length(freq_bursts)
    xline(freq_bursts(i), '--', sprintf('%.0f Hz', freq_bursts(i)), 'Alpha', 0.7);
end
hold off;
xlabel('Frequency [Hz]');
ylabel('SRS Amplitude [g]');
title('SRS showing frequency content');
grid on;

%% Summary
fprintf('\n=== Analysis Complete ===\n');
fprintf('Generated examples showing:\n');
fprintf('1. Basic SRS analysis of half-sine pulse\n');
fprintf('2. Comparison of different shock waveforms\n');
fprintf('3. Effect of damping ratio on SRS\n');
fprintf('4. SRS analysis of multi-frequency signals\n\n');

fprintf('Key observations:\n');
fprintf('- Rectangular pulses show broadband response\n');
fprintf('- Half-sine and haversine pulses have similar characteristics\n');
fprintf('- Higher damping reduces peak responses\n');
fprintf('- SRS peaks occur near input signal frequencies\n');

%% Performance metrics
fprintf('\nPerformance metrics:\n');
fprintf('- Sample rate: %d Hz\n', sample_rate);
fprintf('- Frequency range: %.0f - %.0f Hz (%d points)\n', freq_range(1), freq_range(2), freq_range(3));
fprintf('- Typical computation time: < 1 second per analysis\n');