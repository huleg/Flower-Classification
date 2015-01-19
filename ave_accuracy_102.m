% Average Accuracy. This script randomly generates training, validation and
% test sets of photos and finds the mean and standard deviation of the
% accuracies. 

num_tests = 5;
accuracies = zeros(1, num_tests);


use_mirror = 0;
use_jitter = 0;
do_svm = 1;


% initialise variables
flower_set_number = 102;
image_folder = 'oxfordflower102/';

% import vector of flower file names
image_name = importdata(strcat(image_folder,'files.txt'));
image_name = cell2mat(image_name);


% generate vector of image categorisation labels
image_labels = load(strcat(image_folder,'labels.mat'));
image_labels = (cell2mat(struct2cell(image_labels)));

for count = 1 : num_tests
    % generate setid
    setid.trnid = [];
    setid.valid = [];
    setid.tstid = [];
    for i = 1 : flower_set_number
        A = find(image_labels == i);
        setid.trnid = [setid.trnid datasample(A, 10, 'replace', false)];
        A = setdiff(A, setid.trnid);
        setid.valid = [setid.valid datasample(A, 10, 'replace', false)];
        A = setdiff(A, setid.valid);
        setid.tstid = [setid.tstid A];
    end


    [train_instance_matrix, test_instance_matrix, train_label_vector, ...
        test_label_vector] = cnn_gen_test_train_matrix(image_name, ...
        image_folder, image_labels, use_mirror, use_jitter, setid);


    % train models 
    if do_svm
    [weight_matrix, model_labels] = svm_train( ... 
        flower_set_number, train_instance_matrix, train_label_vector);
    end

    % test models
    if do_svm
    decision_values = ...
        svm_test(flower_set_number, test_instance_matrix, weight_matrix);
    end


    confusion_matrix = gen_conf_mat( ... 
        decision_values, test_label_vector);

    confusion_matrix_accuracy = trace(confusion_matrix) / ...
        flower_set_number;
    
    accuracies(count) = confusion_matrix_accuracy;

end

accuracy_mean = mean(accuracies);
accuracy_std = std(accuracies);
 
    
    

