% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03/11

% This is the TopEulerWrapper class. This program wraps around the TopEuler package by Alexander Erlich for animation.

% Example Usage:
% >>> animator = TopEulerWrapper(config);

% Primary Functions:
%   -- animate(obj, csvFile, vidTitle): animates tops motion and records video from data in csvFile

% Parameters/Properties:
%   -- config: dummy, not used. This is to stay consistent with other classes

% Depends on:
%   -- TopEuler

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef TopEulerWrapper
    
    methods
        function obj = TopEulerWrapper(cfg)
            disp("WARNING: TopEuler Wrapper IGNORES vidName and config!");
        end
        
        function vidFile = animate(obj, csvFile, vidTitle)
            % ------------------------------------
            % This function generates an animation and saves a video file given the simulated data.
            % Input:
            %   - obj: constructor initialized with given data
            %   - csvFile: path to the csv file that contains the simulated data
            %   - vidTitle: title for the video that will be generated
            % Output:
            %   - vidFile: path to the video file that will be generated
            % ------------------------------------
            arguments
                obj;
                csvFile {mustBeText};
                vidTitle {mustBeText};
            end
            
            % Preprocess data
            disp("WARNING: TopEuler Wrapper IGNORES vidName!");
            disp("CSV: "+csvFile);
            datFile = TopEulerWrapper.topEulerCSV2DAT(csvFile);

            % Configure video file name and paths
            [csvPath,csvName,ext] = fileparts(csvFile);
            animPath = convertStringsToChars(csvPath);
            animPath = animPath(1:end-4);
            vidFile = convertCharsToStrings(animPath) + "animations/" + csvName + "_TopEulerAnim.mp4";
            disp("Saving video in "+vidFile);

            % Actually animate and render video
            sTopMainWVideo(datFile, vidFile);
            
            % This is a temporary .dat file, so it should be deleted
            disp("Deleting temporary file: "+datFile);
            delete(datFile);
        end
    end
        
    methods(Static)
        function datFile = topEulerCSV2DAT(csvFile)
            % ------------------------------------
            % This function convert the contents of a CSV file into a DAT file
            % Input:
            %   - obj: constructor initialized with given data
            %   - csvFile: path to the csv file that contains the simulated data
            % Output:
            %   - datFile: path to the newly created DAT file
            % ------------------------------------
            table = readtable(csvFile);
            output = table2array(table(:,1:4));
            datFile = csvFile +'.dat';
            save(datFile,'output', '-ascii');
            disp("Temporary data saved in "+datFile);
        end
    end % Methods
end