function [H,out_img] = get_homography(img1_name,img2_name)

%%%Command To Run to transform image h1.jpg to h2.jpg.
%%% get_homography("h1.jpg", "h2.jpg")
%%% Double Click on the figures Appearing. Do not single click. Otherwiese
%%% the program will not run.

%Put graphical =0 for debugging
graphical=1;

%%% Read Two Imgaes
imga=imread(img1_name);
imgb=imread(img2_name);
[imga_row,imga_col,imga_channel]=size(imga);
[imgb_row,imgb_col,imgb_channel]=size(imgb);
%%%Initialize Points on Imgaes
points_a=zeros(2,4);
points_b=zeros(2,4);

% %%% Graphical Input of Points for First Image
if(graphical)
    f1=figure;
    imshow(imga);
    for i=1:4
        [points_a(1,i),points_a(2,i)]=getpts()
    end
    close(f1);

    f2=figure;
    imshow(imgb);
    for i=1:4
        [points_b(1,i),points_b(2,i)]=getpts()
    end
    close(f2);
elseif(graphical==0)

%%% Exact Points on two images for Debug Purpose. To enable put graphical
%%% =0 at the top. It is for Debug Purpose.
    points_a=[121,1085,1086,118;119,121,1081,1086];
    points_b =[110, 457,   741,  383 ;  214,   58,  277,  470];
end


%%% Homography Matrix Based on 4 points.
H=get_homograpgy_matrix(points_a, points_b)


% h2 to h1 Homography Matrix to verify.
%H=[0.00399539794880642,	0.00180165687377229,	-0.894006907773387 ;-0.00255080577685794,	0.00247088647051637,	0.448015831064349;5.77445640283428e-07,	-6.63718946115813e-09,	0.00128175915503446]
%  h2 to h1
%     0.0040    0.0018   -0.8939
%    -0.0025    0.0024    0.4483
%     0.0000   -0.0000    0.0013
% 
%   h1 to h2
%     0.0010   -0.0007    0.9882
%     0.0012    0.0019    0.1533
%    -0.0000    0.0000    0.0047

%%% First Transform imga to get the dimension of Canvas.
x_transformed = zeros(imga_row,imga_col);
y_transformed = zeros(imga_row,imga_col);


for i=1:imga_row
    for j=1:imga_col
        x_transformed(i,j)=round((H(1,1)*i+H(1,2)*j+H(1,3))/(H(3,1)*i+H(3,2)*j+H(3,3)));
        y_transformed(i,j)=round((H(2,1)*i+H(2,2)*j+H(2,3))/(H(3,1)*i+H(3,2)*j+H(3,3)));
    end
end

min_x=min(min(x_transformed));
max_x=max(max(x_transformed));

min_y=min(min(y_transformed));
max_y=max(max(y_transformed));

H_inv = inv(H);
canvas_y_dim=(max_y-min_y+1);
canvas_x_dim=(max_x-min_x+1);
x_c = zeros(canvas_x_dim, canvas_y_dim);
y_c = zeros(canvas_x_dim, canvas_y_dim);



%%% Use Inverse Homography matrix to Avoid the the black spots in the canvas. The
%%% black spot occurs due to multiple mapping from imga to canvas or vice versa.

for i=min_x:max_x
    for j=min_y:max_y
        x_c(i-min_x+1,j-min_y+1) = round((H_inv(1,1)*i+H_inv(1,2)*j+H_inv(1,3))/(H_inv(3,1)*i+H_inv(3,2)*j+H_inv(3,3)));
        y_c(i-min_x+1,j-min_y+1) = round((H_inv(2,1)*i+H_inv(2,2)*j+H_inv(2,3))/(H_inv(3,1)*i+H_inv(3,2)*j+H_inv(3,3)));
    end
end


canvas=uint8(zeros(canvas_x_dim,canvas_y_dim,3));


for i=1:canvas_x_dim
    for j=1:canvas_y_dim
        x = x_c(i,j);
        y = y_c(i,j);
        
        %Leave the parts which are not part of imga. The dark part of
        %canvas corresponds to that region.
        if (x_c(i,j)>=1 && x_c(i,j)<=imga_row) && (y_c(i,j)>=1 && y_c(i,j)<=imga_col)
            canvas(i,j,:) = imga(x,y,:);
        end
    end
end


% The below code can be uncommented if one wants to see the black spotted Canvas

%canvas=uint8(zeros(canvas_x_dim,canvas_y_dim,3));
% flag=0;
% %Put Pixel on the canvas
% for i=1:imga_row
%     for j=1:imga_col
%         x_t=x_transformed(i,j)-min_x+1;
%         y_t=y_transformed(i,j)-min_y+1;
%         canvas(y_t,x_t,:)=imga(i,j,:);
%     end
% end

figure();
imshow(imga);
figure();
imshow(canvas);
out_img=canvas;

end

