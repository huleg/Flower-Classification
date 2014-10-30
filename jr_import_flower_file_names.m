function imageName = jr_import_flower_file_names()
% JR_FILE_IMPORT_FLOWER_NAMES imports the names of the flower image files 

imageName = importdata('oxfordflower3/jpg/files.txt');
imageName = cell2mat(imageName);
end