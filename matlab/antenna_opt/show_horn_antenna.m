function [antennaObject] = show_horn_antenna(X, design_frequency)

    % Antenna Properties 
    antennaObject = design(horn, design_frequency);
       
    antennaObject.FeedWidth = X(1);
    antennaObject.FeedHeight = X(2);
    antennaObject.Height = X(3);
    antennaObject.Width = X(4);
    antennaObject.Length = X(5);
    antennaObject.FlareLength = X(6);
    antennaObject.FlareHeight = X(7);
    antennaObject.FlareWidth = X(8);
    antennaObject.FeedOffset = [X(9) 0];
        
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