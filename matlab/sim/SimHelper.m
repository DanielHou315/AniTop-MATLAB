% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/02

% This class implements static helper methods for Tops simulation

% Example Usage: None, use as static helper library

% Depends on: None

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef SimHelper
    % This is a helper class with static only methods
    methods(Static)

        function E = calcEnergy(I,Omega)
            % ------------------------------------
            % This function calculates the system energy given Omega array and I
            % Using this we can verify that momentum is conserved
            % ------------------------------------
            arguments
                I (3,1) {mustBeNumeric};
                Omega (:,3) {mustBeNumeric};
            end
            E = (I(1)*Omega(:,1).^2 + I(2)*Omega(:,2).^2 + I(3)*Omega(:,3).^2 ) / 2;
        end

        function M = calcMomentum(I,Omega)
            % ------------------------------------
            % % This function calculates the momentum given Omega array and I
            % Using this we can verify that momentum is conserved
            % ------------------------------------
            arguments
                I (3,1) {mustBeNumeric};
                Omega (:,3) {mustBeNumeric};
            end
            M = I(1)^2 * Omega(:,1).^2 + I(2)^2 * Omega(:,2).^2 + I(3)^2 * Omega(:,3).^2;
        end


        function csvFilePath = getDataPath(postfix)
            % ------------------------------------
            % % This function calculates the momentum given Omega array and I
            % Using this we can verify that momentum is conserved
            % ------------------------------------
            % Define the path to the data directory relative to this script
            curTime = datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd_HH-mm-ss');
            scriptPath = fileparts(mfilename('fullpath'));
            dataDirPath = fullfile(scriptPath(1:end-10), 'data');
            
            % Check if the data directory exists, if not, create it
            if ~exist(dataDirPath, 'dir')
                mkdir(dataDirPath);
            end
            % Define the full path to the output CSV file
            csvFilePath = fullfile(dataDirPath, string(curTime) + '_' + postfix + '.csv');
        end




        function plotData3D(t,data,name)
        % ------------------------------------
        % Plots debug 3 dimensional data in 2D plot
        % ------------------------------------
        arguments
            t (:,1) {mustBeNumeric};
            data (:, 3) {mustBeNumeric};
            name {mustBeText}
        end
        figOmg = figure("Name", name);
        plot(t, data, "LineWidth",3);
        title(name+" vs. Time");
        xlabel("Time (s)");
        ylabel(name);
        legend(name+'_1', name+'_2', name+'_3');
        end

        function plotEM(t, data, opt)
        % ------------------------------------
        % This function graphs the changing system energy E in blue and
        % the constant initial energy E0 as a straight line, using the first E value as E0.
        % ------------------------------------
        arguments
            t (:,1) {mustBeNumeric};
            data (:, 1) {mustBeNumeric};
            opt {mustBeText};
        end

        figEM = figure("Name", "System Energy Overview"); % Create a new figure
        plot(t, data, 'b', "LineWidth", 2); % Plot changing E in blue
        hold on; % Keep the plot for additional lines
        
        d0 = data(1); % Use the first E value as E0
        plot(t, d0*ones(size(t)), 'r--', "LineWidth", 2); % Plot constant E0 as a straight line
        
        xlabel("Time (s)");

        if opt == 'e'
            title("System Energy over Time");
            ylabel("Energy (J)");
            legend('System Energy', 'Initial Energy');
        elseif opt == 'm'
            title("System Momentum over Time");
            ylabel("Momentum (kg*m/s)");
            legend('System Momentum', 'Initial Momentum');
        else
            error("Invalid PlotEM Option " + opt);
        end

        pbaspect([3 1 1]); % Keep aspect ratio
        hold off; % No more plots on this subplot
        end
    
    end % methods(Static())
end