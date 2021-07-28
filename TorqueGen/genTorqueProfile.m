%% Compute pchip nodes & magnitudes from control parameters - EPIC Cont - LG
close all; clc; clear all;
input = 'v6,-6,0.3,0.325,0.65,0.7,1.15,1.2,6,-6,0.3,0.475,0.675,0.7,1,1.2!';
input = extractBetween(input,'v','!');
data = strsplit(input{1}, ',' );

% Left Magnitude
hipExtPeakNodeY_A = -abs(str2num(data{1}));
hipFlexPeakNodeY_A = abs(str2num(data{2}));

hipExtStartNodeX_A = str2num(data{3});
hipExtPeakNodeX_A = str2num(data{4});
hipExtEndNodeX_A = str2num(data{5});
hipFlexStartNodeX_A = str2num(data{6});
hipFlexPeakNodeX_A = str2num(data{7});
hipFlexEndNodeX_A = str2num(data{8});

hipExtPeakNodeY_B = -abs(str2num(data{9}));
hipFlexPeakNodeY_B = abs(str2num(data{10}));


hipExtStartNodeX_B = str2num(data{11});
hipExtPeakNodeX_B = str2num(data{12});
hipExtEndNodeX_B = str2num(data{13});
hipFlexStartNodeX_B = str2num(data{14});
hipFlexPeakNodeX_B = str2num(data{15});
hipFlexEndNodeX_B = str2num(data{16});

hipExtStartNodeY_A = 0;
hipExtEndNodeY_A = 0;
hipFlexStartNodeY_A = 0;
hipFlexEndNodeY_A = 0;
hipFlexStartNodeY_B = 0;
hipFlexEndNodeY_B = 0;
hipExtStartNodeY_B = 0;
hipExtEndNodeY_B = 0;


if hipExtEndNodeX_A~=hipFlexStartNodeX_A
    hipNodesX_A = [hipExtStartNodeX_A, hipExtPeakNodeX_A, hipExtEndNodeX_A, ...
        hipFlexStartNodeX_A, hipFlexPeakNodeX_A, hipFlexEndNodeX_A];
    hipNodesY_A = [hipExtStartNodeY_A, hipExtPeakNodeY_A, hipExtEndNodeY_A, ...
        hipFlexStartNodeY_A, hipFlexPeakNodeY_A, hipFlexEndNodeY_A];
else
    hipNodesX_A = [hipExtStartNodeX_A, hipExtPeakNodeX_A, hipExtEndNodeX_A, ...
        hipFlexPeakNodeX_A, hipFlexEndNodeX_A];
    hipNodesY_A = [hipExtStartNodeY_A, hipExtPeakNodeY_A, hipExtEndNodeY_A, ...
        hipFlexPeakNodeY_A, hipFlexEndNodeY_A];
end

hipNodesX_A = [hipNodesX_A-1.0 hipNodesX_A hipNodesX_A+1.0];
hipNodesY_A = [hipNodesY_A hipNodesY_A hipNodesY_A];
hipTimePlot = -1:0.01:2;
x = hipTimePlot;
y = pchip(hipNodesX_A, hipNodesY_A, hipTimePlot)*-1;

torqueProfiles = load([pwd '/torqueProfiles.mat']);
torque_lg = -torqueProfiles.data.walk.normal;
scale_A = max(abs(torque_lg))/max(abs(hipNodesY_A*-1));
% scale_B = max(abs(torque_lg))/max(abs(hipNodesY_B*-1));

figure
hold on
% plot(linspace(0,1,length(torque_lg)), torque_lg, 'b');
subplot(2,1,1)
plot(x, y, 'r', 'linewidth',3)

title('Left Leg Torque Profile')
ylabel('Joint Torque (Nm)')
xlabel('Gait Phase w.r.t. Toe-Off')
xlim([0 1])
xticks(0:0.1:1)

%%
if hipExtEndNodeX_B~=hipFlexStartNodeX_B
    hipNodesX_B = [hipExtStartNodeX_B, hipExtPeakNodeX_B, hipExtEndNodeX_B, ...
        hipFlexStartNodeX_B, hipFlexPeakNodeX_B, hipFlexEndNodeX_B];
    hipNodesY_B = [hipExtStartNodeY_B, hipExtPeakNodeY_B, hipExtEndNodeY_B, ...
        hipFlexStartNodeY_B, hipFlexPeakNodeY_B, hipFlexEndNodeY_B];
