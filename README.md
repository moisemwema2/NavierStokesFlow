# Shock Response Spectrum (SRS) Analysis Toolbox

A comprehensive MATLAB/Octave toolbox for calculating and analyzing shock response spectra of acceleration time histories.

## Overview

The Shock Response Spectrum (SRS) is a fundamental tool in shock and vibration analysis, used to characterize the severity of transient events on structures and equipment. This toolbox provides a complete set of functions for:

- Calculating SRS from acceleration time histories
- Generating standard shock waveforms for testing
- Comparing multiple SRS curves
- Analyzing the effects of damping
- Loading experimental data from various formats

## Features

### Core Functions

- **`srs_main.m`** - Main SRS calculation engine
- **`sdof_response.m`** - Single degree of freedom response calculation
- **`plot_srs.m`** - Professional SRS plotting with multiple options
- **`srs_compare.m`** - Multi-curve comparison plots
- **`generate_shock.m`** - Standard shock waveform generator
- **`load_data.m`** - Data import from various file formats

### Supported Shock Types

- Half-sine pulse
- Haversine (raised cosine)
- Rectangular pulse
- Sawtooth pulse
- Terminal peak sawtooth
- Exponential decay
- Pyroshock simulation
- Double exponential (ballistic shock)

### Analysis Capabilities

- Multiple damping ratios (typically 2-20%)
- Frequency ranges from 1 Hz to 50+ kHz
- Positive, negative, and absolute maximum responses
- Time domain visualization
- Parametric studies

## Quick Start

### Basic SRS Analysis

```matlab
% Generate a half-sine shock pulse
[time, accel] = generate_shock('half_sine', 0.01, 100, 10000);

% Calculate SRS with 5% damping
freq_range = [10, 5000, 100]; % 10 Hz to 5 kHz, 100 points
[freq, srs_max, srs_pos, srs_neg] = srs_main(time, accel, freq_range, 0.05);

% Plot results
plot_srs(freq, srs_max, srs_pos, srs_neg, 0.05, 'all');
```

### Compare Different Shock Types

```matlab
shock_types = {'half_sine', 'rectangular', 'exponential'};
freq_cell = {};
srs_cell = {};
labels = {};

for i = 1:length(shock_types)
    [time, accel] = generate_shock(shock_types{i}, 0.01, 100, 10000);
    [freq, srs, ~, ~] = srs_main(time, accel, [10, 5000, 100], 0.05);
    
    freq_cell{i} = freq;
    srs_cell{i} = srs;
    labels{i} = shock_types{i};
end

srs_compare(freq_cell, srs_cell, labels);
```

### Load Experimental Data

```matlab
% Load from CSV file
[time, accel, info] = load_data('shock_test.csv', 'skip_rows', 1, ...
                               'time_units', 'ms', 'accel_units', 'g');

% Calculate SRS
[freq, srs, ~, ~] = srs_main(time, accel, [10, 10000, 150], 0.05);
```

## Function Reference

### srs_main(time, accel, freq_range, damping, method)

Main SRS calculation function.

**Inputs:**
- `time` - Time vector [s]
- `accel` - Acceleration time history [g or m/s²]
- `freq_range` - [min_freq, max_freq, num_points] [Hz]
- `damping` - Damping ratio (default: 0.05)
- `method` - 'absolute', 'positive', 'negative', or 'all'

**Outputs:**
- `freq` - Frequency vector [Hz]
- `srs_max` - Maximum absolute response
- `srs_pos` - Maximum positive response
- `srs_neg` - Maximum negative response

### generate_shock(shock_type, duration, amplitude, sample_rate, ...)

Generate standard shock waveforms.

**Parameters:**
- `shock_type` - Type of shock waveform
- `duration` - Shock duration [s]
- `amplitude` - Peak amplitude [g]
- `sample_rate` - Sampling rate [Hz]

**Additional parameters by shock type:**
- `'sawtooth'` - direction: 'up' or 'down'
- `'exponential'` - decay_constant [1/s]
- `'pyroshock'` - frequency [Hz], damping ratio
- `'double_exponential'` - tau1, tau2 [s]

## Theory

The shock response spectrum represents the maximum response of a series of single degree of freedom (SDOF) oscillators to a given shock input. Each oscillator has a different natural frequency but the same damping ratio.

For an SDOF system with:
- Natural frequency: ωₙ = 2πf
- Damping ratio: ζ
- Input acceleration: ü(t)

The equation of motion is:
```
ẍ + 2ζωₙẋ + ωₙ²x = -ü(t)
```

The SRS value at frequency f is the maximum absolute displacement response of the corresponding SDOF oscillator.

### Damping Effects

- **Low damping (ζ < 5%)**: Higher peak responses, more oscillatory
- **High damping (ζ > 20%)**: Lower peaks, more stable response
- **Critical damping (ζ = 100%)**: Fastest settling without overshoot

## Applications

### Aerospace
- Spacecraft launch environments
- Pyroshock from explosive devices
- Landing impact analysis

### Automotive
- Crash test analysis
- Component shock testing
- Transportation vibration

### Military/Defense
- Weapon system shock qualification
- Blast response analysis
- Equipment survivability testing

### Electronics
- Drop test analysis
- Transportation shock
- Component qualification

## Example Workflows

### 1. Standard Shock Test Analysis
```matlab
% Run the comprehensive example
srs_example;
```

### 2. Parametric Study
```matlab
% Study effect of shock duration
durations = [0.005, 0.01, 0.02, 0.05]; % seconds
for i = 1:length(durations)
    [time, accel] = generate_shock('half_sine', durations(i), 100, 10000);
    [freq, srs, ~, ~] = srs_main(time, accel, [10, 5000, 100], 0.05);
    % Store and compare results
end
```

### 3. Multi-Axis Analysis
```matlab
% Analyze X, Y, Z acceleration data
axes = {'X', 'Y', 'Z'};
for i = 1:3
    filename = sprintf('shock_test_%s.csv', axes{i});
    [time, accel, ~] = load_data(filename);
    [freq, srs, ~, ~] = srs_main(time, accel, [10, 10000, 150], 0.05);
    % Compare responses
end
```

## Performance Notes

- Typical computation time: < 1 second for 100 frequency points
- Memory usage scales with frequency resolution and time history length
- Recommended sample rate: 10× highest frequency of interest
- Frequency range: Start at 1-10 Hz, extend to 5-10× shock frequency content

## Requirements

- MATLAB R2016b or later (or GNU Octave 5.0+)
- Signal Processing Toolbox (for some advanced features)

## License

This toolbox is provided for educational and research purposes. Please cite appropriately if used in publications.

## References

1. Harris, C.M. and Piersol, A.G., "Harris' Shock and Vibration Handbook"
2. Lalanne, C., "Mechanical Shock" (Shock and Vibration series)
3. MIL-STD-810: Environmental Engineering Considerations and Laboratory Tests

## Support

For questions, bug reports, or feature requests, please refer to the documentation or contact the development team.