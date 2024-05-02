% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03

% This class implements methods for Lagrange Tops simulation

% Example Usage:
% >>> sim = SimLagrange([2,2,5], [0,30,0]. [7,8,9], 1, [0,0,2]);
% >>> dataFile = sim.simulate();

% Primary Functions:
%   -- simulate(): simulates Lagrange tops motion

% Depends on:
%   -- SimHelper

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef SimLagrange
    properties(SetAccess=private)
        I = zeros(3,1);
        euler0 = zeros(3,1);
        P0 = zeros(3, 1);
        mgl = 9.8; % Let default be 1 * 9.8 * 1
        omega0;
        verbose = false;
    end

    methods
        function obj = SimLagrange(I0, euler0, P0, mgl, omega0)
            % ------------------------------------
            % obj is the constructor for the SimLagrange class
            % and parameters for obj 
            % 
            % Input:
            %   - I0: moments of inertia, (3x1) array
            %   - euler0: initial heading, (3x1) array
            %   - Omega0: initial angular velocities, (3x1) array
            % Output:
            %    - Angular accelerations, (Nx3) array
            % ------------------------------------
            arguments
                I0 (3,1) {mustBeNumeric};
                euler0 (3,1) {mustBeNumeric};
                P0 (3,1) {mustBeNumeric};
                mgl {mustBeNumeric};
                omega0 (3,1) {mustBeNumeric};
            end
            obj.I = I0;
            assert(I0(1) == I0(2)); % Make sure first and seond moments of inertia are the same
            obj.euler0 = euler0;
            obj.P0 = P0;
            obj.omega0 = omega0;
            obj.mgl = mgl;
        end

        function simDataFile = simulate(obj, verbose)
            % ------------------------------------
            % obj function is an interface between static computing functions 
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

            % Compute Euler Angles
            [t, eulerAngles, eulerRates, Ueff] = SimLagrange.calcVars(obj.I, obj.P0, obj.euler0, obj.omega0(2), obj.mgl);

            % eulerAngles = wrapTo2Pi(eulerAngles);
            
            if verbose == true
                % Euler Angle and Rates
                SimHelper.PlotData3D(t, eulerAngles,"EulerAngle");
                SimHelper.PlotData3D(t, eulerRates,"EulerRate");
            end

            % Save the output
            simDataFile = SimLagrange.saveDataLagrange(t, eulerAngles, eulerRates, Ueff);
            
            if obj.verbose == true
                disp(simDataFile+" saved successfully.");
            end
        end
    end % Member Methods


    methods(Static)
        function [t, eulerAngles, eulerRates, Ueff] = calcVars(I, P, euler0, dTheta0, mgl)
            % ------------------------------------
            % This function computes values of interest. 
            % Input:
            %   - I: moments of inertia, (3x1) array
            %   - P: angular momentum, (3x1) array
            %   - euler0: initial Euler angles, (3x1) array
            %   - dTheta0: initial angular velocity, scalar
            %   - mgl: product of mass, gravity, and length, scalar
            % Output:
            %   - t: time points array
            %   - Y: solution array with phi, theta, psi, and dTheta over time
            % ------------------------------------
        
            % Time span
            timeSeries = 0:0.04:20;
        
            % Compute Constants
            a = P(3) / I(1);
            b = P(1) / I(1);
            beta = 2 * mgl / I(1);
        
            % Initial conditions vector
            Y0 = [euler0; dTheta0]; 
        
            % Solve the system of ODEs
            [t, eulerAngles] = ode45(@(t, Y) SimLagrange.diffFunc(t, Y, I, a, b, beta), timeSeries, Y0);
            eulerAngles = eulerAngles(:,1:3);

            % Compute Euler Rate
            eulerRates = SimLagrange.calcEulerRate(t, eulerAngles);
            % Compute Effective Potential
            Ueff = SimLagrange.calcUeff(eulerAngles(:,2),I,a,b,mgl);
        end
        
        function dYdt = diffFunc(t, Y, I, a, b, beta)
            % ------------------------------------
            % This function defines the system of ODEs to solve
            % Input:
            %   - t: implicit
            %   - Y: variables of interest (initial conditions), (4x1 array)
            %   - I: moment of inertia (3x1) array
            %   - a,b,beta: constants, scalars, see Theory.md
            % Output:
            %   - dYdt: differential quantity
            % ------------------------------------
        
            phi = Y(1);
            theta = Y(2);
            psi = Y(3);
            dTheta = Y(4);
        
            % Equations
            dPhidt = (b - a * cos(theta)) / sin(theta)^2;
            dThetadt = dTheta;
            dPsidt = a * (I(1)-I(3)) - (b - a*cos(theta))*cos(theta) / sin(theta)^2;
            d2Thetadt = (a^2+b^2)*cos(theta)/sin(theta)^3 - a*b*(3+cos(2*theta))/(2*sin(theta)^3) + beta/2*sin(theta);
        
            % Output derivative vector
            dYdt = [dPhidt; dThetadt; dPsidt; d2Thetadt];
        end

        function [eulerRates] = calcEulerRate(t, eulerAngles)
            % ------------------------------------
            % This function defines the system of ODEs to solve
            % Input:
            %   - t: time series (Nx1 array)
            %   - eulerAngles: euler angles (Nx3 array)
            % Output:
            %   - eulerRates (Nx3 array)
            % ------------------------------------
            euler2 = [eulerAngles; eulerAngles(:,2:-1)];
            euler1 = [eulerAngles(1); eulerAngles(1:-2)];
            eulerDiff = euler2 - euler1;
            eulerRates = eulerDiff ./ t;
        end

        function Ueff = calcUeff(theta,I,a,b,mgl)
            % ------------------------------------
            % This function calculates effective potential for particular Lagrange system
            % Input:
            %   - theta: series of theta angles
            %   - I: moment of inertia (3x1 array)
            %   - a,b: constants, see Theory.md
            %   - mgl: mass*gravity_constant*length (scalar)
            % Output:
            %   - Ueff: effective potential (Nx1 array)
            % ------------------------------------
            u1 = I(1)/2 .* ((b*ones(size(theta))-a.*cos(theta)) ./ sin(theta)).^2;
            u2 = mgl .* cos(theta);
            Ueff = u1 + u2;
        end

        function csvFilePath = saveDataLagrange(t, eulerAngles, eulerRates, Ueff)
            % ------------------------------------
            % Saves data of interest
            % ------------------------------------
            arguments
                t (:,1) {mustBeNumeric};
                eulerAngles (:, 3) {mustBeNumeric};
                eulerRates (:,3) {mustBeNumeric};
                Ueff {mustBeNumeric};
            end

            csvFilePath = SimHelper.getDataPath("SimLagrange");

            eulerRate1 = eulerRates(:,1); eulerRate2 = eulerRates(:,2); eulerRate3 = eulerRates(:,3);
            eulerAngle1 = eulerAngles(:,1); eulerAngle2 = eulerAngles(:,2); eulerAngle3 = eulerAngles(:,3);

            eulerTable = table(t, ...
                eulerAngle1, eulerAngle2, eulerAngle3, ...
                eulerRate1, eulerRate2, eulerRate3, ...
                Ueff);
            writetable(eulerTable,csvFilePath,'WriteRowNames',true); 
        end
    end % Helper Methods
end % SimEuler Class
