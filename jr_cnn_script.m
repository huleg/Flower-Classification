%JR_CNN_SCRIPT Script generates photo file names and passes them to jr_cnn
%and saves the returned feature vector

% initialise variables
flowerSetNumber = 102;
flowerSetNumberLable = num2str(flowerSetNumber);
imageFolder = 'oxfordflower102/';
imageTrainFolder = strcat(imageFolder, 'jpgtrain/');
imageTestFolder = strcat(imageFolder, 'jpgtest/');
numTotalImages = size(imageLabels, 2);
numTrainingImages = numTotalImages;
numTestImages = numTotalImages;


% import vector of flower file names
imageName = importdata(strcat(imageFolder,'files.txt'));
imageName = cell2mat(imageName);

% generate vector of image categorisation labels
imageLabels = load(strcat(imageFolder,'labels.mat'));
imageLabels = (cell2mat(struct2cell(imageLabels)));

% for simplified 5 flower case only:
if flowerSetNumber == 5
    imageLabels = imageLabels(1:numTotalImages);
end


% load / generate trainingInstanceMatrix storing training flower feature data
if exist(strcat(imageFolder,'trainingInstanceMatrix', flowerSetNumberLable, '.mat'))
    trainingInstanceMatrix = load(strcat(imageFolder,'trainingInstanceMatrix', flowerSetNumberLable, '.mat'));
    trainingInstanceMatrix = (cell2mat(struct2cell(trainingInstanceMatrix)));
else
    trainingInstanceMatrix = ones(numTrainingImages, 4096);
    for i = 1 : numTrainingImages
        trainingInstanceMatrix(i, :) = jr_cnn(imageName(i , :), imageTrainFolder);
    end
    save(strcat(imageFolder,'trainingInstanceMatrix', flowerSetNumberLable, '.mat'), 'trainingInstanceMatrix');
end


% load / generate testInstanceMatrix storing test flower feature data
if  exist(strcat(imageFolder,'testInstanceMatrix', flowerSetNumberLable, '.mat'))
    testInstanceMatrix = load(strcat(imageFolder,'testInstanceMatrix', flowerSetNumberLable, '.mat'));
    testInstanceMatrix = (cell2mat(struct2cell(testInstanceMatrix)));
else
    testInstanceMatrix = ones(numTestImages, 4096);
    for i = 1 : numTestImages
        testInstanceMatrix(i, :) = jr_cnn(imageName(i, :), imageTestFolder);
    end
    save(strcat(imageFolder,'testInstanceMatrix', flowerSetNumberLable, '.mat'), 'testInstanceMatrix')
end


if 1
% train and test models 
[predictLabels, accuracies, decValues] = jr_svm(flowerSetNumber, numTestImages, trainingInstanceMatrix, testInstanceMatrix, imageLabels);

end

