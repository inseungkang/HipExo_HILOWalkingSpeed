%% Questions
% 1. Is midTiming the midpoint for midDuration?
% 2. Starting hip timer at 84% of gc w.r.t. HS is not guaranteed to be
% zero. Do you just hardcode extra zero nodes to enforce this?
% 3. Based on the grf data, it seems like neither the ankle or hip timers
% start right at heel strike?

%% Set up gait phase variables
% Reported values are in terms of hip timing which is delayed 84% from start of ankle timer (~ heel strike). 
hipTimingOffset = 0.84; % Hip params offset w.r.t. Stanford 0% from pdf & data
toeOffTiming = 0.637; % TO w.r.t. Stanford 0% from pdf & data
heelStrikeTiming = 0.9585; % HS w.r.t. Stanford 0% from pdf & data
hipTime = 0:0.01:1;
gaitPhase = 0:0.1:1;

%% Set up control parameters
hipExtRiseDuration = 0.1723;
hipExtPeakTime = 0.2643;
% hipExtPeakTorque = 0.1967;
hipExtPeakTorque = 10;
hipMidTime = 0.4867;
hipMidDuration = 0.014;
hipFlexPeakTime = 0.8009;
% hipFlexPeakTorque = -0.1967;
hipFlexPeakTorque = -10;
hipFlexFallDuration = 0.2039;

% hipExtRiseDuration = 0.25;
% hipExtPeakTime = 0.225;
% hipExtPeakTorque = 0.1967;
% hipMidTime = 0.4867;
% hipMidDuration = 0;
% hipFlexPeakTime = 0.85;
% hipFlexPeakTorque = -0.1967;
% hipFlexFallDuration = 0.3;
% 
% hipExtRiseDuration = 0.19; % Adjusted Max
% hipExtPeakTime = 0.245; % Adjusted Min
% % hipExtPeakTorque = 0.1967;
% hipExtPeakTorque = 6;
% hipMidTime = 0.4867;
% hipMidDuration = 0.01; % Adjusted Min
% hipFlexPeakTime = 0.83; % Adjusted Max
% % hipFlexPeakTorque = -0.1967;
% hipFlexPeakTorque = -6;
% hipFlexFallDuration = 0.22; % Adjusted Max

fprintf("u%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f!\n", hipExtRiseDuration, ...
    hipExtPeakTime, hipExtPeakTorque, hipMidTime, hipMidDuration, hipFlexPeakTime, ...
    hipFlexPeakTorque, hipFlexFallDuration);

%% Compute pchip nodes & magnitudes from control parameters
hipExtStartNodeX = hipExtPeakTime - hipExtRiseDuration;
hipExtPeakNodeX = hipExtPeakTime;
hipExtEndNodeX = hipMidTime - (hipMidDuration/2);
hipFlexStartNodeX = hipMidTime + (hipMidDuration/2);
hipFlexPeakNodeX = hipFlexPeakTime;
hipFlexEndNodeX = hipFlexPeakTime + hipFlexFallDuration;

hipExtStartNodeY = 0;
hipExtPeakNodeY = hipExtPeakTorque;
hipExtEndNodeY = 0;
hipFlexStartNodeY = 0;
hipFlexPeakNodeY = hipFlexPeakTorque;
hipFlexEndNodeY = 0;

if hipExtEndNodeX~=hipFlexStartNodeX
    hipNodesX = [hipExtStartNodeX, hipExtPeakNodeX, hipExtEndNodeX, ...
        hipFlexStartNodeX, hipFlexPeakNodeX, hipFlexEndNodeX];
    hipNodesY = [hipExtStartNodeY, hipExtPeakNodeY, hipExtEndNodeY, ...
        hipFlexStartNodeY, hipFlexPeakNodeY, hipFlexEndNodeY];
else
    hipNodesX = [hipExtStartNodeX, hipExtPeakNodeX, hipExtEndNodeX, ...
        hipFlexPeakNodeX, hipFlexEndNodeX];
    hipNodesY = [hipExtStartNodeY, hipExtPeakNodeY, hipExtEndNodeY, ...
        hipFlexPeakNodeY, hipFlexEndNodeY];

