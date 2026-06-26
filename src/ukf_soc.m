function [SOC_UKF, ukf_y, ukf_Vm, ukf_Vh] = ukf_soc(I_meas, V_meas)
%#codegen
% ---- Parameters (Panasonic UR18650ZTA) ----
Q_nom  = 2.65 * 3600;
dt     = 1;

SOC_bp = [0, 0.1, 0.25, 0.5, 0.75, 0.9, 1];
OCV_bp = [3.50, 3.57, 3.63, 3.71, 3.93, 4.08, 4.19];
R0_bp  = [0.0085, 0.0085, 0.0087, 0.0082, 0.0083, 0.0085, 0.0085];
R1_bp  = [0.0029, 0.0024, 0.0026, 0.0016, 0.0023, 0.0018, 0.0017];
tau_bp = [36, 45, 29, 77, 33, 33, 39];

% ---- Persistent state ----
persistent x P initialized
if isempty(initialized)
    SOC_init = 0.8;           % Same starting point as EKF for fair comparison
    x = [SOC_init; 0];
    P = diag([0.1, 1e-4]);
    initialized = true;
end

% ---- Tuning (same as EKF) ----
Q_cov = diag([1e-5, 1e-5]);
R_cov = 0.01;

% ---- UKF sigma-point parameters ----
n = 2;                    % state dimension
alpha = 1e-3;
beta  = 2;
kappa = 0;
lambda = alpha^2 * (n + kappa) - n;

% Weights for mean and covariance
Wm = zeros(1, 2*n + 1);
Wc = zeros(1, 2*n + 1);
Wm(1) = lambda / (n + lambda);
Wc(1) = Wm(1) + (1 - alpha^2 + beta);
for i = 2:(2*n + 1)
    Wm(i) = 1 / (2 * (n + lambda));
    Wc(i) = Wm(i);
end

% ---- Generate sigma points ----
% Use Cholesky; add tiny jitter for numerical stability
% Ensure P is symmetric and positive definite
P_safe = (P + P') / 2 + 1e-8 * eye(n);
L = chol((n + lambda) * P_safe, 'lower');

X = zeros(n, 2*n + 1);
X(:, 1) = x;
for i = 1:n
    X(:, i + 1)     = x + L(:, i);
    X(:, i + n + 1) = x - L(:, i);
end

% ---- Propagate sigma points through state equations ----
X_pred = zeros(n, 2*n + 1);
for i = 1:(2*n + 1)
    soc_i = min(max(X(1, i), 0.001), 0.999);
    R1_i   = interp1(SOC_bp, R1_bp, soc_i, 'linear', 'extrap');
    tau_i  = interp1(SOC_bp, tau_bp, soc_i, 'linear', 'extrap');
    a_i    = exp(-dt / tau_i);
    b_i    = R1_i * (1 - a_i);
    
    X_pred(1, i) = X(1, i) + (dt / Q_nom) * I_meas;
    X_pred(2, i) = a_i * X(2, i) - b_i * I_meas;
end

% ---- Predicted mean and covariance ----
x_pred = X_pred * Wm';
P_pred = Q_cov;
for i = 1:(2*n + 1)
    diff_x = X_pred(:, i) - x_pred;
    P_pred = P_pred + Wc(i) * (diff_x * diff_x');
end

% ---- Propagate sigma points through measurement equation ----
Y_pred = zeros(1, 2*n + 1);
for i = 1:(2*n + 1)
    soc_i = min(max(X_pred(1, i), 0.001), 0.999);
    R0_i  = interp1(SOC_bp, R0_bp, soc_i, 'linear', 'extrap');
    OCV_i = interp1(SOC_bp, OCV_bp, soc_i, 'linear', 'extrap');
    Y_pred(i) = OCV_i + R0_i * I_meas - X_pred(2, i);
end

% ---- Predicted measurement mean and covariances ----
y_pred = Y_pred * Wm';

S = R_cov;
Pxy = zeros(n, 1);
for i = 1:(2*n + 1)
    diff_y = Y_pred(i) - y_pred;
    diff_x = X_pred(:, i) - x_pred;
    S   = S + Wc(i) * (diff_y * diff_y);
    Pxy = Pxy + Wc(i) * (diff_x * diff_y);
end

% ---- Kalman gain and update ----
K = Pxy / S;
innovation = V_meas - y_pred;
x = x_pred + K * innovation;
P = P_pred - K * S * K';

% Clamp SOC
x(1) = min(max(x(1), 0), 1);

% ---- Outputs ----
SOC_UKF = x(1);
ukf_y   = innovation;
ukf_Vm  = V_meas;
ukf_Vh  = y_pred;
end