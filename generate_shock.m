function [time, accel] = generate_shock(shock_type, duration, amplitude, sample_rate, varargin)
% GENERATE_SHOCK - Generate various shock waveforms for SRS testing
%
% Creates standard shock waveforms commonly used in shock testing
%
% INPUTS:
%   shock_type  - Type of shock ('half_sine', 'haversine', 'sawtooth', 
%                 'terminal_peak', 'rectangular', 'exponential', 'pyroshock')
%   duration    - Shock duration [s]
%   amplitude   - Peak amplitude [g or m/s^2]
%   sample_rate - Sampling rate [Hz]
%   varargin    - Additional parameters specific to shock type
%
% OUTPUTS:
%   time        - Time vector [s]
%   accel       - Acceleration time history

% Input validation
if nargin < 4
    error('At least 4 input arguments required');
end

% Create time vector with padding before and after shock
pre_duration = duration;
post_duration = 2*duration;
total_duration = pre_duration + duration + post_duration;

dt = 1/sample_rate;
time = 0:dt:total_duration;
n_total = length(time);
n_shock = round(duration/dt);
start_idx = round(pre_duration/dt) + 1;
end_idx = start_idx + n_shock - 1;

% Initialize acceleration vector
accel = zeros(size(time));

% Generate shock based on type
switch lower(shock_type)
    case 'half_sine'
        % Half sine pulse
        t_shock = linspace(0, pi, n_shock);
        accel(start_idx:end_idx) = amplitude * sin(t_shock);
        
    case 'haversine'
        % Haversine pulse (raised cosine)
        t_shock = linspace(0, pi, n_shock);
        accel(start_idx:end_idx) = amplitude * (1 - cos(t_shock))/2;
        
    case 'sawtooth'
        % Sawtooth pulse
        direction = 'up'; % default
        if length(varargin) >= 1
            direction = varargin{1};
        end
        
        t_shock = linspace(0, 1, n_shock);
        if strcmp(direction, 'up')
            accel(start_idx:end_idx) = amplitude * t_shock;
        else
            accel(start_idx:end_idx) = amplitude * (1 - t_shock);
        end
        
    case 'terminal_peak'
        % Terminal peak sawtooth
        t_shock = linspace(0, 1, n_shock);
        accel(start_idx:end_idx) = amplitude * t_shock;
        
    case 'rectangular'
        % Rectangular pulse
        accel(start_idx:end_idx) = amplitude;
        
    case 'exponential'
        % Exponential decay
        decay_constant = 1/duration; % default
        if length(varargin) >= 1
            decay_constant = varargin{1};
        end
        
        t_shock = linspace(0, duration, n_shock);
        accel(start_idx:end_idx) = amplitude * exp(-decay_constant * t_shock);
        
    case 'pyroshock'
        % Pyroshock simulation (damped oscillation)
        freq = 1000; % default frequency [Hz]
        damping = 0.1; % default damping
        
        if length(varargin) >= 1
            freq = varargin{1};
        end
        if length(varargin) >= 2
            damping = varargin{2};
        end
        
        omega = 2*pi*freq;
        omega_d = omega * sqrt(1 - damping^2);
        t_shock = linspace(0, duration, n_shock);
        
        envelope = amplitude * exp(-damping * omega * t_shock);
        oscillation = cos(omega_d * t_shock);
        accel(start_idx:end_idx) = envelope .* oscillation;
        
    case 'double_exponential'
        % Double exponential (ballistic shock)
        tau1 = duration/10; % rise time constant
        tau2 = duration/2;  % decay time constant
        
        if length(varargin) >= 1
            tau1 = varargin{1};
        end
        if length(varargin) >= 2
            tau2 = varargin{2};
        end
        
        t_shock = linspace(0, 3*duration, n_shock);
        accel(start_idx:end_idx) = amplitude * (exp(-t_shock/tau2) - exp(-t_shock/tau1));
        
    otherwise
        error('Unknown shock type: %s', shock_type);
end

% Add noise if requested
if length(varargin) >= 3 && varargin{3} > 0
    noise_level = varargin{3};
    noise = noise_level * amplitude * randn(size(accel));
    accel = accel + noise;
end

end