% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03

% This class implements methods for Lagrange Tops animation

% Example Usage:
% >>> animator = AnimationLagrange(config);
% >>> videoFile = animator.animate();

% Primary Functions:
%   -- animate(): animates Lagrange tops motion and records video from data in csvFile

% Depends on:
%   -- AnimationCommon

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef AnimationLagrange
    
    properties
    % ------------------------------------
    % This section contains the Required properties of the top to be simulated
    % ------------------------------------
        slidingScale = 5;
        vidWriter;
    end
    
    methods
        function obj = AnimationLagrange(sliding_window)
            % ------------------------------------
            % This function generates an animation and saves a video file given the simulated data
            % Input:
            %   - sliding_window: whether to use sliding window or not
            % Output: 
            %   - obj: object containing provided configuration data as a property
            % ------------------------------------
            if sliding_window ~= true
                obj.slidingScale = -1;
            end
        end
        
        function vidFile = animate(obj, dataFile, vidTitle)
            % ------------------------------------
            % This function generates an animation and saves a video file given the simulated data
            % Input:
            %   - obj
            %   - dataFile: path to a data file that contains data to be visualized
            %   - vidTitle: title of video
            % Output:
            %   - vidFile: path to the video file created
            % ------------------------------------
            [t, euler, eulerRate, Ueff] = AnimationLagrange.loadData(dataFile);

            % Deal with fixed frames
            if obj.slidingScale == -1
                obj.slidingScale = t(end);
            end

            % Open video editor
            obj.vidWriter = VidWriter(AnimationCommon.genVideoPath(dataFile, vidTitle));

            % Initialize UI
            [mainAxes, sideAxes] = AnimationCommon.initAniTopUI(3);
            [phf, phm, bodyAxes] = AnimationCommon.initPlotMain(mainAxes);
            [surfX,surfY,surfZ,surfHandle] = AnimationLagrange.genMesh(mainAxes);
            disp(phf(1))
            AnimationCommon.setPlotStyle("Lagrange Top", 24, " ", " ", phf, ["X", "Y", "Z"], mainAxes);
            
            % Configure Side Plots
            % Euler Angles
            eulerDots = AnimationCommon.initPlot2D(t, euler, 'Euler Angles', 'Time', 'Euler Angle', ["$\phi$", "$\theta$", "$\psi$"], obj.slidingScale, sideAxes(1));
            % Euler Rates
            eulerRateDots = AnimationCommon.initPlot2D(t, eulerRate, 'Euler Angle Rates', 'Time', 'Euler Angle Rate', ["$\dot \phi$", "$\dot \theta$", "$\dot \psi$"], obj.slidingScale, sideAxes(2));
            % Angular Velocities
            ueffDots = AnimationCommon.initPlot2D(t, Ueff, 'Effective Potential', 'Time', 'Energy', "$U_{eff}$", obj.slidingScale, sideAxes(3));
            
            % Start Rendering each frame
            % We are skipping the first frame because of deltas used. 
            for i=1:length(t)-1
                % Draw Main Window
                AnimationCommon.updatePlotMain(i, euler, surfX, surfY, surfZ, surfHandle, phm, bodyAxes);

                % Draw Side Windows
                AnimationCommon.updatePlot2D(i, t, euler, eulerDots, obj.slidingScale, sideAxes(1));
                AnimationCommon.updatePlot2D(i, t, eulerRate, eulerRateDots, obj.slidingScale, sideAxes(2));
                AnimationCommon.updatePlot2D(i, t, Ueff, ueffDots, obj.slidingScale, sideAxes(3));
            
                drawnow                     % drawing the new position
                obj.vidWriter.writeFrame(); % Update Video
            end
            obj.vidWriter.close();          % Close video recorder
            vidFile = obj.vidWriter.vidFile;
        end
    end

    methods(Static)
        function [X,Y,Z,surfHandle] = genMesh(parentAxes)
        % ------------------------------------
        % This function generates a combined geometric mesh consisting of a cone and a cylindrical tip
        % Input:
        %   - parentAxes: axes object where the generated mesh is displayed
        % Output:
        %   - X, Y, Z: matrix of combined x, y, and z coordinates
        %   - surfHandle: handle to the surface object created by the surf function
        % ------------------------------------
            % Generate Cone
            [X,Y,Z] = AnimationCommon.genCone(2, 4);
            Z = -Z + 2;

            % Generate Cylinder tip
            [X2, Y2, Z2] = AnimationCommon.genCylinder(0.5, 2);
            Z2 = Z2 + 4;

            X = [X;X2];
            Y = [Y;Y2];
            Z = [Z;Z2];
            hold(parentAxes, 'on');
            surfHandle = surf(X,Y,-Z+1,'EdgeColor','none','FaceColor','red', 'Parent', parentAxes);
            hold(parentAxes, 'off');
        end

        function [t,euler, eulerRate, Ueff] = loadData(file)
            % ------------------------------------
            % This function organizes input data into seperate variables
            % ------------------------------------   
            table = readtable(file);
            t = table2array(table(:,1));
            euler = table2array(table(:,2:4));
            eulerRate = table2array(table(:,5:7));
            Ueff = table2array(table(:,8));
        end
    end % Methods
end