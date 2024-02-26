function [antennaObject] = show_conical_horn_antenna(X, design_frequency)

    % Antenna Properties 
    antennaObject = design(hornConical, design_frequency);
       
    antennaObject.Radius = X(1);
    antennaObject.WaveguideHeight = X(2);
    antennaObject.FeedHeight = X(3);
    antennaObject.FeedWidth = X(4);
    antennaObject.FeedOffset = X(5);
    antennaObject.ConeHeight = X(6);
    antennaObject.ApertureRadius = X(7);
    antennaObject.Conductor.Conductivity = 5.8*1e7;
    antennaObject.Conductor.Thickness = 0.000127;

        
    %% Antenna Analysis 
    % Define plot frequency 
    % Define frequency range 
%     freqRange = (8415:93.5:10285) * 1e6;
    % show for horn
    figure;
    show(antennaObject)
    
    % azimuth for horn
    figure;
    patternAzimuth(antennaObject, design_frequency);
    
    figure;
    pattern(antennaObject, design_frequency);
    
    antennaObject
end