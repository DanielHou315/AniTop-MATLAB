% ------------------------------------
% University of Michigan LoG(M) 2024WN Tops Team 2024/03

% This is the main function for AniTop package.

% Example Usage:
% In MATLAB command window
% >>> AniTop

% Primary Functions:
%   -- AniTop(): this is the driver function

% Parameters/Properties:
%   -- Configuration of the driver is done through config/config.json.
%   -- Please refer to README for details.

% Generative AI Disclaimer:
%  -- This class implementation is free of Generative AI output.
% ------------------------------------

function AniTop()
    % ------------------------
    % The driver function for the entire AniTop project.
    % ------------------------

    % Setup Paths
    packageRoot =  getPackageRootPath();

    % Create and add necessary Paths
    createReqPaths();
    addpath(packageRoot+"/matlab/animation");
    addpath(packageRoot+"/matlab/sim");

    % Read Config
    config = readConfig();
    mode = config.mode;
    verboseMode = config.verbose;

    % Get animation configs
    animateMode = config.animation.kernel;
    sliding_window = config.animation.sliding_window;

    % Do single sim & animation, see config/README for details
    if mode == "single"
        configList = [getSingleConfig(config)];
        
    % Do one-to-one sim & animation, se config/README for details
    elseif mode == "one-to-one"
        configList = genOne2OneConfigs(config);

    % Do grid style sim & animation, see config/README for details
    elseif mode == "grid"
        % configList = genGridConfigs(config);
        disp("Grid Mode is being worked on! Exiting...");
        return;

    % Otherwise, illegal config
    else
        disp("Rendering Mode " + mode + " is NOT AVAILABLE! Exiting...")
        return;
    end

    % Animate each
    for i=1:length(configList)
        animateOneTop(configList(i), i+"-th_Top: "+configList.top, ...
                animateMode, sliding_window, verboseMode);
    end
end



function animateOneTop(simConfig, vidName, ...
                    animationKernel, sliding_window, verboseMode)
    % ------------------------------------
    % This function simulates and animates one top configuration
    % ------------------------------------

    % Euler Top Config
    if simConfig.top == "euler"
        top = SimEuler(simConfig.I, simConfig.omega0, simConfig.euler0);
        animator = AnimationEuler(sliding_window);

    % Lagrange Top Config
    elseif simConfig.top == "lagrange"
        % Additional information needed
        P0 = simConfig.omega0 .* simConfig.I;
        top = SimLagrange(simConfig.I, simConfig.euler0, simConfig.P0, simConfig.mgl, simConfig.omega0);
        animator = AnimationLagrange(sliding_window);

    % Kovalevskaya Top Config
    elseif simConfig.top == "kovalevskaya"
        P0 = simConfig.omega0 .* simConfig.I;
        top = SimKov(simConfig.I, simConfig.euler0, P0, simConfig.mga);
        animator = AnimationKov(sliding_window);
    else
        disp("Top " + topMode + " is not available!");
        return;
    end

    % Do Simulation
    simResultFile = top.simulate(verboseMode);
    disp("Top Simulate with result in " + simResultFile);

    % Deal with Non-Default Animators
    if animationKernel == "Tops"
    elseif animationKernel == "TopEuler"
        addpath(pwd+"/../TopEuler/");
        animator = TopEulerWrapper(config);
    elseif animationKernel == "none"
        disp("Animation Skipped...")
        return;
    else
        disp("Animation Kernel " + animator + " not supported! Check your config file.");
        return;
    end

    % Do Animation
    animationVideoFile = animator.animate(simResultFile, vidName);
    disp("Animation Successfully rendered and stored as " + animationVideoFile);
end






% ------------------------------------
%
% Config Helper Functions
%
% ------------------------------------

function simConfig = getSingleConfig(config)
    topMode = config.sim.tops(:);
    I = config.sim.init_moment_inertia(:,:);
    omega0 = config.sim.init_ang_velocity(:, :);
    euler0 = deg2rad(config.sim.init_heading(:,:));

    simConfig = struct("top", topMode(1), "I", I(1,:), "omega0", omega0(1,:), "euler0", euler0(1,:), "mgl",0, "mga", 0);

    if topMode(1) == "lagrange"
        simConfig.mgl = config.sim.mgl(1);
    elseif topMode(1) == "kovalevskaya"
        simConfig.mga = config.sim.mga(1);
    end
end

