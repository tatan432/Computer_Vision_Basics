
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Depth From Stereo:  Rectified Images
%%% Optimization: MRF Optimization through Graph-Cut Method
%%% Author : Sayan Kumar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Graph Cut library
addpath('gcmex-2.3.0\GCMex\');
clear all;
close all;


%% Initial Parameters
img1=double(imread("im6.png"));
[height1, width1, channel1] = size(img1);
img2=double(imread("im2.png"));
[height2, width2, channel2] = size(img2);
lambda=100; % Weight for the Prior Term

%% Data-Term Computation
fprintf('Data Term Compuation Start \n');
depth_val = 1:0.2*width1;
no_nodes = height1*width1;
no_labels=length(depth_val);

img_distance = zeros(no_labels,height1, width1);
img_temp = zeros(height1, width1, 3);


for i=1:length(depth_val)
    depth = depth_val(i);
    img_temp = [img2(:,depth+1:width2,:),  zeros(height2, depth,3)];
    temp_diff = img1 - img_temp;
    img_distance(i,:,:) = sqrt(sum(temp_diff.^2,3));
end

data_term = reshape(img_distance, no_labels, no_nodes); 

%% Prior Terms
fprintf('Prior Term Compuation Start \n');

prior_val = ones(4*no_nodes,1)*lambda;
[sparse_i, sparse_j]= connect_edges(height1,width1);
prior_term0=sparse(sparse_i(:,1),sparse_j(:,1),lambda,no_nodes,no_nodes,4*no_nodes);



%% Disparity Matrix
[c_i, c_j] = meshgrid(1:no_labels, 1:no_labels);
eta = 0.05*(max(depth_val)-min(depth_val));
labelcost = min(abs(c_i - c_j),eta); % Taken From Paper "Consistent Depth Maps Recovery from a Video Sequence"  



%% Graph Cut Computation
fprintf('Graph Cut Optimization Start \n');
init_label = ones(no_nodes,1);
[labels, E Eafter] = GCMex(init_label, single(data_term), prior_term0, single(labelcost),0);


%% Display Results 

histogram(labels);
% max_out=max(max(out_img));
out_img =reshape(labels, [height1,width1]);
in_img1 = uint8(img1);
in_img2 = uint8(img2);
figure(1);
subplot(1,2,1);
imshow(in_img1);
subplot(1,2,2);
imshow(in_img2,[]);
figure(2);
imshow(out_img,[]);