end
    
% hipNodesX = [hipNodesX(1:end-1)-1.0 hipNodesX hipNodesX(2:end)+1.0];
% hipNodesY = [hipNodesY(1:end-1) hipNodesY hipNodesY(2:end)];
hipNodesX = [hipNodesX-1.0 hipNodesX hipNodesX+1.0];
hipNodesY = [hipNodesY hipNodesY hipNodesY];
% hipNodesX = [hipNodesX(end)-1.0 hipNodesX hipNodesX(1)+1.0];
% hipNodesY = [hipNodesY(end) hipNodesY hipNodesY(1)];

hipTimePlot = -1:0.01:2;

%% Plot hip torque profile w.r.t. hip timing
x = hipTimePlot;
xHeelStrike = ones(1,2)*(heelStrikeTiming-hipTimingOffset);
xToeOff = ones(1,2)*(toeOffTiming-hipTimingOffset);

y = pchip(hipNodesX, hipNodesY, hipTimePlot);
yHeelStrike = [hipExtPeakTorque, hipFlexPeakTorque];
yToeOff = [hipExtPeakTorque, hipFlexPeakTorque];

figure
hold on
plot(x, y)
plot(xHeelStrike-1, yHeelStrike, '-r')
plot(xHeelStrike, yHeelStrike, '-r')
plot(xHeelStrike+1, yHeelStrike, '-r')
plot(xToeOff-1, yToeOff, '-b')
plot(xToeOff, yToeOff, '-b')
plot(xToeOff+1, yToeOff, '-b')
plot(hipNodesX, hipNodesY, 'o')

title('Hips')
ylabel('Torque (Nm/kg)')
xlabel('Gait Phase w.r.t. Hip Timing')
xlim([0 1])
xticks(0:0.1:1)

%% Plot hip torque profile w.r.t. Stanford 0% from pdf & data
% aka hip timing+84% (which is approximately heel strike but actually aligns w/ start of ankle timer)

x = hipTimePlot+hipTimingOffset;
xHeelStrike = ones(1,2)*heelStrikeTiming;
xToeOff = ones(1,2)*toeOffTiming;

y = pchip(hipNodesX, hipNodesY, hipTimePlot);
yHeelStrike = [hipExtPeakTorque, hipFlexPeakTorque];
yToeOff = [hipExtPeakTorque, hipFlexPeakTorque];

figure
hold on
plot(x, y)
plot(xHeelStrike-1, yHeelStrike, '-r')
plot(xHeelStrike, yHeelStrike, '-r')
plot(xHeelStrike+1, yHeelStrike, '-r')
plot(xToeOff-1, yToeOff, '-b')
plot(xToeOff, yToeOff, '-b')
plot(xToeOff+1, yToeOff, '-b')
plot(hipNodesX+hipTimingOffset, hipNodesY, 'o')

title('Hips')
ylabel('Torque (Nm/kg)')
xlabel('Gait Phase w.r.t. Hip Timing+84% (aka Ankle Timing)')
xlim([0 1])
xticks(0:0.1:1)

%% Plot hip torque profile w.r.t. heel-strike
x = hipTimePlot+hipTimingOffset-heelStrikeTiming;
xHeelStrike = zeros(1,2);
xToeOff = ones(1,2)*(toeOffTiming-heelStrikeTiming);

y = pchip(hipNodesX, hipNodesY, hipTimePlot)*-1;
yHeelStrike = [hipExtPeakTorque, hipFlexPeakTorque]*-1;
yToeOff = [hipExtPeakTorque, hipFlexPeakTorque]*-1;

figure
hold on
plot(x, y)
plot(xHeelStrike-1, yHeelStrike, '-r')
plot(xHeelStrike, yHeelStrike, '-r')
plot(xHeelStrike+1, yHeelStrike, '-r')
plot(xToeOff-1, yToeOff, '-b')
plot(xToeOff, yToeOff, '-b')
plot(xToeOff+1, yToeOff, '-b')
plot(hipNodesX+hipTimingOffset-heelStrikeTiming, hipNodesY*-1, 'o')

