% Slide a sphere with a fixed orientation between two planes to illustrate
% sheath effects.
clear

% Parameters
h = 0.01;
mu = 0.3*ones(2,1);
m = 0.2;
r = 0.05;
w = 0.051;

params = struct('h', h, 'mu', mu, 'm', m, 'r', r, 'w', w, 'step_fun', []);

x0 = [0, 0, r-w, 0, 0, 0]';
u = [1, 0, 0]';
N = 51;

%% Simulation
time = 0:h:h*(N-1);

params.step_fun = @solver_ncp;
[x1, f1] = stepper(params, @step_bead, x0, u, N);
params.step_fun = @solver_blcp;
[x2, f2] = stepper(params, @step_bead, x0, u, N);
params.step_fun = @solver_ccp;
[x3, f3] = stepper(params, @step_bead, x0, u, N);
params.step_fun = @solver_convex;
[x4, f4] = stepper(params, @step_bead, x0, u, N);

%% Plotting
plot(time, x1(4,:), '-')
hold on
plot(time, x2(4,:), '-.')
plot(time, x3(4,:), '--')
plot(time, x4(4,:), ':')
hold off

legend({'NCP','BLCP','CCP','Convex'}, 'Location', 'Northwest')
xlabel('Time (sec)')
ylabel('Sphere Velocity (m/s)')
a = gca;
for k = 1:numel(a.Children)
    a.Children(k).LineWidth = 2;
end