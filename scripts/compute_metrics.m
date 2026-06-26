%% Compute SOC Estimation Metrics (EKF + UKF + CC)

t = soc_true.Time;
true_soc = soc_true.Data;
ekf_soc_data = soc_ekf.Data;
cc_soc_data = soc_cc.Data;
ukf_soc_data = soc_ukf.Data;

N = min([length(true_soc), length(ekf_soc_data), length(cc_soc_data), length(ukf_soc_data)]);
true_soc = true_soc(1:N);
ekf_soc_data = ekf_soc_data(1:N);
cc_soc_data  = cc_soc_data(1:N);
ukf_soc_data = ukf_soc_data(1:N);
t = t(1:N);

% RMSE
rmse_ekf = sqrt(mean((ekf_soc_data - true_soc).^2));
rmse_cc  = sqrt(mean((cc_soc_data  - true_soc).^2));
rmse_ukf = sqrt(mean((ukf_soc_data - true_soc).^2));

% Max absolute error
maxerr_ekf = max(abs(ekf_soc_data - true_soc));
maxerr_cc  = max(abs(cc_soc_data  - true_soc));
maxerr_ukf = max(abs(ukf_soc_data - true_soc));

% Convergence time
err_ekf = abs(ekf_soc_data - true_soc);
err_ukf = abs(ukf_soc_data - true_soc);
idx_ekf = find(err_ekf < 0.02, 1, 'first');
idx_ukf = find(err_ukf < 0.02, 1, 'first');
conv_ekf = NaN; if ~isempty(idx_ekf), conv_ekf = t(idx_ekf); end
conv_ukf = NaN; if ~isempty(idx_ukf), conv_ukf = t(idx_ukf); end

fprintf('\n===== SOC Estimation Metrics =====\n');
fprintf('EKF RMSE:           %.4f (%.2f%%)\n', rmse_ekf, rmse_ekf*100);
fprintf('UKF RMSE:           %.4f (%.2f%%)\n', rmse_ukf, rmse_ukf*100);
fprintf('CC  RMSE:           %.4f (%.2f%%)\n', rmse_cc,  rmse_cc*100);
fprintf('EKF Max Error:      %.4f (%.2f%%)\n', maxerr_ekf, maxerr_ekf*100);
fprintf('UKF Max Error:      %.4f (%.2f%%)\n', maxerr_ukf, maxerr_ukf*100);
fprintf('CC  Max Error:      %.4f (%.2f%%)\n', maxerr_cc,  maxerr_cc*100);
fprintf('EKF Convergence:    %.1f s\n', conv_ekf);
fprintf('UKF Convergence:    %.1f s\n', conv_ukf);
fprintf('==================================\n');

figure('Position', [100 100 900 500]);
subplot(2,1,1);
plot(t, true_soc, 'k-', 'LineWidth', 2); hold on;
plot(t, ekf_soc_data, 'b-', 'LineWidth', 1.5);
plot(t, ukf_soc_data, 'g-.', 'LineWidth', 1.5);
plot(t, cc_soc_data, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('SOC');
legend('True SOC', 'EKF', 'UKF', 'Coulomb Counting', 'Location', 'best');
title('SOC Estimation Comparison');
grid on;

subplot(2,1,2);
plot(t, (ekf_soc_data - true_soc)*100, 'b-',  'LineWidth', 1.5); hold on;
plot(t, (ukf_soc_data - true_soc)*100, 'g-.', 'LineWidth', 1.5);
plot(t, (cc_soc_data  - true_soc)*100, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('SOC Error (%)');
legend('EKF Error', 'UKF Error', 'CC Error', 'Location', 'best');
title('Estimation Error');
grid on;