function [fig3D, globe, plt, sat_lat, sat_long] = makePlot(ECIPos, LLHGDPos)
    % Initialisation
    sat_lat  = rad2deg(LLHGDPos(1,:));
    sat_long = rad2deg(LLHGDPos(2,:));

    screen1 = [0.0 0.5 0.5 0.5];
    screen2 = [0.5 0.5 0.5 0.5];

    %% 3D Plot Set-up
    fig3D = figure(1);
    set(fig3D, 'Units', 'normalized', 'Position', screen2);

    load('topo.mat','topo');
    [x,y,z] = sphere(50);
    x = -x.*6378000;
    y = -y.*6378000;
    z = z.*6378000;

    props.FaceColor = 'texture';
    props.EdgeColor = 'none';
    props.FaceLighting = 'phong';
    props.Cdata = topo;

    axes('dataaspectratio',[1 1 1],'visible','on');
    hold on;
    globe = surface(x,y,z,props);
    whitebg(1, 'k');

    plt.orbits = plot3(ECIPos(1,:), ECIPos(2,:), ECIPos(3,:), 'b');
    hold on;
    plt.sats = scatter3(NaN, NaN, NaN, 'r', 'filled');

    %% 2D Ground Trace Setup
    fig.map = figure(2);
    set(fig.map, 'Units', 'normalized', 'Position', screen1);
    map = imread('Blue_Marble_Next_Generation_August.jpg');
    image([-180 180],[90 -90], map);
    axis xy;
    hold on;
    grid on;
    scatter(sat_long, sat_lat, 1);
    title('Ground Trace of LEO Satellite');
    ylabel('Latitude (deg)');
    xlabel('Longitude (deg)');
    legend('LEO Satellite');

    plt.ground_trace = scatter(NaN, NaN, 'r', 'filled');
end