else
    hipNodesX_B = [hipExtStartNodeX_B, hipExtPeakNodeX_B, hipExtEndNodeX_B, ...
        hipFlexPeakNodeX_B, hipFlexEndNodeX_B];
    hipNodesY_B = [hipExtStartNodeY_B, hipExtPeakNodeY_B, hipExtEndNodeY_B, ...
        hipFlexPeakNodeY_B, hipFlexEndNodeY_B];
end

hipNodesX_B = [hipNodesX_B-1.0 hipNodesX_B hipNodesX_B+1.0];
hipNodesY_B = [hipNodesY_B hipNodesY_B hipNodesY_B];
hipTimePlot = -1:0.01:2;
x = hipTimePlot;
y = pchip(hipNodesX_B, hipNodesY_B, hipTimePlot)*-1;

torqueProfiles = load([pwd '/torqueProfiles.mat']);
torque_lg = -torqueProfiles.data.walk.normal;
scale_B = max(abs(torque_lg))/max(abs(hipNodesY_B*-1));

subplot(2,1,2)
plot(x, y, 'r', 'linewidth',3)

title('Right Leg Torque Profile')
ylabel('Joint Torque (Nm)')
xlabel('Gait Phase w.r.t. Toe-Off')
xlim([0 1])
xticks(0:0.1:1)

%%

% if hipFlexPeakNodeX_B < hipFlexStartNodeX_B
%     hipFlexPeakNodeX_B = hipFlexPeakNodeX_B + 1;
% end
% if hipFlexEndNodeX_B < hipFlexPeakNodeX_B
%     hipFlexEndNodeX_B = hipFlexEndNodeX_B + 1;
% end
% 
% % fprintf("v%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f!\n", -hipExtPeakNodeY_A, -hipFlexPeakNodeY_A, ...
% %     hipExtStartNodeX_A, hipExtPeakNodeX_A, hipExtEndNodeX_A, ...
% %     hipFlexStartNodeX_A, hipFlexPeakNodeX_A, hipFlexEndNodeX_A)
% 
% if hipExtEndNodeX_B~=hipFlexStartNodeX_B
%     hipNodesX_B = [hipExtStartNodeX_B, hipExtPeakNodeX_B, hipExtEndNodeX_B, ...
%         hipFlexStartNodeX_B, hipFlexPeakNodeX_B, hipFlexEndNodeX_B];
%     hipNodesY_B = [hipExtStartNodeY_B, hipExtPeakNodeY_B, hipExtEndNodeY_B, ...
%         hipFlexStartNodeY_B, hipFlexPeakNodeY_B, hipFlexEndNodeY_B];
% else
%     hipNodesX_B = [hipExtStartNodeX_B, hipExtPeakNodeX_B, hipExtEndNodeX_B, ...
%         hipFlexPeakNodeX_B, hipFlexEndNodeX_B];
%     hipNodesY_B = [hipExtStartNodeY_B, hipExtPeakNodeY_B, hipExtEndNodeY_B, ...
%         hipFlexPeakNodeY_B, hipFlexEndNodeY_B];
% end
% 
% hipNodesX_B = [hipNodesX_B-1.0 hipNodesX_B hipNodesX_B+1.0];
% hipNodesY_B = [hipNodesY_B hipNodesY_B hipNodesY_B];
% hipTimePlot = -1:0.01:2;
% 
% x = hipTimePlot;
% y = pchip(hipNodesX_B, hipNodesY_B, hipTimePlot)*-1;
% 
% torqueProfiles = load([pwd '/torqueProfiles.mat']);
% torque_lg = -torqueProfiles.data.walk.normal;
% scale_B = max(abs(torque_lg))/max(abs(hipNodesY_B*-1));
% % scale_B = max(abs(torque_lg))/max(abs(hipNodesY_B*-1));
% 
% plot(x, y, 'b', 'linewidth',3)
% legend('Non-paretic', 'Paretic')
