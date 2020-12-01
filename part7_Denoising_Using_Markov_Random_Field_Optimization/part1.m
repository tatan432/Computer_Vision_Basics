
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Noise Removal : Binary Graph Cut Optimization of
%%% Markov Random Field
%%% Author : Sayan Kumar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Graph Cut library
addpath('gcmex-2.3.0\GCMex\');
clear all;
close all;


%% Initial Parameters
img=imread("bayes_in.jpg");
lambda=60; % Weight for the Prior Term

SOURCE = [0; 0; 255]; %% blue -> FG
SINK = [245; 210; 110]; %% yellow -> BG

[height,width,depth] = size(img);
no_labels = 2;
no_nodes = height*width;



%% Data Term


data_term = zeros(no_labels,no_nodes);

for row = 1:height
    for col = 1:width
        node= (row-1)*width+col;
        c(1:3,1) = img(row,col,:);
        source_dist = distance(SOURCE,c);
        sink_dist = distance(SINK,c);
        data_term(:,node) = [sink_dist;source_dist];

    end
end

%% Prior Term
prior_val = ones(4*no_nodes,1)*lambda;

sparse_i = zeros(4*no_nodes,1);
sparse_j = zeros(4*no_nodes,1);

count=0;
% Create Prior Edges
for row = 1:height
    for col = 1:width
        node= (row-1)*width+col;
        if row < height
            count = count + 1;
            sparse_i(count,1) = node;
            sparse_j(count,1) = node + width;
        end
        if row > 1
            count = count + 1;
            sparse_i(count,1) = node;
            sparse_j(count,1) = node - width;
        end
        if col < width
            count = count + 1;
            sparse_i(count,1) = node;
            sparse_j(count,1) = node + 1;
        end
        if col > 1
            count = count + 1;
            sparse_i(count,1) = node;
            sparse_j(count,1) = node - 1;
        end
    end
end

prior_term=sparse(sparse_i(1:count,1),sparse_j(1:count,1),prior_val(1:count,1));

%% Disparity Matrix - Straight forward for Binary Labels
[c_i, c_j] = meshgrid(1:no_labels, 1:no_labels);
labelcost = abs(c_i - c_j);
%% Graph Cut Computation

init_label = zeros(no_nodes,1);
[labels E Eafter] = GCMex(init_label, single(data_term), prior_term, single(labelcost),0);


%% Output Image Generation
out_img = zeros(height,width,3);

for row = 1:height
    for col = 1:width
        node = (row-1)*width + col;
        if labels(node,1) == 1
            out_img(row, col, :) = SOURCE ;
        else
            out_img(row, col, :) = SINK ;
        end
    end
end

out_img = uint8(out_img);

figure(1);
imshow(img);
figure(2);
imshow(out_img);


