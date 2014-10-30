%JR_CNN_SCRIPT Script generates photo file names and passes them to jr_cnn
%and saves the returned feature vector

% flowerSetNumber allows easy switching of flower sets. 3, 17 or 102
flowerSetNumber = 3;

% import vector of flower file names, change format from cell to matrix
imageName = jr_import_flower_file_names;

% generate vector of image categorisation labels
imageLabels = load('oxfordflower3/labels.mat');
imageLabels = (cell2mat(struct2cell(imageLabels)));

% for simplified 3 flower case only:
if flowerSetNumber == 3
    imageLabels = imageLabels(1:240);
end

% define vectors containing the indeces of training and testing data
% trainingIndexVector = [1:40, 81:120, 161:200];
% testIndexVector = [41:80, 121:160, 201:240];

% generate vectors containing the indeces of training and testing data
trainingIndexVector = [];
testIndexVector = [];
flag = 1;
for i = 1:240 %size(imageLabels, 2)
   
   if flag == 1 
       trainingIndexVector = [trainingIndexVector i];
   end
   
   if flag == -1 
       testIndexVector = [testIndexVector i];
   end
   
   if mod(i, 40) == 0
       flag = flag * -1;
   end
   
end

trainingIndexVector ;
testIndexVector ;


% load / generate trainingInstanceMatrix storing training flower feature data
if exist('trainingInstanceMatrix.mat')
    trainingInstanceMatrix = load('trainingInstanceMatrix.mat');
    trainingInstanceMatrix = (cell2mat(struct2cell(trainingInstanceMatrix)));
else
    trainingInstanceMatrix = ones(size(trainingIndexVector, 2), 1000);
    for i = 1 : size(trainingIndexVector, 2)
        trainingInstanceMatrix(i, :) = jr_cnn(imageName(trainingIndexVector(i), :));
    end
    save('trainingInstanceMatrix.mat', 'trainingInstanceMatrix');
end

% load / generate testInstanceMatrix storing test flower feature data
if  exist('testInstanceMatrix.mat')
    testInstanceMatrix = load('testInstanceMatrix.mat');
    testInstanceMatrix = (cell2mat(struct2cell(testInstanceMatrix)));
else
    testInstanceMatrix = ones(size(trainingIndexVector, 2), 1000);
    for i = 1 : size(trainingIndexVector, 2)
        testInstanceMatrix(i, :) = jr_cnn(imageName(testIndexVector(i), :));
    end
    save('testInstanceMatrix.mat', 'testInstanceMatrix')
end



% train and test models 
[predictLabels, accuracies, decValues] = jr_svm(flowerSetNumber, trainingInstanceMatrix, testInstanceMatrix);



