function [out_img] = get_basic_panorama(varargin)

%%% Finding Basic Panorama of images.
%%% Command to Run: get_basic_panorama("im01.jpg","im02.jpg","im03.jpg")
%%% Disclaimer: Running
%%% get_basic_panorama("im01.jpg","im02.jpg","im03.jpg","im04.jpg") doesn't
%%% work as it exceeds the MATLAB Array Bound.

[~,num_images]=size(varargin)
img=(varargin(1,1));

canvas=imread([img{:}]);

for i=2:num_images
    img=(varargin(1,i));
    imgi = imread([img{:}]);
    canvas= get_ransac_homography(imgi,canvas);
    figure();
    imshow(canvas);
end

figure(i);
imshow(canvas);
out_img=canvas;

end