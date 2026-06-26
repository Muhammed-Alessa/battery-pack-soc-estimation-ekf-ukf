function SOC_EKF  = ekf_soc(I_meas, V_meas)
%#codegen
Q_nom  = 2.65 * 3600;
dt     = 1;
SOC_bp = [0, 0.1, 0.25, 0.5, 0.75, 0.9, 1];
OCV_bp = [3.50, 3.57, 3.63, 3.71, 3.93, 4.08, 4.19];
R0_bp  = [0.0085, 0.0085, 0.0087, 0.0082, 0.0083, 0.0085, 0.0085];
R1_bp  = [0.0029, 0.0024, 0.0026, 0.0016, 0.0023, 0.0018, 0.0017];
tau_bp = [36, 45, 29, 77, 33, 33, 39];

persistent x P initialized
if isempty(initialized)
    SOC_init = 0.8;    % was 0.5 — EKF starts WRONG (30% too high)
    x = [SOC_init; 0];
    P = diag([0.1, 1e-4]);
    initialized = true;
end

soc_c = min(max(x(1), 0.001), 0.999);
R0   = interp1(SOC_bp, R0_bp, soc_c, 'linear', 'extrap');
R1   = interp1(SOC_bp, R1_bp, soc_c, 'linear', 'extrap');
tau1 = interp1(SOC_bp, tau_bp, soc_c, 'linear', 'extrap');
OCV  = interp1(SOC_bp, OCV_bp, soc_c, 'linear', 'extrap');

ds = 0.005;
s_hi = min(soc_c + ds, 1);
s_lo = max(soc_c - ds, 0);
dOCV = (interp1(SOC_bp, OCV_bp, s_hi, 'linear', 'extrap') - ...
        interp1(SOC_bp, OCV_bp, s_lo, 'linear', 'extrap')) / (s_hi - s_lo);

Q_cov = diag([1e-5, 1e-5]);
R_cov = 0.01;

a = exp(-dt / tau1);
b = R1 * (1 - a);
SOC_pred = x(1) + (dt / Q_nom) * I_meas;
VRC_pred = a * x(2) - b * I_meas;
x_pred = [SOC_pred; VRC_pred];

F = [1, 0; 0, a];
P_pred = F * P * F' + Q_cov;

V_hat = OCV + R0 * I_meas - VRC_pred;
y = V_meas - V_hat;
H = [dOCV, -1];
S = H * P_pred * H' + R_cov;
K = (P_pred * H') / S;

x = x_pred + K * y;
P = (eye(2) - K * H) * P_pred;
x(1) = min(max(x(1), 0), 1);

SOC_EKF = x(1);
debug_y = y;
debug_Vm = V_meas;
debug_Vh = V_hat;
end