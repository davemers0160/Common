classdef preluLayer < nnet.layer.Layer

    properties (Learnable)
        % Layer learnable parameters
            
        % Scaling coefficient
        Alpha
    end
    
    methods
        function layer = preluLayer(numChannels, name) 
            % Create an preluLayer with numChannels channels

            % Set layer name
            if nargin == 2
                layer.Name = name;
            end

            % Set layer description
            layer.Description = ...
                ['preluLayer with ', num2str(numChannels), ' channels']; 
        
            % Initialize scaling coefficient
            layer.Alpha = rand([1 1 numChannels]); 
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer and output the result
            
            Z = max(0, X) + layer.Alpha .* min(0, X);
        end
        
        function [dLdX, dLdAlpha] = backward(layer, X, Z, dLdZ, memory)
            % Backward propagate the derivative of the loss function through 
            % the layer 
            
            dLdX = layer.Alpha .* dLdZ;
            dLdX(X>0) = dLdZ(X>0);
            dLdAlpha = min(0,X) .* dLdZ;
            dLdAlpha = sum(sum(dLdAlpha,1),2);
            
            % Sum over all observations in mini-batch
            dLdAlpha = sum(dLdAlpha,4);
        end
    end
end