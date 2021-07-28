% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (C) OMG Plc 2009.
% All rights reserved.  This software is protected by copyright
% law and international treaties.  No part of this software / document
% may be reproduced or distributed in any form or by any means,
% whether transiently or incidentally to some other use of this software,
% without the written permission of the copyright owner.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part of the Vicon DataStream SDK for MATLAB.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MarkerY=PRG_SelfPace
% Program options
TransmitMulticast = false;
EnableHapticFeedbackTest = false;
HapticOnList = {'ViconAP_001';'ViconAP_002'};
bReadCentroids = false;
bReadRays = false;
axisMapping = 'ZUp';

% A dialog to stop the loop
% MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK' );

% Load the SDK
fprintf( 'Loading SDK...' ); 
addpath C:\Users\HuMoTech\Desktop\Inseung\VICON_Stream
Client.LoadViconDataStreamSDK();
fprintf( 'done\n' );

% Program options (VICON desk's IP address)
% HostName = '169.254.27.74';
HostName = '192.168.10.3';
% Make a new client
MyClient = Client();

% Connect to a server
fprintf( 'Connecting to %s ...', HostName );

remote = tcpip('localhost', 4000);
fopen(remote);

while ~MyClient.IsConnected().Connected
  % Direct connection
  MyClient.Connect( HostName );
  
  % Multicast connection
  % MyClient.ConnectToMulticast( HostName, '224.0.0.0' );
  
  fprintf( '.' );
end
fprintf( '\n' );

% Enable some different data types
MyClient.EnableSegmentData();
MyClient.EnableMarkerData();
MyClient.EnableUnlabeledMarkerData();
MyClient.EnableDeviceData();

fprintf( 'Segment Data Enabled: %s\n',          AdaptBool( MyClient.IsSegmentDataEnabled().Enabled ) );
fprintf( 'Marker Data Enabled: %s\n',           AdaptBool( MyClient.IsMarkerDataEnabled().Enabled ) );
fprintf( 'Unlabeled Marker Data Enabled: %s\n', AdaptBool( MyClient.IsUnlabeledMarkerDataEnabled().Enabled ) );
fprintf( 'Device Data Enabled: %s\n',           AdaptBool( MyClient.IsDeviceDataEnabled().Enabled ) );

% Set the streaming mode
MyClient.SetStreamMode( StreamMode.ClientPull );
% MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
% MyClient.SetStreamMode( StreamMode.ServerPush );

% Set the global up axis
if axisMapping == 'XUp'
  MyClient.SetAxisMapping( Direction.Up, ...
                          Direction.Forward,      ...
                          Direction.Left ); % X-up
elseif axisMapping == 'YUp'
  MyClient.SetAxisMapping( Direction.Forward, ...
                         Direction.Up,    ...
                         Direction.Right );    % Y-up
else
  MyClient.SetAxisMapping( Direction.Forward, ...
                         Direction.Left,    ...
                         Direction.Up );    % Z-up
end

Output_GetAxisMapping = MyClient.GetAxisMapping();
fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', Output_GetAxisMapping.XAxis.ToString(), ...
                                           Output_GetAxisMapping.YAxis.ToString(), ...
                                           Output_GetAxisMapping.ZAxis.ToString() );

  

% Loop until the message box is dismissed
TreadmillCmd = 0;
upBound = 1.5;
downBound = 0.5;
counter = 0;
buffer = zeros(25,1);
global avgSpeed
firstOpt = 0;
testvar = optimizableVariable('rightFlex',[60 140]);

while true
  buffer = [buffer(2:25,1); TreadmillCmd];
  avgSpeed = mean(buffer);
  counter = counter + 1;
  pause(0.01);

  while MyClient.GetFrame().Result.Value ~= Result.Success
  end% while
  
  MarkerName='LPSI';
  SubjectName='pawe';
  
% Output_GetMarkerGlobalTranslation = MyClient.GetMarkerGlobalTranslation( SubjectName, MarkerName );
Output_GetMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation(1);
MarkerY=Output_GetMarkerGlobalTranslation.Translation( 2 );


    if MarkerY == 0
    else 
       TreadmillCmd = ((MarkerY-1000)*0.5/500)+1;
    end
        
%  if int8(mod(counter, 50)) == 0
%      if firstOpt == 0
%          BayesObject = bayesopt(@testFcn,testvar,...
%         'AcquisitionFunction','expected-improvement',...
%         'MaxObjectiveEvaluations',1);
%         firstOpt = 1;
%      elseif firstOpt == 1
%          BayesObject = resume(BayesObject,'IsObjectiveDeterministic',true,...
%              'MaxObjectiveEvaluations',1);
%      end
%      optimizeTime = 1;
% 
%  else
%      optimizeTime = 0;
%  end

 if TreadmillCmd > upBound
    TreadmillCmd = upBound;
 elseif TreadmillCmd < downBound
    TreadmillCmd = downBound;
 end
 
 tm_set(remote, TreadmillCmd, 1);
 
 fprintf("Speed: ");
 fprintf("%.2f",TreadmillCmd);
 fprintf(" MarkerPos: ");
 fprintf("%.2f",double(MarkerY));
 fprintf(" ElapsedTime: ");
 fprintf("%.1f",TreadmillCmd);
 fprintf(" ");
 fprintf("%.2f",avgSpeed);
 fprintf( '\n' );

end% while true 
tm_set(remote, 0, 1);
fclose(remote);

% Disconnect and dispose
MyClient.Disconnect();

% Unload the SDK
fprintf( 'Unloading SDK...' );
Client.UnloadViconDataStreamSDK();
fprintf( 'done\n' );
end

function ObjFcn = testFcn(testvar)
global avgSpeed
ObjFcn = -avgSpeed;
end