title('Hips')
ylabel('Torque (Nm/kg)')
xlabel('Gait Phase w.r.t. Heel-Strike')
xlim([0 1])
xticks(0:0.1:1)

%% Plot hip torque profile w.r.t. toe-off
x = hipTimePlot+hipTimingOffset-toeOffTiming;
xHeelStrike = ones(1,2)*(heelStrikeTiming-toeOffTiming);
xToeOff = zeros(1,2);

y = pchip(hipNodesX, hipNodesY, hipTimePlot)*-1;
yHeelStrike = [hipExtPeakTorque, hipFlexPeakTorque]*-1;
yToeOff = [hipExtPeakTorque, hipFlexPeakTorque]*-1;

figure
hold on
plot(x, y)
plot(xHeelStrike-1, yHeelStrike, '-r')
plot(xHeelStrike, yHeelStrike, '-r')
plot(xHeelStrike+1, yHeelStrike, '-r')
plot(xToeOff-1, yToeOff, '-b')
plot(xToeOff, yToeOff, '-b')
plot(xToeOff+1, yToeOff, '-b')
plot(hipNodesX+hipTimingOffset-toeOffTiming, hipNodesY*-1, 'o')

title('Hips')
ylabel('Torque (Nm/kg)')
xlabel('Gait Phase w.r.t. Toe-Off')
xlim([0 1])
xticks(0:0.1:1)

