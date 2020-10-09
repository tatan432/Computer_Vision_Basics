function [out_img] = get_ransac_homography(imga,imgb)


[imga_row,imga_col,imga_channel]=size(imga);
[imgb_row,imgb_col,imgb_channel]=size(imgb);

%%% Find SIFT Keypoints and Descriptors. First Row of Keypoint is X
%%% co-ordinate and Second Row is Y co-ordinate.
%%% 1 Keypoints has the descriptor size of 128.
[keypoints_a,descriptors_a] = sift_detector(imga);
[keypoints_b,descriptors_b] = sift_detector(imgb);

%%% No of Keypoints from SIFT.
[~, nkeypts_a] = size(keypoints_a);
[~, nkeypts_b] = size(keypoints_b);

%%% Form a Match Array Based on L2 Norm. 
match_array = zeros(nkeypts_a,2);

for i = 1 : nkeypts_a
     minimum_dist = double(vecnorm(double(descriptors_a(:,i)-descriptors_b(:,1))));
     for j = 1 : nkeypts_b
         dist = double(vecnorm(double(descriptors_a(:,i)-descriptors_b(:,j))));
         if dist < minimum_dist
            minimum_dist = dist;
            match_array(i,1) = i;
            match_array(i,2) = j;
            match_array(i,3) = minimum_dist;
        end
    end
end

%%% sort the keypoints based on Minimum distance. The First few Keypoints are more relevant.
sorted_match = sortrows(match_array,3);

% canvas = [imga,imgb];

best_points=100;

% figure(1);
% imshow(canvas);
% hold on;
% for i = 1 : best_points
%     y_match = [keypoints_a(2,match_array(i,1)), keypoints_b(2,match_array(i,2))];
%     x_match = [keypoints_a(1,match_array(i,1)), imga_col + keypoints_b(1,match_array(i,2))];
%     scatter(x_match,y_match);
%     %%% LINE SYNTAX: line([x1,x2],[y1,y2]), not line([x1,y1],[x2,y2]);
%     line(x_match,y_match,'Color', [rand,rand,rand],'LineWidth',1)
%     drawnow
% end

iterations=1000;
eps=5;
max_inliers =0 ;

for T=1:iterations
    test_points=6;
    k = randi([1,best_points], [1,test_points]);
    test_matches = sorted_match(k, :);
    %%% Keypoints X and Y co-ordinate
    test_keypoints_a = zeros(2, test_points);
    test_keypoints_b = zeros(2, test_points);
    
    %%% Extraction of Random Test Keypoints
    for j=1:test_points
        a_index=test_matches(j,1);
        b_index=test_matches(j,2);
        test_keypoints_a(1:2,j)=round(keypoints_a(1:2,a_index));
        test_keypoints_b(1:2,j)=round(keypoints_b(1:2,b_index));
    end
        
    %%% Find Homography Matrix with SVD with the extracted random Test Keypoints.
    x_n=[test_keypoints_a(1,:);test_keypoints_b(1,:)];
    y_n=[test_keypoints_a(2,:);test_keypoints_b(2,:)];
    H_test=get_homography_matrix_svd(x_n,y_n);
  
    
    inlier_a_indexes=[];
    inlier_b_indexes=[];
    
    
    %%% Inlier Findings
    inliers=0;
    for i = 1:nkeypts_a
        a_index = match_array(i,1);
        b_index = match_array(i,2);
        a_x = keypoints_a(1, a_index); 
        a_y = keypoints_a(2,a_index) ;

%         n_y = (H_test(2,:)*[ a_x ; a_y ; 1 ])/(H_test(3,:)*[ a_x ; a_y ; 1 ]) ;
%         n_x = (H_test(1,:)*[ a_x ; a_y ; 1 ])/(H_test(3,:)*[ a_x ; a_y ; 1 ]) ; 
        
        H=H_test;
        n_y = (H(1,:)*[ a_y ; a_x ; 1 ])/(H(3,:)*[ a_y ; a_x ; 1 ]) ;
        n_x = (H(2,:)*[ a_y ; a_x ; 1 ])/(H(3,:)*[ a_y ; a_x ; 1 ]) ;
        
        distance = [(keypoints_b(1,b_index)) - n_x; (keypoints_b(2,b_index) - n_y)];
        err = norm(distance);
        if err < eps
            inliers = inliers + 1;
            inlier_a_indexes=[inlier_a_indexes,a_index];
            inlier_b_indexes=[inlier_b_indexes,b_index];
        end    

    end
    
    %%% Save Hompgraphy Matrix with Maximum Inliers.
    if(inliers > max_inliers)
        H_saved=H_test;
        max_inliers=inliers;
        saved_inliers_a=inlier_a_indexes;
        saved_inliers_b=inlier_b_indexes;
    end
end
    
    
% figure(2);
% imshow(canvas);
% hold on;
% [~,no_inliers]=size(saved_inliers_a);
% x_match_arr=zeros(2,no_inliers);
% y_match_arr=zeros(2,no_inliers);
% for i = 1 : no_inliers
%     a_idx=saved_inliers_a(i);
%     b_idx=saved_inliers_b(i);
%     
%     y_match = [keypoints_a(2,a_idx), keypoints_b(2,b_idx)];
%     x_match = [keypoints_a(1,a_idx), imga_col + keypoints_b(1,b_idx)];
%     x_match_arr(1:2,i)=x_match(1:2);
%     y_match_arr(1:2,i)=y_match(1:2);
%     scatter(x_match,y_match);
%     %%% LINE SYNTAX: line([x1,x2],[y1,y2]), not line([x1,y1],[x2,y2]);
%     line(x_match,y_match,'Color', [rand,rand,rand],'LineWidth',1)
%     drawnow
% end


stitch_canvas=stitch_images(imga,imgb,H_saved);
% figure(3);
% imshow(stitch_canvas);
out_img=stitch_canvas;

end

