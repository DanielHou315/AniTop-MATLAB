% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/04

% This class implements methods for a video writer integrated in Tops animations

% Example Usage:
% >>> vid_writer = VidWriter()

% Primary Functions:
%   -- writeFrame(): records current frame to video buffer

% Depends on:
%   -- None

% This class implementation is free of Generative AI output.
% ------------------------------------

classdef VidWriter
    properties
        vidFile;
        writer;  
    end

    methods
        function obj = VidWriter(vidFile)
            % ------------------------------------
            % This is the constructor opening video editor
            % 
            % Input:
            %   - vidFile: path or name of the video file to be created
            % Output:
            %   - obj: output of the constructor
            % ------------------------------------
            obj.vidFile = vidFile;
            obj.writer = VideoWriter(obj.vidFile, 'MPEG-4');
            obj.writer.Quality = 100;
            obj.writer.FrameRate = AnimationCommon.frameRate;
            open(obj.writer);
        end

        function writeFrame(obj)
            % ------------------------------------
            % This function writes current frame into video buffer
            % ------------------------------------
            frame = getframe(gcf); % gcf gets the current figure
            writeVideo(obj.writer, frame); % Add the frame to the video
        end

        function close(obj)
            close(obj.writer);
        end
    end % Methods
end