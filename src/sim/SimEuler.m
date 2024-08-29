% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/02

% This class implements methods for Euler Tops simulation

% Example Usage:
% >>> sim = SimEuler([1,2,3], [4,5,6]. [7,8,9]);
% >>> dataFile = sim.simulate();

% Primary Functions:
%   -- simulate(): simulates Eulertops motion

% Depends on:
%   -- SimHelper

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef SimEuler
    properties(SetAccess=private)
        I = zeros(3,1);
        omega0 = zeros(3,1);
        euler0 = zeros(3,1);
    end

    methods
        function obj = SimEuler(I0, omega0, euler0)
            % ------------------------------------
            % This is the constructor for the SimEuler class
            % and parameters for this 
            % 
            % Input:
            %   - omega0: initial angular velocities, (3x1) array
            %   - I0: moments of inertia, (3x1) array
            %   - Euler0: initial Euler angles, (3x1) array
            %   - verbose: flag used for debugging
            % Output:
            %   - obj: constructor initialized with provided input parameters
            % ------------------------------------
            arguments
                I0 (3,1) {mustBeNumeric};
                omega0 (3,1) {mustBeNumeric};
                euler0 (3,1) {mustBeNumeric};
            end
            obj.I = I0;
            obj.omega0 = omega0;
            obj.euler0 = euler0;
        end


        function simDataFile = simulate(this, verbose)
            % ------------------------------------
            % This function is an interface between static computing functions 
            % and parameters for Euler Top simulation. 
            % 
            % Input:
            %   - verbose: whether to produce debug output
            % Output:
            %    - SimDataFile: str
            % Rquires: 
            %   - The REQUIRED properties must be set by the constructor explicitly. 
            %   - Simulating with placeholder parameters will cause undefined behavior. 
            % ------------------------------------
            [t, omega] = SimEuler.calcVars(this.I, this.omega0);

            % Compute Euler Angle Sequence
            [t, eulerAngles, eulerRates] = SimEuler.calcEulerAngles(t, this.I, omega, this.euler0);
            % eulerAngles = wrapTo2Pi(eulerAngles);

            if verbose == true
                % We can also see that angular velocities form an ellipse.
                SimHelper.plotData3D(t, omega, "\omega");
                
                % We can also test energy conservation and verify with initial value
                energies = SimHelper.calcEnergy(this.I, omega);
                SimHelper.plotEM(t, energies, "e");

                % We can also test energy conservation and verify with initial value
                momenta = SimHelper.calcMomentum(this.I, omega);
                SimHelper.plotEM(t, momenta, "m");

                % this.verbose Euler Angle and Rates
                SimHelper.plotData3D(t, eulerAngles,"EulerAngle");
                SimHelper.plotData3D(t, eulerRates,"EulerRate");
            end

            % Save the output
            simDataFile = SimEuler.saveDataEuler(t, omega, eulerRates, eulerAngles);
            
            disp(simDataFile+" saved successfully.");
        end
    end % Member Methods


    methods(Static)
    % ------------------------------------
    % 
    % This section contains TESTED compute functions for Euler Top Sim
    % 
    % ------------------------------------
        function [t,omega] = calcVars(I, omega0)
            % ------------------------------------
            % This function use the ode45 package to solve differential equations
            % 
            % Input:
            %   - omega0: angular velocities, (3x1) array
            %   - I: moments of inertia, (3x1) array
            % Output:
            %   - omega: angular velocities, (3x3) matrix 
            %   - Time: the time points which angular velocities are computed
            % ------------------------------------
            arguments
                I (3,1) {mustBeNumeric};
                omega0 (3,1) {mustBeNumeric};
            end
            timeSeries = 0:0.04:20;
            [t,omega] = ode45(@(t,omega) SimEuler.difffunc(t,I,omega), timeSeries, omega0);
        end

        function dOmegadt = difffunc(t,I,omega)
            % ------------------------------------
            % This function defines the differential equation that we solve with ode45
            % 
            % Input:
            %   - t: time, (Nx1) array
            %   - I: moments of inertia, (3x1) array
            %   - omega: angular velocities, (3x1) array
            % Output:
            %    - domegadt: rates of change of the angular velocities,
            %    (3x1) array
            % ------------------------------------
            omegaDot1 = (I(2) - I(3)) / I(1) * omega(2) * omega(3);
            omegaDot2 = (I(3) - I(1)) / I(2) * omega(1) * omega(3);
            omegaDot3 = (I(1) - I(2)) / I(3) * omega(1) * omega(2);

            dOmegadt = [omegaDot1; omegaDot2; omegaDot3];
        end

        function [t, eulerAngles, eulerRates] = calcEulerAngles(t, I, omega, euler0)
            % ------------------------------------
            % This function calculates the Euler Angles given initial conditions
            % 
            % Input:
            %   - t: time, (Nx1) array
            %   - I: moments of inertia, (3x1) array
            %   - omega: angular velocities, (3x1) array
            % Output:
            %    - Euler Angles: calculated over time, (Nx3) array
            %    - Euler Rates: calculated over time, (Nx3) array
            % ------------------------------------
            % Initialize Euler Angles
            eulerAngleSum = euler0;
            ts = length(t);
            eulerAngles = zeros(ts, 3);
            eulerRates = zeros(ts,3);

            deltaT = 0;
            for i = 1:ts
                if i ~= ts
                    deltaT = t(i+1) - t(i);
                end
                eulerAngleRate = SimEuler.calcEulerAngleRate(omega(i,:), eulerAngleSum);
                eulerAngleSum = eulerAngleSum + eulerAngleRate * deltaT;
                eulerAngles(i,:) = eulerAngleSum;
                eulerRates(i,:) = eulerAngleRate;
            end
        end

        function [eulerAngleRate] = calcEulerAngleRate(omega,prevEulerAngle)
            % ------------------------------------
            % This function calculates the Euler Angle rates given the
            % euler angles calculated by previous function
            % 
            % Input:
            %   - omega: angular velocities, (3x1) array
            %   - prevEulerAngles: previously calculated Euler Angles, (3x1) array
            % Output:
            %   - EulerAngleRate: rate of change of Euler Angles, (3x1) array
            % ------------------------------------

            % Get the angles in a nice way to work with
            [phi, theta, psi] = SimEuler.adjustEulerFromQuat(prevEulerAngle(1), prevEulerAngle(2), prevEulerAngle(3));
            % phi = prevEulerAngle(1);
            % theta = prevEulerAngle(2);
            % psi = prevEulerAngle(3);

            Dphi = [sin(psi)/sin(theta),cos(psi)/sin(theta),0];
            Dtheta = [cos(theta), sin(psi), 0];
            Dpsi = [-cos(theta)*sin(psi) / sin(theta), -cos(theta)*cos(psi)/sin(theta), 1];
            M = [Dphi;Dtheta;Dpsi];

            eulerAngleRate = M * transpose(omega)
        end

        function [phi, theta, psi] = adjustEulerFromQuat(phi, theta, psi)
            % Convert Euler angles to quaternion
            % MATLAB's eul2quat uses the 'ZYX' sequence by default, which matches [psi, theta, phi]
            q = eul2quat([psi, theta, phi]);
            % Extract quaternion components for clarity
            qw = q(1); qx = q(2); qy = q(3); qz = q(4);
            
            % Calculate the test value for singularity check
            test = qx*qy + qz*qw;
            
            % Handle north pole singularity
            if test > 0.499
                psi = 2 * atan2(qx, qw);
                theta = pi / 2;
                phi = 0;
                return;
            end
            
            % Handle south pole singularity
            if test < -0.499
                psi = -2 * atan2(qx, qw);
                theta = -pi / 2;
                phi = 0;
                return;
            end
            
            % If no singularity, calculate adjusted Euler angles based on quaternion
            % sqx = qx^2;
            % sqy = qy^2;
            % sqz = qz^2;
            % psi = atan2(2*qy*qw - 2*qx*qz , 1 - 2*sqy - 2*sqz);
            % theta = asin(2*test);
            % phi = atan2(2*qx*qw - 2*qy*qz , 1 - 2*sqx - 2*sqz);
        end
        

        function csvFilePath = saveDataEuler(t, omega, eulerRates, eulerAngles)
            % ------------------------------------
            % This function output the csv file containing simulation data
            % ------------------------------------
            arguments
                t (:,1) {mustBeNumeric};
                omega (:, 3) {mustBeNumeric};
                eulerRates (:, 3) {mustBeNumeric};
                eulerAngles (:, 3) {mustBeNumeric};
            end
            csvFilePath = SimHelper.getDataPath("SimEuler");

            omega1 = omega(:,1); omega2 = omega(:,2); omega3 = omega(:,3);
            eulerRate1 = eulerRates(:,1); eulerRate2 = eulerRates(:,2); eulerRate3 = eulerRates(:,3);
            eulerAngle1 = eulerAngles(:,1); eulerAngle2 = eulerAngles(:,2); eulerAngle3 = eulerAngles(:,3);

            eulerTable = table(t, ...
                eulerAngle1, eulerAngle2, eulerAngle3, ...
                omega1, omega2, omega3, ...
                eulerRate1, eulerRate2, eulerRate3);
            writetable(eulerTable,csvFilePath,'WriteRowNames',true); 
        end
    end % Helper Methods
end % SimEuler Class


