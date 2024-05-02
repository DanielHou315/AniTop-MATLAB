% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03

% This class implements methods for Kovalevskaya Tops animation

% Example Usage:
% >>> animator = AnimationKov(config);
% >>> videoFile = animator.animate();

% Primary Functions:
%   -- animate(): animates Kovalevskaya tops motion and records video from data in csvFile

% Depends on:
%   -- AnimationCommon

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef AnimationKov
    
    properties
        slidingScale=5;
        vidWriter;
    end
    
    methods
        function obj = AnimationKov(sliding_window)
            % ------------------------------------
            % This function initializes an AnimationKov object
            % ------------------------------------
            if sliding_window ~= true
                obj.slidingScale = -1;
            end
        end
        
        function vidFile = animate(obj, dataFile, vidTitle)
            % ------------------------------------
            % This function generates an animation and saves a video file given the simulated data.
            % ------------------------------------
            [t, euler, angMomentum] = AnimationKov.loadData(dataFile);

            % Deal with fixed frames
            if obj.slidingScale == -1
                obj.slidingScale = t(end);
            end

            % Open video editor
            obj.vidWriter = VidWriter(AnimationCommon.genVideoPath(dataFile, vidTitle));

            % Initialize UI
            [mainAxes, sideAxes] = AnimationCommon.initAniTopUI(2);
            [phf, phm, bodyAxes] = AnimationCommon.initPlotMain(mainAxes);
            [surfX,surfY,surfZ,surfHandle] = AnimationKov.genMesh(mainAxes);
            disp(phf(1))
            AnimationCommon.setPlotStyle("Kovalevskaya Top", 24, " ", " ", phf, ["X", "Y", "Z"], mainAxes);
            
            % Configure Side Plots
            % Euler Angles
            eulerDots = AnimationCommon.initPlot2D(t, euler, 'Euler Angles', 'Time', 'Euler Angle', ["$\phi$", "$\theta$", "$\psi$"], obj.slidingScale, sideAxes(1));
            % Angular Momentum
            angMomentumDots = AnimationCommon.initPlot2D(t, angMomentum, 'Angular Momentum', 'Time', 'Angular Momentum', ["$P_\phi$", "$P_\theta$", "$P_\psi$"], obj.slidingScale, sideAxes(2));
            
            % Start Rendering each frame
            % We are skipping the first frame because of deltas used. 
            for i=1:length(t)-1
                % Draw Main Window
                AnimationCommon.updatePlotMain(i, euler, surfX, surfY, surfZ, surfHandle, phm, bodyAxes);

                % Draw Side Windows
                AnimationCommon.updatePlot2D(i, t, euler, eulerDots, obj.slidingScale, sideAxes(1));
                AnimationCommon.updatePlot2D(i, t, angMomentum, angMomentumDots, obj.slidingScale, sideAxes(2));
            
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
            % This function generates an animation and saves a video file given the simulated data.
            %
            % Input: 
            %   - parentAxes: generate mesh in the parent graphic axes (MATLAB concept)
            % Output:
            %   - X,Y,Z: 3D data for points that make up mesh
            %   - surfHandle: graph handle to the mesh object
            % ------------------------------------
            % Torus
            [Xa,Ya,Za] = AnimationCommon.genTorus(3.75, 32, 0.25, 2);

            % Cylinder 1
            [Xc1, Yc1, Zc1] = AnimationCommon.genCylinder(0.25, 4);
            % Cylinder 2
            [Xc2, Yc2, Zc2] = AnimationCommon.genCylinder(0.25, 4);
            Zc2 = Zc2 * (-1);

            % Cylinder 3, in different orientation
            [Zc3, Yc3, Xc3] = AnimationCommon.genCylinder(0.25, 4);
            % Cylinder 4, in different orientation
            [Zc4, Yc4, Xc4] = AnimationCommon.genCylinder(0.25, 4);
            Xc4 = Xc4 * (-1);

            % Sphere 1
            [Xs1, Ys1, Zs1] = AnimationCommon.genSphere(0.63, 32);
            Xs1 = Xs1 + 2;
            % Sphere 2
            [Xs2, Ys2, Zs2] = AnimationCommon.genSphere(0.63, 32);
            Xs2 = Xs2 - 2;

            % Sphere 3
            [Xs3, Ys3, Zs3] = AnimationCommon.genSphere(0.5, 32);
            Zs3 = Zs3 - 4;

            % Combine points
            Xr = [Xc1;Xc2;Xc3;Xc4;Xs1;Xs2;Xs3];
            Yr = [Yc1;Yc2;Yc3;Yc4;Ys1;Ys2;Ys3];
            Zr = [Zc1;Zc2;Zc3;Zc4;Zs1;Zs2;Zs3];

            hold(parentAxes, "on");
            surfHandle1 = surf(Xa,Ya,Za,'EdgeColor','none','FaceColor','red', 'Parent', parentAxes); 
            surfHandle2 = surf(Xr,Yr,Zr,'EdgeColor','none','FaceColor','red', 'Parent', parentAxes); 
            hold(parentAxes, "off");

            surfHandle = {surfHandle1, surfHandle2};
            X = {Xa, Xr};
            Y = {Ya, Yr};
            Z = {Za, Zr};
        end
        
        % Implement any other functions as seen fit
        function [t,euler, angMomentum] = loadData(file)
            % ------------------------------------
            % This function organizes data into seperate variables
            % ------------------------------------   
            table = readtable(file);
            t = table2array(table(:,1));
            euler = table2array(table(:,2:4));
            angMomentum = table2array(table(:,5:7));
        end
        
    end
end