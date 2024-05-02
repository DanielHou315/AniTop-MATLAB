% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03/11

% This is the AnimationCommon class. This program wraps around the TopEuler package by Alexander Erlich for animation.

% Example Usage:
%   -- Not callable, use as collection of static helper functions

% Parameters/Properties:
%   -- None, static class

% This class implementation is free of Generative AI output.
% ------------------------------------
classdef AnimationCommon
    
    properties(Constant)
        frameRate = 25;     % For performance reasons, we are hard coding in 25 fps videos. 
        colorPalette = [[0 0.4470 0.741]; ...
                        [0.8500 0.3250 0.0980]; ...
                        [0.9290 0.6940 0.1250]; ...
                        [0.4940 0.1840 0.5560]; ...
                        [0.4660 0.6740 0.1880]; ...
                        [0.3010 0.7450 0.9330]; ...
                        [0.6350 0.0780 0.1840]]
    end
    
    methods(Static)
        function [mainAxes, sideAxes] = initAniTopUI(nSidePlots)
            % -----------------------------------
            % This function creates the main plot axes and side plot axes
            % using given initial conditions
            % 
            % Inputs: 
            %   - nSidePlots: the number of side plots to be created 
            % Outputs:
            %   - mainAxes: graphic for the main plot's axis
            %   - sideAxes: graphic for the axes of the side plots, (nx1)array
            % -----------------------------------
            figureWidth = 1280;
            figureHeight = 960;
            hPad = 30;
            vPad = 60;
            
            % Create the main figure window
            fig = figure('Position', [100, 100, figureWidth, figureHeight]);
            
            % Calculate widths and heights for the axes
            mainAnimationWidth = figureWidth * 2 / 3 - 2 * hPad;
            sideAnimationsWidth = figureWidth * 1/3 - hPad;
            sideAnimationHeight = (figureHeight - vPad * (nSidePlots + 1)) / nSidePlots; 

            % Add the main animation axes
            mainAxes = axes('Parent', fig, 'Position', [hPad/figureWidth, vPad/figureHeight, mainAnimationWidth/figureWidth, (figureHeight - 2 * vPad)/figureHeight]);

            % Initialize array to store side axes handles
            sideAxes = gobjects(nSidePlots, 1);

            % Add side animation axes
            for i = 1:nSidePlots
                sideAxes(i) = axes('Parent', fig, ...
                    'Position', [(figureWidth - sideAnimationsWidth - hPad)/figureWidth, ...
                    (figureHeight - i * sideAnimationHeight - i * vPad)/figureHeight, ...
                    sideAnimationsWidth/figureWidth, sideAnimationHeight/figureHeight]);
            end
        end 

        

        % -----------------------------
        % 
        % Functions to Handle Main 3D Window Plotting
        % 
        % -----------------------------
        % Function plotOrigin plots fixed origin
        function phf = drawFixedAxes(rangeX, rangeY, rangeZ, offset, parentAxes)
            % -----------------------------------
            % This function draws fixed axis in the main animation window (solid X-Y-Z axes)
            % Input: 
            %   - rangeX, rangeY, rangeZ: arrays specifying the ranges of the X, Y, and Z axes
            %   - offset: vector offset of the the plotted axes from the parent axes
            %   - parentAxes: a handle to the parent axes object
            % Output:
            %   - phf: plot object corresponding the the plotted axis lines, (3x1) array
            % -----------------------------------
            x0 = offset(1);     % creates origin
            y0 = offset(2);
            z0 = offset(3);
            
            phx = plot3(parentAxes, rangeX + x0, [y0 y0], [z0 z0], '-r', 'LineWidth', 2);
            hold(parentAxes, 'on');
            % text(x0, rangeY(1) + y0 , z0, '  y', 'FontSize', 16);       % y label
            phy = plot3(parentAxes, [x0 x0], rangeY + y0, [z0 z0], '-b', 'LineWidth', 2);
            % text(x0, y0, rangeZ(2) + z0, '  z', 'FontSize', 16);        % z label
            phz = plot3(parentAxes, [x0 x0], [y0 y0], rangeZ + z0, '-g', 'LineWidth', 2);
            hold(parentAxes, 'off');

            % Returning handles needed for styling
            phf = [phx, phy, phz];
        end

        function [bodyAxes, phm] = drawBodyAxes(parentAxes)
            % -----------------------------------
            % This function creates visualization for body axes, which moves with the rotating tops
            % Input: 
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            % Output:
            %   - bodyAxes: matrix containing the coordinates for the endpoints of the X, Y, and Z axes
            %   - phm: array of plot corresponding to the plotted axes lines
            % -----------------------------------
            bodyX = [-6,6; 0,0; 0,0];
            bodyY = [0,0; -6,6; 0,0];
            bodyZ = [0,0; 0,0; -6,6];

            % Draw Rotating Axes
            phmx = line(parentAxes, bodyX(1,:), bodyX(2,:), bodyX(3,:), 'Color', 'red', 'Linestyle' , '--', 'LineWidth', 1);
            phmy = line(parentAxes, bodyY(1,:), bodyY(2,:), bodyY(3,:), 'Color', 'blue', 'Linestyle' , '--', 'LineWidth', 1);
            phmz = line(parentAxes, bodyZ(1,:), bodyX(2,:), bodyZ(3,:), 'Color', 'green', 'Linestyle' , '--', 'LineWidth', 1);
            phm = [phmx, phmy, phmz];
            bodyAxes = [bodyX; bodyY; bodyZ];
        end

        % Main Plot Handling
        function [phf, phm, bodyAxes] = initPlotMain(parentAxes)
            % -----------------------------------
            % This function serves as an initializer for a main plot in a 3D animation
            % Input: 
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            % Output:
            %   - bodyAxes: coordinates for the endpoints of the X, Y, and Z axes
            %   - phm: array of plot corresponding to the plotted axes lines
            %   - phf: set of plot corresponding to the fixed axes lines
            % -----------------------------------   
            % Draw Fixed Axis
            phf = AnimationCommon.drawFixedAxes([-6 6], [-6 6], [-6 6], [0 0 0], parentAxes);
            hold(parentAxes, 'on');
            [bodyAxes, phm] = AnimationCommon.drawBodyAxes(parentAxes);
            
            % Styling
            grid(parentAxes, "on");
            camlight(parentAxes, 'left');
            lighting(parentAxes, 'gouraud'); 
            axis(parentAxes, 'equal');
            hold(parentAxes, 'off');
        end

        function updatePlotMain(i, eulers, surfX, surfY, surfZ, surfHandle, phm, bodyAxes)
            % -----------------------------------
            % This function provides update to the body mesh and body axes
            % Input: 
            %   - i: index of Euler angles 
            %   - eulers: Euler angles
            %   - surfX, surfY, surfZ: matrix containing X, Y, Z coordinate
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            %   - surfHandle:  array of handles representing the body mesh in the 3D plot
            %   - phm: array of plot object handles corresponding to the body axes lines
            %   - bodyAxes: coordinates for the endpoints of the X, Y, and Z axes
            % Output: none
            % -----------------------------------  
            bodyX = bodyAxes(1:3,:);
            bodyY = bodyAxes(4:6,:);
            bodyZ = bodyAxes(7:9,:);

            % Update Body Mesh
            nSurf = length(surfHandle);
            if nSurf > 1
                for c=1:length(surfHandle)
                    [Xt, Yt, Zt] = AnimationCommon.rotateSurf(surfX{c}, surfY{c}, surfZ{c}, eulers(i,:));
                    set(surfHandle{c}, "XData",Xt,"YData",Yt,"ZData",Zt);
                end
            else
                [Xt, Yt, Zt] = AnimationCommon.rotateSurf(surfX, surfY, surfZ, eulers(i,:));
                set(surfHandle, "XData",Xt,"YData",Yt,"ZData",Zt);
            end
            % Update Body Axes
            [Xt, Yt, Zt] = AnimationCommon.rotateSurf(bodyX(1,:), bodyX(2,:), bodyX(3,:), eulers(i,:));
            set(phm(1), "XData",Xt,"YData",Yt,"ZData",Zt);
            [Xt, Yt, Zt] = AnimationCommon.rotateSurf(bodyY(1,:), bodyY(2,:), bodyY(3,:), eulers(i,:));
            set(phm(2), "XData",Xt,"YData",Yt,"ZData",Zt);
            [Xt, Yt, Zt] = AnimationCommon.rotateSurf(bodyZ(1,:), bodyX(2,:), bodyZ(3,:), eulers(i,:));
            set(phm(3), "XData",Xt,"YData",Yt,"ZData",Zt);
        end

        

        % -----------------------------
        % 
        % Functions to Handle 2D Plotting
        % 
        % -----------------------------
        function dotHandler = initPlot2D(t, data, gTitle, xLabel, yLabel, lineLegend, xScale, parentAxes)
            % -----------------------------------
            % This function creates visualization in 2D
            % Input: 
            %   - t: time
            %   - data: data used for plot
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            %   - gTitle: graph title
            %   - xLabel, yLabel: labels for x-axis, y-axis
            %   - lineLegend: legend for corresponding data 
            %   - xScale: maximum value for the x-axis
            % Output:
            %   - dotHandler: graphics corresponding to the moving dots plotted on each data series
            % ----------------------------------- 
            minData = min(min(data)) - 0.1;
            maxData = max(max(data)) + 0.1;
            maxData = maxData + (maxData - minData) * 0.2;
            ylim(parentAxes, [minData, maxData]);
            xlim(parentAxes, [0, xScale]);
            
            % Display all lines
            hold(parentAxes, 'on');
            nCol = length(data(1,:));
            lineHandler = gobjects(nCol, 1);
            for c=1:nCol
                lineHandler(c) = plot(parentAxes, t, data(:,c), ...
                                    'color', AnimationCommon.colorPalette(c,:), ...
                                    'LineWidth',2, ...
                                    'DisplayName', lineLegend(c));
            end

            % Deal with moving dots
            dotHandler = gobjects(nCol, 1);
            for c=1:nCol
                dotHandler(c) = plot(t(1), data(1,c), 'o', ...
                                'MarkerSize',10, ...
                                'MarkerFaceColor', AnimationCommon.colorPalette(c,:), ...
                                'Parent', parentAxes);
            end
            hold(parentAxes, 'off');

            % Style the graph
            AnimationCommon.setPlotStyle(gTitle, 12, xLabel, yLabel, lineHandler, lineLegend, parentAxes);
        end

        function updatePlot2D(i, t, data, dots, xScale, parentAxes)
            % -----------------------------------
            % This function updates the visualization in 2D
            % Input: 
            %   - i: current index in the data series
            %   - t: time
            %   - data: data used for plot
            %   - dots: moving dots in each graphic
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            %   - xScale: maximum value for the x-axis
            % -----------------------------------   
            % Update position of dots representing current data point
            for c=1:length(dots)
                set(dots(c), 'XData', t(i), 'YData', data(i,c)); % Move marker
            end

            % Update X window
            % For fixed, xScale will just be length of animation, so no special case is needed.
            xmin = t(max(1,i-xScale * AnimationCommon.frameRate));
            xmax = max(xScale, t(i));
            xlim(parentAxes, [xmin,xmax]);
        end
        
        function setPlotStyle(gTitle, titleSize, xLabel, yLabel, ph, lineLabels, parentAxes)
            % -----------------------------------
            % This function adds legnds, titles, and labels to the 2D graphic
            % Input: 
            %   - gTitle: graph title
            %   - xLabel, yLabel: labels for x-axis, y-axis
            %   - ph: plot handles, (3x1) array
            %   - parentAxes: handle to the parent axes where body axes will be plotted
            %   - lineLabels: labels for data 
            % Output: none
            % -----------------------------------   

            tmph = [];
            for i=1:length(lineLabels)
                tmph = [tmph, ph(i)];
            end
            legend(tmph, lineLabels, 'Location', 'northwest', 'Interpreter', 'latex', "Orientation", "horizontal");
            title(parentAxes, gTitle, "FontSize", titleSize);
            xlabel(parentAxes, xLabel);
            ylabel(parentAxes, yLabel);
        end


        % -----------------------------
        % 
        % Functions to Generate 3D Graphic Objects for Tops
        % 
        % -----------------------------
        function [X,Y,Z] = genSymmetricCylinder(R, L, nNodes)
        % -----------------------------
        % This function generates the coordinates for a symmetric cylinder in 3D space
        % Input:
        %   - R: radius
        %   - L: length
        %   - nNodes: generates polygon cylinder with n faces
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of cylinder
        % -----------------------------
            nCS = L*5;           % Number of Cross-Sections

            r = R .* ones(1, nNodes);
            theta = linspace(0, 2*pi, nNodes);
            z = linspace(0, L, nCS)';
            [x,y] = pol2cart(theta, r);

            X = repmat(x, nCS, 1);
            Y = repmat(y, nCS, 1);
            Z = repmat(z, 1, nNodes);

            x_lid = zeros(2, nNodes);
            y_lid = zeros(2, nNodes);
            z_lid = repmat([0; L], 1, nNodes);

            X = [x_lid(1,:); X; x_lid(2, :)];
            Y = [y_lid(1,:); Y; y_lid(2, :)];
            Z = [z_lid(1,:); Z; z_lid(2, :)];
        end

        function [X,Y,Z] = genSqCylinder(sideLength, length)
        % -----------------------------
        % This function generates a cylinder with a square cross-section
        % Input:
        %   - sideLength
        %   - length
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of cylinder
        % -----------------------------
            [X,Y,Z] = AnimationCommon.genSymmetricCylinder(sideLength, length, 5);
        end

        function [X,Y,Z] = genCylinder(radius, length)
        % -----------------------------
        % This function generates the coordinates for a cylinder in 3D space
        % Input:
        %   - radius
        %   - length
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of cylinder
        % -----------------------------
            [X,Y,Z] = AnimationCommon.genSymmetricCylinder(radius, length, 33);
        end

        function [X,Y,Z] = genSoap(radii, height)
            nNodes = 32; 
            phi = 0:(2*pi/31):2*pi;
            R = (1./(1/radii(1)^2 * cos(phi).^2 + 1/radii(2)^2 * sin(phi).^2)).^(1/2);            % Radius
            L = height;              % Length
            nCS = 10;           % Number of Cross-Sections

            r = R .* ones(1, nNodes);
            theta = linspace(0, 2*pi, nNodes);

            z = linspace(0, L, nCS)';

            [x,y] = pol2cart(theta, r);

            X = repmat(x, nCS, 1);
            Y = repmat(y, nCS, 1);
            Z = repmat(z, 1, nNodes);

            x_lid = zeros(2, nNodes);
            y_lid = zeros(2, nNodes);
            z_lid = repmat([0; L], 1, nNodes);

            X = [x_lid(1,:); X; x_lid(2, :)];
            Y = [y_lid(1,:); Y; y_lid(2, :)];
            Z = [z_lid(1,:); Z; z_lid(2, :)];
        end

        function [X,Y,Z] = genCone(radius, height)
        % -----------------------------
        % This function generates the coordinates for a cone in 3D space
        % Input:
        %   - radius
        %   - length
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of cone
        % -----------------------------
            % Configure
            R = radius;             % Base Radius
            r = 0;             % Tip Radius
            H = height;             % Height
            nCS = height*5;          % Number of Cross-Sections
            nNodes = 33;      % Nodes per Cross-Section
            
            % Draw Cone
            z = linspace(-H/2, H/2, nCS);
            m = -(R - r)/H;
            b = 0.5*(R + r);
            r_local = m*z + b;
            theta = linspace(0, 2*pi, nNodes);
            
            [theta, r_local] = meshgrid(theta, r_local);
            [X, Y] = pol2cart(theta, r_local);
            
            Z = repmat(z', 1, nNodes);
            X = [zeros(1, nNodes); X];
            Y = [zeros(1, nNodes); Y];
            Z = [-H/2*ones(1, nNodes); Z];
        end

        % From the sTopEuler package on MATLAB File Exchange. Credit: Alexander Erlich
        function [x, y, z] = genTorus (a, n, r, kpi)
        % -----------------------------
        % This function generates the coordinates for a cone in 3D space
        % Input:
        %   - a: major radius of torus
        %   - n: number of divisions along the torus's circumference
        %   - r: minor radius of torus
        %   - kpi: A scaling factor that multiplies π to extend or reduce the theta range
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of torus
        % -----------------------------
            % TORUS Generate a torus.
            theta = -pi * (0:2:kpi*n)/n ;
            phi = 2*pi* (0:2:n)'/n ;
            x = (a + r*cos(phi)) * cos(theta);
            y = (a + r*cos(phi)) * sin(theta);
            z = r * sin(phi) * ones(size(theta));
        end

        % Credit: Haley
        function [X,Y,Z] = torusCylinder(a,n,r,kpi)
        % -----------------------------
        % This function generates the coordinates for a 3D shape of torus joint cylinder
        % Input:
        %   - a: major radius of torus
        %   - n: number of divisions along the torus's circumference
        %   - r: minor radius of torus
        %   - kpi: A scaling factor that multiplies π to extend or reduce the theta range
        % -----------------------------
            % TORUS
            r_out = r;        % center hole radius
            r_in = a;           % outer radius
            alpha = 180*kpi;        % arc angle
            nNodes = 21;        % number of cross-sections
            nCS = n;           % number of nodes per cross-section

            theta = linspace(0, 2*pi, nNodes);
            r = 0.5*(r_out - r_in)*ones(1, nNodes);
            z = r.*cos(theta);
            y = r.*sin(theta) + r_in + 0.5*(r_out - r_in);
            x = zeros(1, nNodes);

            phi = linspace(0 , alpha, nCS);
            X = [];
            Y = [];
            Z = [];
            for i = 1:nCS
                temp_CS = AnimationCommon.rotationMatrix('z', phi(i))*[x; y; z];
                X = [X; temp_CS(1, :)];
                Y = [Y; temp_CS(2, :)];
                Z = [Z; temp_CS(3, :)];
            end
        end

        function [X,Y,Z] = genSphere(radius, n)
        % -----------------------------
        % This function generates the coordinates for a 3D shape of sphere
        % Input:
        %   - radius
        %   - n: number of divisions along the sphere's surface
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of sphere
        % -----------------------------  
            [X, Y, Z] = sphere(n);
            X = X * radius;
            Y = Y * radius;
            Z = Z * radius;
        end

        function [X,Y,Z] = genEllipsoid(radiusX, radiusY, radiusZ)
        % -----------------------------
        % This function generates the coordinates for a 3D shape of ellipsoid
        % Input:
        %   - radiusX
        %   - radiusY
        %   - radiusZ
        % Output:
        %   - X, Y, Z: matrix containing the x, y, and z coordinates of points defining surface of ellipsoid
        % -----------------------------
            [X, Y, Z] = sphere;
            X = X * radiusX;
            Y = Y * radiusY;
            Z = Z * radiusZ;
        end
        

        % -----------------------------
        % 
        % Functions to Rotate 3D Objects
        % 
        % -----------------------------
        function ret_mat = EuMat( phi, theta, psi )
        % -----------------------------
        % From the sTopEuler package on MATLAB File Exchange. Credit: Alexander Erlich
        % This function returns a rotation matrix 
        % Input:
        %   - phi: rotation angle about the z-axis
        %   - theta: rotation angle about the x-axis
        %   - psi: rotation angle about the y-axis
        % Output:
        %   - ret_mat: final rotation matrix that combines the three rotations
        % ----------------------------- 
            Dphi = [cos(phi),-sin(phi),0;sin(phi),cos(phi),0;0,0,1];
            Dtheta = [1,0,0;0,cos(theta),-sin(theta);0,sin(theta), cos(theta)];
            Dpsi = [cos(psi),-sin(psi),0;sin(psi),cos(psi),0;0,0,1];
        
            ret_mat = Dphi*Dtheta*Dpsi;
        end

        
        function [ Xt,Yt,Zt ] = multiplyEuMat( EuMat, X,Y,Z )
        % -----------------------------
        % From the sTopEuler package on MATLAB File Exchange. Credit: Alexander Erlich
        % This function returns the coordinates of same object rotated using a rotation matrix
        % Input:
        %   - EuMat: Euler rotation, (3x3) matrix
        %   - X, Y, Z: x, y, and z coordinates of the points to be rotated
        % Output:
        %   - Xt, Yt, Zt:  x, y, and z coordinates after applying the rotation
        % ----------------------------- 
            %MULTIPLYEUMAT takes the X, Y, Z coordinates of an object and returns the
            %coordinates Xt, Yt, Zt of same object rotated using a rotation matrix
            Xt=X;
            Yt=Y;
            Zt=Z;
            
            resvec=[1;1;1];
            for i=1:numel(X)
               temp=[X(i);Y(i);Z(i)];
               resvec=EuMat*temp;
               Xt(i) = resvec(1);
               Yt(i) = resvec(2);
               Zt(i) = resvec(3);
            end
        end

        function [Xt, Yt, Zt] = rotateSurf(X, Y, Z, euler)
        % -----------------------------
        % This function rotates the surface in 3D space
        % Input:
        %   - euler
        %   - X, Y, Z: x, y, and z coordinates of the points to be rotated
        % Output:
        %   - Xt, Yt, Zt:  x, y, and z coordinates after applying the rotation
        % ----------------------------- 
            mat = AnimationCommon.EuMat(euler(1), euler(2), euler(3));
            [Xt, Yt, Zt] = AnimationCommon.multiplyEuMat(mat, X, Y, Z);
        end




        % -----------------------------
        % 
        % Functions for I/O, or util functions
        % 
        % -----------------------------
        function path = genVideoPath(csvFile, vidTitle)
        % -----------------------------
        % This function constructs a path for saving a video file based on a given CSV file path
        % Input:
        %   - csvFile: full path to a CSV file
        %   - vidTitle: title for video
        % Output:
        %   - path:  full path where the video is saved
        % ----------------------------- 
            curTime = datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd_HH-mm-ss'); 
            [csvPath,csvName,ext] = fileparts(csvFile);
            animPath = convertStringsToChars(csvPath);
            animPath = animPath(1:end-4);
            path = fullfile(convertCharsToStrings(animPath) + "animations/", ...
                            string(curTime) + '_' + vidTitle);
        end

    end % Methods
    
end % AnimationCommon