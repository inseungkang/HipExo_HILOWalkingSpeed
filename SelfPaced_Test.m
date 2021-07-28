function MarkerY = PRG_SelfPace
%     % Program options
%     TransmitMulticast = false;
%     EnableHapticFeedbackTest = false;
%     HapticOnList = {'ViconAP_001';'ViconAP_002'};
%     bReadCentroids = false;
%     bReadRays = false;
%     axisMapping = 'ZUp';
%     
%     
%     % Load the SDK
%     fprintf( 'Loading SDK...' ); 
%     addpath C:\Users\HuMoTech\Desktop\Inseung\VICON_Stream
%     Client.LoadViconDataStreamSDK();
%     fprintf( 'done\n' );
%     
%     % Program options (VICON desk's IP address)
%     % HostName = '169.254.27.74';
%     HostName = '192.168.10.3';
%     % Make a new client
%     MyClient = Client();
%     
%     % Connect to a server
%     fprintf( 'Connecting to %s ...', HostName );
%     remote = tcpip('localhost', 4000);
%     fopen(remote);
%     
%     while ~MyClient.IsConnected().Connected
%         % Direct connection
%         MyClient.Connect( HostName );
% 
%         % Multicast connection
%         % MyClient.ConnectToMulticast( HostName, '224.0.0.0' );
%       
%         fprintf( '.' );
%     end
%     fprintf( '\n' );
%     
%     % Enable some different data types
%     MyClient.EnableSegmentData();
%     MyClient.EnableMarkerData();
%     MyClient.EnableUnlabeledMarkerData();
%     MyClient.EnableDeviceData();
%     
%     fprintf( 'Segment Data Enabled: %s\n',          AdaptBool( MyClient.IsSegmentDataEnabled().Enabled ) );
%     fprintf( 'Marker Data Enabled: %s\n',           AdaptBool( MyClient.IsMarkerDataEnabled().Enabled ) );
%     fprintf( 'Unlabeled Marker Data Enabled: %s\n', AdaptBool( MyClient.IsUnlabeledMarkerDataEnabled().Enabled ) );
%     fprintf( 'Device Data Enabled: %s\n',           AdaptBool( MyClient.IsDeviceDataEnabled().Enabled ) );
%     
%     % Set the streaming mode
%     MyClient.SetStreamMode( StreamMode.ClientPull );
%     % MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
%     % MyClient.SetStreamMode( StreamMode.ServerPush );
%     
%     % Set the global up axis
%     if axisMapping == 'XUp'
%         MyClient.SetAxisMapping( Direction.Up, ...
%                               Direction.Forward,      ...
%                               Direction.Left ); % X-up
%     elseif axisMapping == 'YUp'
%         MyClient.SetAxisMapping( Direction.Forward, ...
%                              Direction.Up,    ...
%                              Direction.Right );    % Y-up
%     else
%         MyClient.SetAxisMapping( Direction.Forward, ...
%                              Direction.Left,    ...
%                              Direction.Up );    % Z-up
%     end
%     
%     Output_GetAxisMapping = MyClient.GetAxisMapping();
%     fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
%                                                Output_GetAxisMapping.YAxis.ToString(), ...
%                                                Output_GetAxisMapping.ZAxis.ToString() );
%     
%     % Loop until the message box is dismissed

    global avgSpeed;
    global downBound;
    TreadmillCmd = 0;
    upBound = 1.4;
    downBound = 0.6;
    counter = 0;
    buffer = zeros(25,1);

    var1 = optimizableVariable('Left_ExtPeakTiming',[0.35 0.6]);
    var2 = optimizableVariable('Left_FlexPeakTiming',[0.75 1.15]);
    var3 = optimizableVariable('Right_ExtPeakTiming',[0.35 0.6]);
    var4 = optimizableVariable('Right_FlexPeakTiming',[0.75 1.15]);
    
    LeftExtMag = 6;
    LeftFlexMag = -6;
    RightExtMag = 6;
    RightFlexMag = -6;

    % Create figure for keyboard interrupts
    fig = figure('KeyPressFcn', @key_ISR, 'Position', [10 500 400 100]);
    text(0.04, 0.8, 'Keyboard Interrupt GUI', 'FontSize', 20, 'Fontweight', 'bold')
    text(0.04, 0.4, '[Space]: Stop', 'FontSize', 12, 'Color', 'b')
    text(0.04, 0.15, '[Enter]: Update Optimizer', 'FontSize', 12, 'Color', 'b')
    set(gca, 'Visible', 'off')
    set(fig, 'CloseRequestFcn', []);

    % Keyboard interrupt flag variables
    global break_flag;
    global bad_param_flag;
    break_flag = false;
    bad_param_flag = false;

    % Establish loop execution frequency
    freq = 5;
    rate = rateControl(freq);
    reset(rate);

    while true
        clc;
        buffer = [buffer(2:25,1); TreadmillCmd];
        avgSpeed = mean(buffer);
        counter = counter + 1;
        fprintf('Elapsed Time: %.3f\n', rate.TotalElapsedTime);
        fprintf('Counter: %d\n', counter);
    
