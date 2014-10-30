% initialise predictLabels, accuracies, decValues matrices
 predictLabels = ones(flowerSetNumber, 120);
 accuracies = ones(flowerSetNumber, 3);
 decValues = ones(flowerSetNumber, 120);
 
for i = 1:flowerSetNumber
    % generate label vectors
    labelVector = generateLabelVector(flowerSetNumber, i);
    
    % train + test SVMs  
    addpath libsvm-3.18/matlab
    model = svmtrain(labelVector, trainingInstanceMatrix, '-c 1 -g 1');
    [predict_label, accuracy, dec_values] = svmpredict(labelVector, testInstanceMatrix, model);
    rmpath libsvm-3.18/matlab
    
    % store predict_label, accuracy, dec_values
    predictLabels(i, :) = predict_label';
    accuracies(i, :) = accuracy;
    decValues(i, :) = dec_values'; 
end
