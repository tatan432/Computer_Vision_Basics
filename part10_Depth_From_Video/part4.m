%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Depth From Stereo:  Depth Estimation from 5 frame Sequence
%%% Optimization: MRF Optimization through Graph-Cut Method
%%% Reference : "Consistent Depth Maps Recovery from a Video Sequence", TPAMI'09
%%% Author : Sayan Kumar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Normalized Depth
dmin  = 0;
dstep = 0.0001;
% dmax is decided based on the value of K2 * R2' * (T1 - T2). 
% dmax.* K2 * R2' * (T1 - T2) should be around 0.2*width1
dmax  = 0.015 - dstep; 
depth_val = dmin:dstep:dmax;
no_labels=length(depth_val);

% The following Parameter Taken As per paper
sigmac  = 10;
eta     = 0.05*(dmax - dmin);
ws      = 5./(dmax - dmin);
epsilon = 50;

no_frames=5;
C_M=dlmread('cameras.txt');
C_M = C_M(2:no_frames*7+1,:);

%% Data Term for 5 Frames
ref_no=2;
L_init_sum=0;
ref_frame=imread(['Road/src/test000',num2str(ref_no),'.jpg']);
[height1, width1, channel1] = size(ref_frame);
no_nodes=height1*width1;
img1=ref_frame;

for frame = 1:no_frames
    if(ref_no ~= frame)
        fprintf('Data Term Compuation Start for ref frame=%d and Current Frame=%d\n',ref_no,frame);
        curr_frame= imread(['Road/src/test000',num2str(frame),'.jpg']);
        K1=C_M(((7*(ref_no-1)+1):(7*(ref_no-1)+3)),:);
        R1=C_M(((7*(ref_no-1)+4):(7*(ref_no-1)+6)),:);
        T1=C_M((7*(ref_no-1)+7),:)';

        K2=C_M(((7*(frame-1)+1):(7*(frame-1)+3)),:);
        R2=C_M(((7*(frame-1)+4):(7*(frame-1)+6)),:);
        T2=C_M((7*(frame-1)+7),:)';
        L_init=init_data_term(K1,R1,T1, K2,R2, T2, depth_val, ref_frame, curr_frame,sigmac);
        L_init_sum= L_init_sum +L_init;
        
    end
end

u_x = 1./(max(L_init_sum,3));

% Data Term of Dimension no_labels x no_nodes 
Ed_t_pre= 1 - (u_x .* L_init_sum);
Ed_t_pre = permute(Ed_t_pre, [3 1 2]);
data_term  = reshape(Ed_t_pre, length(depth_val), no_nodes); 

%% Prior Term

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
out_img =reshape(labels, [height1,width1]);
imshow(out_img,[]);