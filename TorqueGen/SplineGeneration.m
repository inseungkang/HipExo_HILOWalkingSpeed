%% Generate profiles
% Please note this is an old script. These are random profiles and not what
% we applied during the experiment

Hip_nodes_time = [0, 0.035,  0.25 , 0.5, 0.55, 0.75 , 0.95, 1]; % Hip timing nodes as a percent of stride
Hip_nodes_torque = [0,   0  , -0.225,  0 ,  0  , 0.125,  0  , 0]; % Hip magnitude nodes normalized by body mass [Nm/kg]

Ankle_nodes_time = [0, 0.2, 0.48, 0.6, 1]; % Ankle timing nodes as a percent of stride
Ankle_nodes_torque = [0,  0 , 0.5 ,  0 , 0]; % Ankle magnitude nodes normalized by body mass [Nm/kg]

% you can visually evaluate profiles like this:
tt = 0:.01:1; %
subplot(2,1,1)
HTT = pchip(Hip_nodes_time,Hip_nodes_torque,tt);
plot(tt,HTT)
title('Hips')
ylabel('Torque (Nm/kg)')
subplot(2,1,2)
ATT = pchip(Ankle_nodes_time,Ankle_nodes_torque,tt);
plot(tt,ATT)
title('Ankles')
ylabel('Torque (Nm/kg)')
xlabel('Time (% stride)')

%% Evaluate profiles in real time controller
% Use the spline fit to generate torque profile
Hiptorqueprofile = pchip(Hip_nodes_time,Hip_nodes_torque);
Ankletorqueprofile = pchip(Ankle_nodes_time, Ankle_nodes_torque);

% Evaluate the profile at current time step (stridetimes(i))
% stridetimes is an input to this block in our controller, so this
% stridetimes is just a dummy for the sample code
stridetimes = ones(6,1); % 
Hip_joint_torque(1)= ppval(Hiptorqueprofile,stridetimes(1)); % Each joint has its own stride time (1=left hip, 2 =right hip)
Hip_joint_torque(2)= ppval(Hiptorqueprofile,stridetimes(2)); % We start the hip timer 84% of stride after the ankles to avoid torque discontinuities at heel strike

Ankle_joint_torque(1)= ppval(Ankletorqueprofile,stridetimes(5)); % 3 and 4 are knee stride times, 5=left ankle, 6=right ankle
Ankle_joint_torque(2)= ppval(Ankletorqueprofile,stridetimes(6));% We start the ankle timer at heel strike