% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/04

% This class implements methods for Kovalevskaya Tops simulation

% Example Usage:
% >>> sim = SimKov([2,2,1], [0,30,0]. [7,8,9], 1);
% >>> dataFile = sim.simulate();

% Primary Functions:
%   -- simulate(): simulates Kovalevskaya tops motion

% Depends on:
%   -- SimHelper

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef SimKov
  
    properties(SetAccess=private)
        I = 0;
        euler0 = zeros(3,1);
        P0 = zeros(3,1);
        mga = 0;
    end


    methods
        function obj = SimKov(I, euler0, P0, mga)
            % ------------------------------------
            % This is the constructor for the SimEuler class
            % 
            % Input:
            %   - I: moments of inertia, (3x1) array
            %   - euler0: initial heading, (3x1) array
            %   - P0: initial angular momentum, orgahized in (P-Phi, P-Theta, P-Psi) order.
            %   - mga: m*g*a term of the Kovalevskaya top expression. See Theory.md
            % Output:
            %    - None
            % ------------------------------------
            arguments
                I (3,1) {mustBeNumeric};
                euler0 (3,1) {mustBeNumeric};
                P0 {mustBeNumeric};
                mga {mustBeNumeric};
            end
            assert(I(1) == I(2) && I(3)*2 == I(1));
            obj.I = I(1);
            obj.euler0 = euler0;
            obj.euler0(2) = euler0(2)+1e-9;
            obj.P0 = P0;
            obj.mga = mga;
        end

        function simDataFile = simulate(obj, verbose)
            % ------------------------------------
            % This function is an interface between static computing functions 
            % and parameters for Euler Top simulation. 
            % 
            % Input:
            %   - None
            % 
            % Output:
            %    - SimDataFile: str
            % 
            % Rquires: 
            %   - The REQUIRED properties must be set by the constructor explicitly. 
            %   - Simulating with placeholder parameters will cause undefined behavior. 
            % ------------------------------------
            % Calculate variables
            [t, eulerAngles, angMomentum] = SimKov.calcVars(obj.I, obj.P0, obj.euler0, obj.mga);
            % eulerAngles = wrapTo2Pi(eulerAngles);

            % Save the output
            simDataFile = SimKov.saveDataKov(t, eulerAngles, angMomentum);
            
            if verbose == true
                disp(simDataFile+" saved successfully.");
            end
        end
    end % Member Methods


    methods(Static)
        function [t, eulerAngles, angMomentum] = calcVars(I, P0, euler0, mga)
            % ------------------------------------
            % Input:
            %   - I: initial moments of inertia, (3x1) array
            %   - P: initial angular momentum, (3x1) array
            %   - euler0: initial Euler angles, (3x1) array
            %   - mga: product of mass, gravitational constant, and CoM offset from symmetry axis, scalar
            % Output:
            %   - t: time points array
            %   - Y: solution array with phi, theta, psi, and dTheta over time
            % ------------------------------------
        
            % Time span
            timeSeries = 0:0.04:20;
        
            % Initial conditions vector
            Y0 = [euler0;P0(2:3)'];
            pPhi = P0(1);
        
            % Solve the system of ODEs
            [t, vars] = ode45(@(t, Y) SimKov.diffFunc(t, Y, I, pPhi, mga), timeSeries, Y0);
            eulerAngles = vars(:,1:3);
            pTheta = vars(:,4);
            pPsi = vars(:,5);
            pPhi = pPhi.*ones(size(pTheta));

            angMomentum = [pPhi,pTheta,pPsi];

            % % Compute Euler Rate
            % eulerRates = SimLagrange.calcEulerRate(t, eulerAngles);
            % % Compute Effective Potential
            % Ueff = SimLagrange.calcUeff(t,eulerAngles(:,2),I,a,b,mgl);
        end

        function dYdt = diffFunc(t, Y, I, pPhi, mga)
            % This function defines the system of ODEs to solve
        
            phi = Y(1);
            theta = Y(2);
            psi = Y(3);
            pTheta = Y(4);
            pPsi = Y(5);
        
            % Equations
            dPhidt = (pPhi - pPsi * cos(theta)) / (I*sin(theta)^2);
            dThetadt = pTheta / I;
            dPsidt = -pPsi/(2*I) - (pTheta-pPsi)*cos(theta) / (2*I*sin(theta).^2);

            dPTheta = -(pTheta-pPsi*cos(theta)*pPsi*sin(theta))/(2*I*sin(theta)^2) + (pPhi-pPsi*cos(theta))^2/(2*I*sin(theta)^3)*cos(theta)-mga*cos(theta)*sin(psi);
            dPPsi = -mga * sin(theta) * cos(psi);
        
            % Output derivative vector
            dYdt = [dPhidt; dThetadt; dPsidt; dPTheta; dPPsi];
        end

        function csvFilePath = saveDataKov(t, eulerAngles, angMomentum)
            % ------------------------------------
            % This function saves data with formats specific to the Kovalevskaya Top Simulation
            % ------------------------------------
            arguments
                t (:,1) {mustBeNumeric};
                eulerAngles (:, 3) {mustBeNumeric};
                angMomentum (:, 3) {mustBeNumeric};
            end
            % Get File Name
            csvFilePath = SimHelper.getDataPath("SimKov");

            % Extract data
            eulerAngle1 = eulerAngles(:,1); eulerAngle2 = eulerAngles(:,2); eulerAngle3 = eulerAngles(:,3);
            pPhi = angMomentum(:,1);pTheta = angMomentum(:,2);pPsi = angMomentum(:,3);

            % write table
            eulerTable = table(t, ...
                eulerAngle1, eulerAngle2, eulerAngle3, ...
                pPhi, pTheta, pPsi);
            writetable(eulerTable,csvFilePath,'WriteRowNames',true); 
        end
    end % Helper Methods
end % SimEuler Class
  
  
  