%         while MyClient.GetFrame().Result.Value ~= Result.Success
%         end % while
%       
%         MarkerName='LPSI';
%         SubjectName='pawe';
%       
%         % Output_GetMarkerGlobalTranslation = MyClient.GetMarkerGlobalTranslation( SubjectName, MarkerName );
%         Output_GetMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation(1);
%         MarkerY=Output_GetMarkerGlobalTranslation.Translation( 2 );
     
        if TreadmillCmd > upBound
            TreadmillCmd = upBound;
        elseif TreadmillCmd < downBound
            TreadmillCmd = downBound;
        end
        
%         tm_set(remote, TreadmillCmd, 0.1);
%         if MarkerY > 1000
%             TreadmillCmd = TreadmillCmd + 0.01;
%     
%         elseif MarkerY < 900
%             TreadmillCmd = TreadmillCmd - 0.01;
%         end
    
        if int8(mod(counter, 50)) == 0 || (bad_param_flag && counter > 50)
            if counter == 50
                fprintf('[Bayes Opt Init]');
                BayesObject = bayesopt(@testFcn,[var1 var2 var3 var4],...
                'AcquisitionFunction','expected-improvement-per-second-plus',...
                'IsObjectiveDeterministic', 0,...
                'OutputFcn',@assignInBase,...
                'MaxObjectiveEvaluations',1,...
                'PlotFcn',[],...
                'verbose',0,...
                'InitialX', table(1, 2, 3, 4));
            else
                fprintf('[Bayes Opt Update]');
                BayesObject = resume(BayesObject,...
                'MaxObjectiveEvaluations',1,...
                'IsObjectiveDeterministic', 0,...
                'OutputFcn',@assignInBase,...
                'PlotFcn',[],...
                'verbose',0);
            end
            
            if bad_param_flag
                counter = counter - mod(counter, 50);
            end
            bad_param_flag = false;
            pause(1)
        end
     
%         currentParam = BayesObject.XTrace(end,:);
%         paramSet = strcat('v',...
%                           num2str(LeftExtMag),',',...
%                           num2str(LeftFlexMag),',',...
%                           num2str(0.3),',',...
%                           num2str(currentParam.Left_ExtPeakTiming),',',...
%                           num2str(0.65),',',...
%                           num2str(0.7),',',...
%                           num2str(currentParam.Left_FlexPeakTiming),',',...
%                           num2str(1.2),',',...
%                           num2str(RightExtMag),',',...
%                           num2str(RightFlexMag),',',...       
%                           num2str(0.3),',',...
%                           num2str(currentParam.Right_ExtPeakTiming),',',...
%                           num2str(0.65),',',...
%                           num2str(0.7),',',...                     
%                           num2str(currentParam.Right_FlexPeakTiming),',',...
%                           num2str(1.2),'!');
%          fprintf('Current IterNum: ')             
%          fprintf("%d",BayesObject.NumObjectiveEvaluations)
%          fprintf(', Speed: ')             
%          fprintf("%f",speed)
%          fprintf( '\n' );                  
%          fprintf("%s",paramSet)
%          fprintf( '\n' );
%          fprintf( '\n' );
% 
%          fprintf("Speed: ");
%          fprintf("%.2f",TreadmillCmd);
%          fprintf(" MarkerPos: ");
%          fprintf("%.2f",double(MarkerY));
%          fprintf(" ElapsedTime: ");
%          fprintf("%.1f",counter/5);
%          fprintf(" ");
%          fprintf("%.2f",avgSpeed);
%          fprintf( '\n' );

        % Break while loop if break button is pressed
        if break_flag
            break;
        end

        % Pause program to meet desired rate
        waitfor(rate);
    end% while true 

    % Close keyboard interrupt GUI
    close all force;
    clc;
    fprintf('Program Interrupted\n');

%     tm_set(remote, 0, 1);
%     fclose(remote);
%     
%     % Disconnect and dispose
%     MyClient.Disconnect();
%     
%     % Unload the SDK
%     fprintf( 'Unloading SDK...' );
%     Client.UnloadViconDataStreamSDK();
%     fprintf( 'done\n' );
end

function objFcn = testFcn(x)
    global avgSpeed;
    global downBound;
    global bad_param_flag;

    if bad_param_flag
        objFcn = -downBound;
    else
        objFcn = -avgSpeed;
    end
end

function key_ISR(~, event)
    global break_flag;
    global bad_param_flag;
    
    key = event.Key;
    if strcmp(key, 'space')
        break_flag = true;
    elseif strcmp(key, 'return')
        bad_param_flag = true;
    end
end