function configList = genOne2OneConfigs(config)
    % ------------------------------------
    % Check whether length of each initial conditions is the same
    % If condition isn't met, an error is thrown and function will exit.
    % Otherwise, generate n configurations for each combination. 
    % ------------------------------------
    topMode = config.sim.tops(:);
    I = config.sim.init_moment_inertia(:,:);
    omega0 = config.sim.init_ang_velocity(:, :);
    euler0 = deg2rad(config.sim.init_heading(:,:));

    nTops = length(topMode);
    assert(nTops == length(I(:,1)));
    assert(nTops == length(omega0(:,1)));
    assert(nTops == length(euler0(:,1)));

    configList = [];
    for i = 1:nTops
        simConfig = struct("top", topMode(i), "I", I(i,:), "omega0", omega0(i,:), "euler0", euler0(i,:), "mgl",0, "mga", 0);

        if topMode(1) == "lagrange"
            simConfig.mgl = config.sim.mgl(i);
        elseif topMode(1) == "kovalevskaya"
            simConfig.mga = config.sim.mga(i);
        end

        configList = [configList, simConfig];
    end
end

% function configList = genGridConfigs(config)
%     % ------------------------------------
%     % Generate sim configurations for each combination in grid mode. 
%     % ------------------------------------
%     topMode = config.sim.tops(:);
%     I = config.sim.init_moment_inertia(:,:);
%     omega0 = config.sim.init_ang_velocity(:, :);
%     euler0 = deg2rad(config.sim.init_heading(:,:));
%     mgl = config.sim.mgl(:);
%     mga = config.sim.mga(:);

%     dataList = {topMode, I, omega0, euler0, mgl, mga};
%     fieldNames = ["top", "I", "omega0", "euler0", "mgl", "mga"];

%     configList = [];
%     baseConfig = struct("top", "_placeholder", "I", 0, "omega0", 0, "euler0", 0, "mgl",0, "mga", 0);
%     recursiveGenGridConfig(baseConfig, dataList, fieldNames, 1, configList);
% end

% function recursiveGenGridConfig(existingConfig, dataList, fieldNames, i, configList)
%     newConfig = existingConfig;
%     % Base case: we are done
%     if i > length(dataList)
%         configList = [configList, newConfig];
%         return
%     end

%     % Assign for current array
%     arr = dataList(i);

%     % Iterate through options, assign, and recurse
%     for j=1:length(arr)
%         if i <= 4
%             disp(newConfig);
%             disp(fieldNames(i));
%             setfield(newConfig, fieldNames(i), arr(j,:));
%         else
%             if newConfig.top == "lagrange"
%                 newConfig.mgl = arr;
%             elseif newConfig.top == "kovalevskaya"
%                 newConfig.mga = arr;
%             end
%         end
%         recursiveGenGridConfig(newConfig, dataList, fieldNames, i+1, configList);
%     end
% end

% ------------------------------------
%
% Path Helper Functions
%
% ------------------------------------
function config = readConfig()
    % ------------------------------------
    % Open Config File, read and return raw string
    % ------------------------------------
    configFile = getDefaultConfigPath();

    % Read file and decode json
    fid = fopen(configFile);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    config = jsondecode(str);
end

function path = getPackageRootPath()
    % ------------------------------------
    % Get the string of absolute path of package root on local machine
    % ------------------------------------
    st = dbstack;
    f = st.file;
    mainFilePath = which(f(1:end-2));
    path = mainFilePath(1:end-15);
end


function createReqPaths()
    % ------------------------------------
    % Create required data and animation paths to store outputs.
    % ------------------------------------
    animPath = fullfile(getPackageRootPath(), 'animations');
    dataPath = fullfile(getPackageRootPath(), 'data');
    % Check if the data directory exists, if not, create it
    if ~exist(animPath, 'dir')
        mkdir(animPath);
    end
    if ~exist(dataPath, 'dir')
        mkdir(dataPath);
    end
end


function path = getDefaultConfigPath()
    % ------------------------------------
    % Get the absolute path of the default config.json file on local machine.
    % Creates default config.json from template if none exists.
    % ------------------------------------
    configPath = convertCharsToStrings(getPackageRootPath())+"config";
    % Check if the data directory exists, if not, create it
    if ~exist(configPath, 'dir')
        mkdir(configPath);
    end

    % Define the full path to the config file
    path = fullfile(configPath, 'config.json');

    % If config does not exist, make one
    if ~exist(path, 'file')
        copyfile(path+".template", path);
        disp("WARNING: No config file found, using default config. You SHOULD change the config as seen fit.");
    end
end