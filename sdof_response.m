function [response, velocity] = sdof_response(time, accel, freq, damping)
% SDOF_RESPONSE - Single Degree of Freedom Response
%
% Calculates the response of a single degree of freedom oscillator
% to an acceleration input using numerical integration
%
% INPUTS:
%   time     - Time vector [s]
%   accel    - Acceleration time history [g or m/s^2]
%   freq     - Natural frequency [Hz]
%   damping  - Damping ratio (fraction of critical damping)
%
% OUTPUTS:
%   response - Displacement response [m] (or [m/g] if accel in g)
%   velocity - Velocity response [m/s] (or [m*s/g] if accel in g)

% Convert frequency to angular frequency
omega_n = 2 * pi * freq;

% Calculate damped frequency
omega_d = omega_n * sqrt(1 - damping^2);

% Check for overdamping
if damping >= 1.0
    warning('System is overdamped (damping >= 1.0). Using critically damped response.');
    damping = 0.99;
    omega_d = omega_n * sqrt(1 - damping^2);
end

% Time step
dt = time(2) - time(1);

% Initialize response arrays
n = length(time);
response = zeros(size(time));
velocity = zeros(size(time));

% Initial conditions (at rest)
x_prev = 0;
v_prev = 0;

% Exponential decay factor
exp_factor = exp(-damping * omega_n * dt);
cos_term = cos(omega_d * dt);
sin_term = sin(omega_d * dt);

% Pre-calculate coefficients for efficiency
if damping < 1.0
    % Underdamped case
    A = exp_factor * (cos_term + (damping * omega_n / omega_d) * sin_term);
    B = exp_factor * (sin_term / omega_d);
    C = exp_factor * (-omega_n^2 / omega_d * sin_term);
    D = exp_factor * (cos_term - (damping * omega_n / omega_d) * sin_term);
else
    % Critically damped case
    A = exp_factor * (1 + damping * omega_n * dt);
    B = exp_factor * dt;
    C = exp_factor * (-omega_n^2 * dt);
    D = exp_factor * (1 - damping * omega_n * dt);
end

% Duhamel's integral coefficients for force integration
alpha = (2*damping) / (omega_n^3 * dt);
beta = 1 / (omega_n^2);
gamma = (2*damping) / (omega_n);

% Numerical integration using linear acceleration method
for i = 2:n
    % Current acceleration
    a_curr = -accel(i);
    a_prev = -accel(i-1);
    
    % Force integration for impulse response
    if damping < 1.0
        % Underdamped impulse response
        h1 = (1 - exp_factor * cos_term) / omega_n^2;
        h2 = (dt - (sin_term * exp_factor) / omega_d) / omega_n^2;
    else
        % Critically damped impulse response
        h1 = (1 - exp_factor * (1 + omega_n * dt)) / omega_n^2;
        h2 = (dt - exp_factor * dt) / omega_n^2;
    end
    
    % Update response using convolution
    x_curr = A * x_prev + B * v_prev + h1 * a_prev + h2 * (a_curr - a_prev);
    v_curr = C * x_prev + D * v_prev + (h1 * omega_n^2 + gamma * h2) / dt * a_prev + ...
             (h2 * omega_n^2 - gamma * h1) / dt * (a_curr - a_prev);
    
    % Store results
    response(i) = x_curr;
    velocity(i) = v_curr;
    
    % Update for next iteration
    x_prev = x_curr;
    v_prev = v_curr;
end

end