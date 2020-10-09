function [keypoints, descriptor] = sift_detector(img)

%%% The public code of SIFT has been taken from the below link. It is
%%% widely used SIFT code and cited more than 1300 times thus can be
%%% trusted.
%%% https://www.vlfeat.org/overview/sift.html

image(img);
run('vlfeat-0.9.21/toolbox/vl_setup');
img = single(rgb2gray(img));
[keypoints,descriptor] = vl_sift(img);
perm = randperm(size(keypoints,2)) ;
sel = perm(1:50) ;

end