%% Plot w/ biological profile w.r.t. toe-off
% torqueProfiles = load('/home/dean/hipTorqueData/torqueProfiles.mat');
% torque_lg = torqueProfiles.data.walk.all;
torque_lg_normal = [0.3463,0.3447,0.3431,0.3414,0.3398,0.3381,0.3363,0.3344,0.3326,0.3307,0.3288,0.3268,0.3248,0.3228,0.3208,0.3187,0.3166,0.3144,0.3123,0.3101,0.3079,0.3057,0.3035,0.3012,0.2990,0.2967,0.2944,0.2921,0.2897,0.2874,0.2850,0.2826,0.2803,0.2779,0.2755,0.2730,0.2706,0.2682,0.2657,0.2633,0.2608,0.2584,0.2559,0.2534,0.2509,0.2485,0.2460,0.2435,0.2410,0.2385,0.2360,0.2335,0.2310,0.2285,0.2260,0.2236,0.2211,0.2186,0.2161,0.2137,0.2112,0.2088,0.2063,0.2039,0.2015,0.1991,0.1967,0.1943,0.1919,0.1895,0.1872,0.1849,0.1826,0.1803,0.1780,0.1758,0.1735,0.1713,0.1691,0.1670,0.1648,0.1627,0.1606,0.1585,0.1565,0.1545,0.1525,0.1505,0.1486,0.1466,0.1448,0.1429,0.1411,0.1393,0.1375,0.1358,0.1341,0.1324,0.1307,0.1291,0.1275,0.1260,0.1245,0.1230,0.1215,0.1201,0.1187,0.1173,0.1160,0.1147,0.1135,0.1122,0.1110,0.1098,0.1087,0.1076,0.1065,0.1054,0.1044,0.1034,0.1025,0.1015,0.1006,0.0998,0.0989,0.0981,0.0973,0.0965,0.0958,0.0951,0.0944,0.0938,0.0932,0.0926,0.0920,0.0914,0.0909,0.0904,0.0900,0.0895,0.0891,0.0887,0.0883,0.0879,0.0876,0.0873,0.0870,0.0867,0.0865,0.0862,0.0860,0.0858,0.0856,0.0855,0.0853,0.0852,0.0850,0.0849,0.0848,0.0847,0.0846,0.0845,0.0844,0.0843,0.0843,0.0842,0.0841,0.0841,0.0840,0.0839,0.0838,0.0837,0.0837,0.0836,0.0834,0.0833,0.0832,0.0830,0.0829,0.0827,0.0825,0.0823,0.0820,0.0817,0.0814,0.0811,0.0807,0.0803,0.0799,0.0795,0.0790,0.0784,0.0778,0.0772,0.0765,0.0758,0.0750,0.0742,0.0734,0.0724,0.0714,0.0704,0.0693,0.0681,0.0669,0.0655,0.0642,0.0627,0.0612,0.0596,0.0579,0.0562,0.0543,0.0524,0.0504,0.0484,0.0462,0.0440,0.0416,0.0392,0.0367,0.0341,0.0314,0.0286,0.0258,0.0228,0.0198,0.0166,0.0134,0.0101,0.0067,0.0032,-0.0004,-0.0041,-0.0079,-0.0117,-0.0157,-0.0197,-0.0238,-0.0280,-0.0323,-0.0366,-0.0411,-0.0456,-0.0502,-0.0548,-0.0596,-0.0643,-0.0692,-0.0741,-0.0791,-0.0841,-0.0892,-0.0943,-0.0995,-0.1047,-0.1100,-0.1153,-0.1206,-0.1259,-0.1313,-0.1367,-0.1421,-0.1476,-0.1530,-0.1585,-0.1639,-0.1694,-0.1748,-0.1802,-0.1857,-0.1911,-0.1964,-0.2018,-0.2071,-0.2124,-0.2176,-0.2228,-0.2280,-0.2331,-0.2382,-0.2432,-0.2481,-0.2530,-0.2577,-0.2625,-0.2671,-0.2717,-0.2761,-0.2805,-0.2848,-0.2890,-0.2931,-0.2971,-0.3010,-0.3048,-0.3084,-0.3119,-0.3154,-0.3187,-0.3219,-0.3249,-0.3278,-0.3306,-0.3329,-0.3351,-0.3377,-0.3404,-0.3418,-0.3429,-0.3440,-0.3441,-0.3457,-0.3476,-0.3485,-0.3488,-0.3485,-0.3464,-0.3470,-0.3474,-0.3476,-0.3478,-0.3469,-0.3450,-0.3443,-0.3434,-0.3422,-0.3414,-0.3394,-0.3378,-0.3360,-0.3347,-0.3326,-0.3305,-0.3277,-0.3249,-0.3216,-0.3187,-0.3171,-0.3186,-0.3143,-0.3109,-0.3076,-0.3052,-0.3044,-0.3019,-0.3001,-0.2982,-0.2981,-0.2973,-0.2970,-0.2955,-0.2955,-0.2962,-0.2961,-0.2953,-0.2958,-0.2962,-0.2965,-0.2973,-0.2978,-0.2991,-0.3005,-0.3022,-0.3039,-0.3048,-0.3058,-0.3072,-0.3089,-0.3127,-0.3160,-0.3182,-0.3200,-0.3222,-0.3248,-0.3279,-0.3311,-0.3343,-0.3376,-0.3409,-0.3443,-0.3479,-0.3515,-0.3554,-0.3596,-0.3639,-0.3682,-0.3725,-0.3759,-0.3805,-0.3845,-0.3875,-0.3913,-0.3951,-0.3989,-0.4020,-0.4050,-0.4078,-0.4106,-0.4135,-0.4162,-0.4188,-0.4213,-0.4234,-0.4252,-0.4269,-0.4283,-0.4296,-0.4308,-0.4318,-0.4326,-0.4331,-0.4336,-0.4338,-0.4340,-0.4338,-0.4333,-0.4328,-0.4322,-0.4313,-0.4303,-0.4291,-0.4279,-0.4265,-0.4252,-0.4238,-0.4223,-0.4207,-0.4190,-0.4172,-0.4155,-0.4137,-0.4118,-0.4104,-0.4092,-0.4079,-0.4044,-0.4028,-0.4016,-0.4004,-0.3990,-0.3971,-0.3953,-0.3934,-0.3916,-0.3898,-0.3880,-0.3863,-0.3846,-0.3830,-0.3814,-0.3799,-0.3784,-0.3770,-0.3757,-0.3744,-0.3732,-0.3721,-0.3710,-0.3700,-0.3691,-0.3682,-0.3674,-0.3667,-0.3661,-0.3655,-0.3650,-0.3645,-0.3642,-0.3639,-0.3636,-0.3634,-0.3633,-0.3632,-0.3632,-0.3632,-0.3632,-0.3633,-0.3634,-0.3636,-0.3638,-0.3640,-0.3642,-0.3644,-0.3646,-0.3649,-0.3651,-0.3653,-0.3656,-0.3658,-0.3660,-0.3661,-0.3663,-0.3664,-0.3665,-0.3665,-0.3665,-0.3665,-0.3665,-0.3664,-0.3662,-0.3659,-0.3656,-0.3652,-0.3648,-0.3643,-0.3637,-0.3631,-0.3624,-0.3617,-0.3608,-0.3600,-0.3590,-0.3580,-0.3569,-0.3557,-0.3545,-0.3532,-0.3519,-0.3504,-0.3489,-0.3474,-0.3458,-0.3441,-0.3424,-0.3406,-0.3387,-0.3368,-0.3348,-0.3328,-0.3307,-0.3286,-0.3264,-0.3242,-0.3219,-0.3196,-0.3172,-0.3148,-0.3124,-0.3099,-0.3074,-0.3048,-0.3022,-0.2996,-0.2969,-0.2942,-0.2915,-0.2887,-0.2860,-0.2832,-0.2803,-0.2775,-0.2746,-0.2717,-0.2688,-0.2659,-0.2630,-0.2600,-0.2570,-0.2541,-0.2511,-0.2481,-0.2451,-0.2421,-0.2391,-0.2361,-0.2330,-0.2300,-0.2270,-0.2240,-0.2210,-0.2180,-0.2150,-0.2120,-0.2090,-0.2061,-0.2031,-0.2001,-0.1972,-0.1943,-0.1913,-0.1884,-0.1855,-0.1827,-0.1798,-0.1770,-0.1741,-0.1713,-0.1685,-0.1657,-0.1630,-0.1602,-0.1575,-0.1548,-0.1521,-0.1495,-0.1468,-0.1442,-0.1416,-0.1390,-0.1365,-0.1339,-0.1314,-0.1289,-0.1265,-0.1240,-0.1216,-0.1192,-0.1168,-0.1145,-0.1121,-0.1098,-0.1075,-0.1053,-0.1031,-0.1008,-0.0987,-0.0965,-0.0943,-0.0922,-0.0901,-0.0881,-0.0860,-0.0840,-0.0820,-0.0800,-0.0781,-0.0761,-0.0742,-0.0723,-0.0705,-0.0686,-0.0668,-0.0650,-0.0632,-0.0615,-0.0597,-0.0580,-0.0563,-0.0546,-0.0529,-0.0513,-0.0497,-0.0481,-0.0465,-0.0449,-0.0434,-0.0418,-0.0403,-0.0388,-0.0373,-0.0358,-0.0343,-0.0329,-0.0314,-0.0300,-0.0286,-0.0271,-0.0257,-0.0243,-0.0230,-0.0216,-0.0202,-0.0188,-0.0175,-0.0161,-0.0148,-0.0135,-0.0121,-0.0108,-0.0095,-0.0082,-0.0068,-0.0055,-0.0042,-0.0029,-0.0016,-0.0003,0.0010,0.0023,0.0036,0.0050,0.0063,0.0076,0.0089,0.0102,0.0116,0.0129,0.0142,0.0156,0.0169,0.0183,0.0197,0.0210,0.0224,0.0238,0.0252,0.0266,0.0280,0.0294,0.0309,0.0323,0.0338,0.0353,0.0368,0.0383,0.0398,0.0414,0.0429,0.0445,0.0461,0.0477,0.0493,0.0510,0.0526,0.0543,0.0560,0.0578,0.0595,0.0613,0.0631,0.0649,0.0667,0.0686,0.0705,0.0724,0.0743,0.0763,0.0783,0.0803,0.0823,0.0844,0.0864,0.0885,0.0907,0.0928,0.0950,0.0972,0.0994,0.1017,0.1039,0.1062,0.1085,0.1109,0.1132,0.1156,0.1180,0.1205,0.1229,0.1254,0.1279,0.1305,0.1330,0.1356,0.1382,0.1408,0.1435,0.1461,0.1488,0.1516,0.1543,0.1571,0.1599,0.1628,0.1656,0.1685,0.1714,0.1743,0.1773,0.1803,0.1833,0.1864,0.1894,0.1925,0.1957,0.1988,0.2020,0.2052,0.2085,0.2117,0.2150,0.2183,0.2217,0.2251,0.2285,0.2319,0.2354,0.2389,0.2424,0.2460,0.2495,0.2531,0.2568,0.2605,0.2641,0.2679,0.2716,0.2754,0.2792,0.2830,0.2869,0.2908,0.2947,0.2986,0.3026,0.3066,0.3106,0.3146,0.3187,0.3227,0.3268,0.3310,0.3351,0.3393,0.3434,0.3476,0.3518,0.3561,0.3603,0.3646,0.3688,0.3731,0.3774,0.3817,0.3860,0.3903,0.3947,0.3990,0.4033,0.4077,0.4120,0.4163,0.4207,0.4250,0.4294,0.4337,0.4380,0.4423,0.4466,0.4509,0.4552,0.4594,0.4637,0.4679,0.4721,0.4763,0.4804,0.4846,0.4887,0.4927,0.4967,0.5007,0.5046,0.5085,0.5124,0.5162,0.5199,0.5236,0.5272,0.5308,0.5343,0.5377,0.5411,0.5444,0.5476,0.5507,0.5537,0.5567,0.5596,0.5624,0.5650,0.5676,0.5701,0.5725,0.5747,0.5769,0.5789,0.5809,0.5827,0.5843,0.5859,0.5873,0.5887,0.5898,0.5908,0.5917,0.5925,0.5931,0.5936,0.5939,0.5941,0.5941,0.5940,0.5937,0.5933,0.5927,0.5920,0.5911,0.5900,0.5888,0.5875,0.5860,0.5843,0.5825,0.5806,0.5785,0.5762,0.5738,0.5713,0.5686,0.5658,0.5629,0.5598,0.5566,0.5532,0.5498,0.5462,0.5425,0.5387,0.5349,0.5309,0.5269,0.5227,0.5185,0.5142,0.5099,0.5055,0.5011,0.4966,0.4922,0.4877,0.4832,0.4786,0.4741,0.4697,0.4652,0.4608,0.4564,0.4520,0.4478,0.4435,0.4394,0.4353,0.4314,0.4275,0.4237,0.4200,0.4165,0.4130,0.4097,0.4066,0.4035,0.4005,0.3978,0.3951,0.3926,0.3902,0.3880,0.3859,0.3839,0.3821,0.3804,0.3788,0.3774,0.3761,0.3749,0.3738,0.3728,0.3719,0.3711,0.3704,0.3697,0.3692,0.3686,0.3682,0.3678,0.3674,0.3670,0.3667,0.3663,0.3660,0.3657,0.3653,0.3649,0.3645,0.3641,0.3636,0.3631,0.3626,0.3620,0.3613,0.3606,0.3598,0.3590,0.3582,0.3572,0.3561,0.3550,0.3539,0.3528];
torque_lg_normal_hs = 0.377;

scale = max(abs(torque_lg_normal))/max(abs(hipNodesY*-1));

figure
hold on
plot(linspace(0,1,length(torque_lg_normal)), torque_lg_normal, 'b');
plot(x, y*scale, 'r')
plot([torque_lg_normal_hs, torque_lg_normal_hs], yHeelStrike*scale, '--b')
plot(xHeelStrike-1, yHeelStrike*scale, '--r')
plot(xHeelStrike, yHeelStrike*scale, '--r')
plot(xHeelStrike+1, yHeelStrike*scale, '--r')
% plot(xToeOff-1, yToeOff*scale, '-b')
% plot(xToeOff, yToeOff*scale, '-b')
% plot(xToeOff+1, yToeOff*scale, '-b')
plot(hipNodesX+hipTimingOffset-toeOffTiming, hipNodesY*-1*scale, 'ok')

% title('Hips')
ylabel('Torque (Nm/kg)')
xlabel('Gait Phase w.r.t. Toe-Off (%)')
xlim([0 1])
xticks(0:0.1:1)

legend('Bio', 'HiLO', 'Bio\_HS', 'HiLO\_HS')
xticks(0:0.1:1)
xticklabels(0:10:100)