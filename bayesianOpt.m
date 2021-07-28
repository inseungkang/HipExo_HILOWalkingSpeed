leftExt = optimizableVariable('leftExt',[0 1]);
leftFlex = optimizableVariable('leftFlex',[0 1]);
rightExt = optimizableVariable('rightExt',[0 1]);
rightFlex = optimizableVariable('rightFlex',[0 1]);
testvar = optimizableVariable('rightFlex',[60 140]);

fun = @(testvar)treadmill;

results = bayesopt(fun,testvar,'Verbose',1,'AcquisitionFunctionName','expected-improvement-plus')