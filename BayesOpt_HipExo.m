function MarkerY = PRG_SelfPace

    global avgSpeed;
    global downBound;
    counter = 0; TreadmillCmd = 0;
    upBound = 1.4; downBound = 0.6;
    buffer = zeros(500,1);

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
    freq = 100;
    rate = rateControl(freq);
    reset(rate);

    while true
        clc;
        buffer = [buffer(2:500,1); TreadmillCmd];
        avgSpeed = mean(buffer);
        counter = counter + 1;
        fprintf('Elapsed Time: %.3f\n', rate.TotalElapsedTime);
        fprintf('Counter: %d\n', counter);
        
        if TreadmillCmd > upBound
            TreadmillCmd = upBound;
        elseif TreadmillCmd < downBound
            TreadmillCmd = downBound;
        end
        
        if int8(mod(counter, 600)) == 0 || (bad_param_flag && counter > 600)
            if counter == 600
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
                counter = counter - mod(counter, 600);
            end
            bad_param_flag = false;
            pause(1)
        end

        if break_flag
            BayesObject_1 = BayesoptResults;

            break;
        end
        waitfor(rate);
    end
    % Close keyboard interrupt GUI
    close all force;
    clc;
    fprintf('Program Interrupted\n');

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

