function [out_img]=stitch_images (imga, imgb, H)

[imga_row,imga_col,imga_channel]=size(imga);
[imgb_row,imgb_col,imgb_channel]=size(imgb);
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


% Determining the Offsets by which the the translated image and original
% image needs to be shifted

if min_y<1
    lower_y = (min_y-1);
else
    lower_y = 0;
end


if min_x<1              
    lower_x = (min_x-1);
else
    lower_x = 0;
end

pre_canvas_x = max_x-lower_x;
pre_canvas_y = max_y-lower_y;

x_c = zeros(pre_canvas_x, pre_canvas_y);
y_c = zeros(pre_canvas_x, pre_canvas_y);

%Inverse Homography Matrix
H_inv = inv(H);

for i=min_x:max_x
    for j=min_y:max_y
        x_c(i-lower_x,j-lower_y) = round((H_inv(1,1)*i+H_inv(1,2)*j+H_inv(1,3))/(H_inv(3,1)*i+H_inv(3,2)*j+H_inv(3,3))); 
        y_c(i-lower_x,j-lower_y) = round((H_inv(2,1)*i+H_inv(2,2)*j+H_inv(2,3))/(H_inv(3,1)*i+H_inv(3,2)*j+H_inv(3,3)));
    end
end

canvas_x_dim = 1 + max(max_x-lower_x,imgb_row-lower_x);
canvas_y_dim = 1 + max(max_y-lower_y,imgb_col-lower_y);


canvas=uint8(zeros(canvas_x_dim,canvas_y_dim,3));


%%% Put the second Image in the Canvas
for i= 1 : imga_row
    for j= 1 : imga_col
        if canvas(i-lower_x,j-lower_y,:) == zeros(1,1,3)
            canvas(i-lower_x,j-lower_y,:) = imgb(i,j,:);
        else
            canvas(i-tr_x,j-tr_y,:) = imgb(i,j,:);
        end
    end
end

%%% Put the transformed fitst image in the Canvas. 
for i= min_x : max_x
    for j= min_y : max_y
        x = x_c(i-lower_x,j-lower_y);
        y = y_c(i-lower_x,j-lower_y);
        if (x>=1 && x<=imga_row) && (y>=1 && y<=imga_col)
           canvas(i-lower_x,j-lower_y,:) = imga(x,y,:);
        end
    end
end


out_img=canvas;
end