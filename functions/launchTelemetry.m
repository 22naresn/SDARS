function launchTelemetry(simTime, ECEFPos, ECIPos, ECIVel, sat_lat, sat_long)
    % Creates a window showing simulated telemetry data (Drag, Temp, Alt)
    telemetryFig = figure('Name','Satellite Telemetry','NumberTitle','off',...
                          'Color','k','Position',[1300, 100, 400, 300]);

    axes('Color','k','XColor','none','YColor','none');
    text(0.05, 0.9, 'SATELLITE TELEMETRY', 'Color', 'w', 'FontSize', 12, 'FontWeight','bold');

    dragText = text(0.05, 0.7, '', 'Color', 'w', 'FontSize', 10);
    tempText = text(0.05, 0.6, '', 'Color', 'w', 'FontSize', 10);
    altText  = text(0.05, 0.5, '', 'Color', 'w', 'FontSize', 10);

    % Loop to simulate telemetry in real time
    for t = 1:min(simTime, 1000)
        % Simulated values (replace with real model later)
        dragVal = 2e-5 * abs(sin(t/100));
        tempVal = 220 + 50*sin(t/50);
        altVal  = norm(ECEFPos(:,t))/1000 - 6371;  % Altitude = norm - Earth radius

        % Update UI
        set(dragText, 'String', sprintf('Atmospheric Drag: %.2e N', dragVal));
        set(tempText, 'String', sprintf('Temperature: %.1f K', tempVal));
        set(altText,  'String', sprintf('Altitude: %.2f km', altVal));

        drawnow;
        pause(0.05);

        % Break loop if user closes the window
        if ~isvalid(telemetryFig)
            break;
        end
    end
end
