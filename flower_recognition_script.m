%JR_CNN_SCRIPT Script generates photo file names and passes them to jr_cnn
%and saves the returned feature vector

% initialise variables
flower_set_number = 5;
number_of_images_per_flower = 80;
image_folder = 'oxfordflower5/';
num_total_images = flower_set_number * number_of_images_per_flower;
num_training_images = num_total_images/2;
num_test_images = num_total_images/2;


% import vector of flower file names
image_name = importdata(strcat(image_folder,'files.txt'));
image_name = cell2mat(image_name);

% generate vector of image categorisation labels
image_labels = load(strcat(image_folder,'labels.mat'));
image_labels = (cell2mat(struct2cell(image_labels)));

% for simplified 5 flower case only:
if flower_set_number == 5
    image_labels = image_labels(1:num_total_images);
end


% the photos come in sets of 80 photos per flower. To split these sets in
% half to generate training and testing data, a training_index_vector of
% [1, 2, ... , 39, 40, 81, 82 ... etc] and a test_index_vector of [41, 42,
% ... , 79, 80 ... etc] are used to address the photos used by each set. 
training_index_vector = ones(1, num_training_images);
test_index_vector = ones(1, num_test_images);
training_count = 0;
test_count = 0;
flag = 1;
for i = 1:num_total_images %size(imageLabels, 2)
   
   if flag == 1 
       training_count = training_count + 1;
       training_index_vector(training_count) = i;
   end
   
   if flag == -1 
       test_count = test_count + 1;
       test_index_vector(test_count) = i;
   end
   
   if mod(i, 40) == 0
       flag = flag * -1;
   end
   
end



% load / generate training_instance_matrix storing training flower feature
% data
if exist(strcat(image_folder,'training_instance_matrix.mat'))
    training_instance_matrix = ...
        load(strcat(image_folder,'training_instance_matrix.mat'));
    training_instance_matrix = ...
        (cell2mat(struct2cell(training_instance_matrix)));
else
    
    training_instance_matrix = ...
        ones( size(training_index_vector, 2) , 4096 );
    training_image_folder = strcat(image_folder, 'jpg/');
    
    for i = 1 : size(training_index_vector, 2)
        training_instance_matrix(i, :) = ...
            cnn_feature_extractor(image_name( ...
                training_index_vector(i), :), training_image_folder);

    end
    
    % code generates a training matrix using mirrors of the training images
    %{
    training_instance_matrix = ...
        ones( (size(training_index_vector, 2) * 2) , 4096 );
    training_image_folder = strcat(image_folder, 'jpg/');
    mirror_image_folder = strcat(image_folder, 'jpgmirror/');
    for i = 1 : size(training_index_vector, 2)
        training_instance_matrix((2*i - 1), :) = ...
            cnn_feature_extractor(image_name( ...
                training_index_vector(i), :), training_image_folder);
        training_instance_matrix(2*i, :) = ...
            cnn_feature_extractor(image_name( ...
                training_index_vector(i), :), mirror_image_folder);
    end
    %}
    save(strcat(image_folder,'training_instance_matrix.mat'), ...
        'training_instance_matrix');
end

% load / generate test_instance_matrix storing test flower feature data
if  exist(strcat(image_folder,'test_instance_matrix.mat'))
    test_instance_matrix = load( ...
        strcat(image_folder,'test_instance_matrix.mat'));
    test_instance_matrix = (cell2mat(struct2cell(test_instance_matrix)));
else
    test_instance_matrix = ones(size(training_index_vector, 2), 4096);
    test_image_folder = strcat(image_folder, 'jpg/');
    for i = 1 : size(training_index_vector, 2)
        test_instance_matrix(i, :) = cnn_feature_extractor(image_name( ...
            test_index_vector(i), :), test_image_folder);
    end
    save(strcat(image_folder,'test_instance_matrix.mat'), ...
        'test_instance_matrix')
end



% train and test models 
if 1
    [prediction_labels, accuracies, decision_values, weight_matrix] = ...
        svm_train_and_test(flower_set_number, num_test_images, ...
            training_instance_matrix, test_instance_matrix);
end

% measure quality of results (confusion matrix, contingency table, ROC)
confusion_matrix = generate_confusion_matrix(decision_values);
contingency_table = generate_contingency_table( ...
    flower_set_number, decision_values);
roc_matrix = generate_roc_curve(decision_values);

% plot ROC curves
plot(roc_matrix(3, :), roc_matrix(2, :), 'y', roc_matrix(5, :), ...
    roc_matrix(4, :), 'r', roc_matrix(7, :), roc_matrix(6, :), 'g', ...
        roc_matrix(9, :), roc_matrix(8, :), 'c', roc_matrix(11, :), ...
            roc_matrix(10, :), 'b');
legend('1', '2', '3', '4', '5', 'location', 'SouthEast')
axis([0 0.6 0 1])

% calculate Area Under Curve for ROC curves
area_under_curve = zeros(5,1);
for i = 1 : size(area_under_curve, 1)
    area_under_curve(i) = trapz(roc_matrix(2 * i + 1, :), ...
        roc_matrix(2 * i , :));
end
