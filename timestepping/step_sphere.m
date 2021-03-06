function [st, x] = step_sphere(params, st, u)
% st = [x, y, z, q0, q1, q2, q3, ...]

% System parameters
h = params.h;
mu = params.mu;
m = params.m; % sphere mass
r = params.r; % sphere radius
step_fun = params.step_fun;

M = diag(m*[1 1 1 (2/5)*r^2 (2/5)*r^2 (2/5)*r^2]);

% Extract pose and velocity
q = st(1:7);
v = st(8:13);

% Gravitational, external, and other forces
omega = v(4:6);
I = M(4:6,4:6);
Fext = [0; 0; -9.81*m; -cross(omega, I*omega)] + u;

% Contact normal distances (gaps)
psi = q(3) - r;

% Jacobian for contacts
J = [ 0  0  1  0  0  0
      1  0  0  0  r  0
      0  1  0 -r  0  0];
R = quat2rotm(q(4:7)');
J(:,4:6) = J(:,4:6)*R;

% Identify active contacts
if (psi < 0.1)
    [v_next, x]  = step_fun(v, Fext, M, J, mu, psi, h);
else
    % Step without contact impulses
    v_next = (v + M\Fext*h);
    x = [0; 0; 0];
end

q_next = int_body(q, v_next, h);

st = [q_next; v_next];
end