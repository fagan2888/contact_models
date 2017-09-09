function gripper_plot(x, f)

% Parameters
h = 0.02;
r = 0.5;

% Disk
angles = linspace(0, 2*pi, 30);
xs = r*cos(angles);
ys = r*sin(angles);

% Plotting
lims = [-4 4 -1 5]*r;
clf
patch(lims([1 2 2 1]), [lims([3 3]) 0 0], 0.8+[0 0 0]);
h_x1 = line(x(4)+[0 0], x(6)+[0 3*r], 'Color', 'k', 'LineWidth', 2);
h_x2 = line(x(5)+[0 0], x(6)+[0 3*r], 'Color', 'k', 'LineWidth', 2);
h_ceil = patch([-2 2 2 -2]*r, x(6)+[3 3 4 4]*r, 'k');
h_disk = patch(x(1) + xs, x(2) + ys, 0.8+[0 0 0]);
h_tick = line(x(1)+[0 r*cos(x(3))], x(2)+[0 r*sin(x(3))], 'Color', 'k', 'LineStyle', '--');
h_quiv1 = [];
if (nargin >= 2)
    hold on
    h_quiv1 = quiver([0 0 x(4) x(5)], [x(6)+4*r x(6)+3*r x(2) x(2)],...
        [0 0 f(4) -f(5)], [-f(2) f(3) f(7) -f(8)], 0, 'b');
    h_quiv2 = quiver([x(1)+r x(1)-r x(1)], [x(2) x(2) 0],...
        [-f(4) f(5) -f(9)], [-f(7) f(8) f(6)], 0, 'r');
    hold off
end
axis(lims)

for k = 1:size(x,2)
    % Plotting
    h_x1.XData = x(4,k)+[0 0];
    h_x1.YData = x(6,k)+[0 3*r];
    h_x2.XData = x(5,k)+[0 0];
    h_x2.YData = x(6,k)+[0 3*r];
    h_ceil.YData = x(6,k)+[3 3 4 4]*r;
    h_disk.XData = x(1,k) + xs;
    h_disk.YData = x(2,k) + ys;
    h_tick.XData = x(1,k)+[0 r*cos(x(3,k))];
    h_tick.YData = x(2,k)+[0 r*sin(x(3,k))];
    if ~isempty(h_quiv1) && (k <= size(f,2))
        h_quiv1.XData = [0 0 x(4,k) x(5,k)];
        h_quiv1.YData = [x(6,k)+4*r x(6,k)+3*r x(2,k) x(2,k)];
        h_quiv1.UData = [0 0 f(4,k) -f(5,k)];
        h_quiv1.VData = [-f(2,k) f(3,k) f(7,k) -f(8,k)];
        h_quiv2.XData = [x(1,k)+r x(1,k)-r x(1,k)];
        h_quiv2.YData = [x(2,k) x(2,k) 0];
        h_quiv2.UData = [-f(4,k) f(5,k) -f(9,k)];
        h_quiv2.VData = [-f(7,k) f(8,k) f(6,k)];
    end
    axis(lims)
    
    pause(h)
end
end