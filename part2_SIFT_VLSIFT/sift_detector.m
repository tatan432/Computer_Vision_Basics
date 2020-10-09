function [keypoints, descriptor] = sift_detector(image_name)

%%% The public code of SIFT has been taken from the below link. It is
%%% widely used SIFT code and cited more than 1300 times thus can be
%%% trusted.
%%% https://www.vlfeat.org/overview/sift.html
img=imread(image_name);
image(img);
run('vlfeat-0.9.21/toolbox/vl_setup');
img = single(rgb2gray(img));
[keypoints,descriptor] = vl_sift(img);
perm = randperm(size(keypoints,2)) ;
sel = perm(1:50) ;
h1 = vl_plotframe(keypoints(:,sel)) ;
h2 = vl_plotframe(keypoints(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descriptor(:,sel),keypoints(:,sel)) ;
set(h3,'color','g') ;

end
