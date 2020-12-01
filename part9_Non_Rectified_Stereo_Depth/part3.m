%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Depth From Stereo:  Non-Rectified Images
%%% Optimization: MRF Optimization through Graph-Cut Method
%%% Reference : "Consistent Depth Maps Recovery from a Video Sequence", TPAMI'09
%%% Author : Sayan Kumar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Graph Cut library
addpath('gcmex-2.3.0\GCMex\');
clear all;
close all;

%% Initial Parameters
img1=double(imread("test00.jpg"));
[height1, width1, channel1] = size(img1);
img2=double(imread("test09.jpg"));
[height2, width2, channel2] = size(img2);

% Normalized Depth
dmin  = 0;
dstep = 0.0001;
% dmax is decided based on the value of K2 * R2' * (T1 - T2). 
% dmax.* K2 * R2' * (T1 - T2) should be around 0.2*width1
dmax  = 0.015 - dstep; 
depth_val = dmin:dstep:dmax;
no_nodes = height1*width1;
no_labels=length(depth_val);

% The following Parameter Taken As per paper
sigmac  = 10;
eta     = 0.05*(dmax - dmin);
ws      = 5./(dmax - dmin);
epsilon = 50;


%% Camera Parameters provided in the paper and Assignment
K1 = [1221.2270770       0.0000000     479.5000000 ; 0.0000000    1221.2270770     269.5000000 ; 0.0000000       0.0000000       1.0000000 ];
K2 = [1221.2270770       0.0000000     479.5000000 ; 0.0000000    1221.2270770     269.5000000 ; 0.0000000       0.0000000       1.0000000 ];
    
R1 =  [1.0000000000	  0.0000000000	  0.0000000000 ; 0.0000000000	  1.0000000000	  0.0000000000 ; 0.0000000000	  0.0000000000	  1.0000000000];
R2 = [0.9998813487    0.0148994942	  0.0039106989 ; -0.0148907594    0.9998865876   -0.0022532664 ; -0.0039438279	  0.0021947658	  0.9999898146];
  
T1 = [ 0.0000000000; 0.0000000000; 0.0000000000]; 
T2 = [-9.9909793759; 0.2451742154; 0.1650832670];    



%% Data-Term Computation
fprintf('Data Term Compuation Start \n');

img_distance=zeros(no_nodes, 1);
img_diff = zeros(height1, width1, length(depth_val));
img1_temp = zeros(no_nodes, 3);
img2_temp = zeros(no_nodes, 3);

homo_cord1 = zeros(3, no_nodes); % Homogeneous Co-ordinate at Image1
homo_cord2 = zeros(3, no_nodes, length(no_labels)); % Homogeneous Co-ordinate at Image2 

% Arrange Homogeneous Co-ordinate for Image1 and Get the corresponding
% pixel Value
for row=1:height1
    for col=1:width1
        node= (row-1)*width1+col;
        homo_cord1(:,node) = [col; row; 1]; % Image Co-ordinate - Columnwise X. Row-wise Y.
        
    end
end

img1_temp = impixel(img1,homo_cord1(1,:), homo_cord1(2,:));

for i=1:length(depth_val)
    depth = depth_val(i);
    
    % For Each Depth Compute Homo-geneous Co-ordinate in the Rectified
    % second Image 
    homo_cord2(:,:) = ((K2 *  R2' * R1 * inv(K1)) * homo_cord1) + repmat((depth .* K2 * R2' * (T1 - T2)), 1, no_nodes);
    homo_cord2(:,:) = round((homo_cord2(:,:)./repmat(homo_cord2(3,:),3,1)));
    img2_temp(:,:) = impixel(img2, homo_cord2(1,:), homo_cord2(2,:));
    img2_temp(isnan(img2_temp(:,:))) = 0;
    temp_diff=img1_temp -img2_temp(:,:);
    
    % Compute Image Distance for all probable Depth Values
    img_distance(:) = sqrt(sum((temp_diff.^2),2));
    img_diff(:,:,i) = reshape(img_distance(:)', width1, height1)';
    
end

% % Determine L_init -> Disparity Likelihood in the Paper
L_init = (sigmac)./(sigmac + img_diff);


% Adaptive Normalization Factor
u_x = 1./(max(L_init,3));

% Data Term of Dimension no_labels x no_nodes 
Ed_t_pre= 1 - (u_x .* L_init);
Ed_t_pre = permute(Ed_t_pre, [3 1 2]);
data_term  = reshape(Ed_t_pre, length(depth_val), no_nodes); 


%% Prior Terms Computation

fprintf('Prior Term Compuation Start \n');

[sparse_i, sparse_j] = connect_edges(height1,width1); 

% Get RGB Values of Image1
R = double(img1(:,:,1)); 
G = double(img1(:,:,2));
B = double(img1(:,:,3));

% Compute Lambda Unformalized Portion First -> Without ws
lambda_unnorm = 1./( sqrt((R(sparse_i(:,1)) - R(sparse_j(:,1))).^2 + (G(sparse_i(:,1)) - G(sparse_j(:,1))).^2 + (B(sparse_i(:,1)) - B(sparse_j(:,1))).^2) + epsilon);
prior_unnorm = sparse(sparse_i(:,1), sparse_j(:,1), lambda_unnorm, no_nodes, no_nodes, 4*no_nodes); % Prior Term as if the lamda is not normalized


% Compute labda normalization factor -> u_lambda
% Firt Compute N Required for Averaging
Nx = 4*ones(height1, width1);
Nx(1,1) = 2; Nx(1,width1)=2; Nx(height1,1)=2; Nx(height1,width1)=2; % No of Eges is 2 at the Corners
Nx(:,1) = 3; Nx(:,width1) = 3; Nx(1,:) = 3; Nx(height1,:) = 3;  % No of Eges is 3 aling eges
Nx = reshape(Nx, [no_nodes, 1]);

% Compute Normalizing Factor
prior_unnorm_sum=sum(prior_unnorm);
prior_unnorm_sum=reshape(prior_unnorm_sum , no_nodes,1);
norm_fact= Nx./(prior_unnorm_sum);

% Compute the smoothing weights
lambda_norm = ws .* lambda_unnorm .* norm_fact(sparse_i(:,1)) ;
% Compute the Smoothing cost or lambda matrix
prior_term = sparse(sparse_i(:,1), sparse_j(:,1), lambda_norm, no_nodes, no_nodes, 4*no_nodes);


%% Disparity Matrix
[c_i, c_j] = meshgrid(1:no_labels, 1:no_labels);
labelcost = min(abs(c_i - c_j),eta); % Taken From Paper "Consistent Depth Maps Recovery from a Video Sequence"  

%% Graph Cut Computation

fprintf('Graph Cut Optimization Start \n');

init_label = zeros(no_nodes,1);
[labels, E Eafter] = GCMex(init_label, single(data_term), prior_term, single(labelcost),0);


%% Display Results 

histogram(labels);
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