function [out_img] = detect_edge(detector,img_name, varargin)

%%% Assignment Part 1  %%%
%%% EDGE DETCTORS      %%%
%%% Author : Sayan Kumar %%%

%%% Command To Run the Script %%%%

%%% SOBEL: >>detect_edge("SOBEL","im01.jpg") - im01.jpg can be replaced with
%%% any other image name.

%%% Gausian : detect_edge("GAUSIAN","im01.jpg",sigma,kernel_size) 
%%% Example: >>detect_edge("GAUSIAN","im01.jpg",1,3)

%%% Harr : detect_edge("HARR","im01.jpg",type,kernel_size)
%%% type 1 : (-1,+1) 
%%% type2: tranpose(-1,+1)
%%% type 3: (+1,-1,+1)
%%% type 4: trnaspose(+1,-1,+1)
%%% type 5: (-1,+1;+1,-1)
%%% All the type can be scaled by the parameter 'kernel_size'
%%% Example: Unit Size Harr Feature Kernel of type 1- 
%%% >>detect_edge("HARR","im01.jpg",1,1)
%%% Example: Harr Feature Kernel of type  of size 3- 
%%% detect_edge("HARR","im01.jpg",5,3)


img=imread(img_name);
%figure();
%imshow(img);
[img_row, img_col, channel]= size(img);
if(channel==3)
    image= rgb2gray(img);
else
    image=img;
end
gray_img=image;
image=double(image);
outimg = double(zeros(img_row,img_col));

%%% SOBEL EDGE DETECTOR

if(detector=="SOBEL")
    kernelx = double([1,0,-1;2,0,-2;1,0,1]);
	kernely = double([1,2,1;0,0,0;-1,-2,-1]);
    for i=1:img_row-2
        for j=1:img_col-2
			sum1 = sum(sum(kernelx.*image(i:i+2,j:j+2)));
			sum2 = sum(sum(kernely.*image(i:i+2,j:j+2)));
			outimg(i, j) = (sum1^2+sum2^2);
        end
    end

elseif (detector == "GAUSIAN")
        sigma = cell2mat(varargin(1,1));
        kernel_size = cell2mat(varargin(1,2));
    
    
        %%% Creating Gausian Kernel First
        m = (kernel_size-1)/2;

        [x,y] = meshgrid(-m:m,-m:m);
        gausian_kernel = double(exp(-(x.*x + y.*y)/(2*sigma*sigma)));
        
        sum_kernel = sum(sum(gausian_kernel(:)));
        
        %%% Do FINITE Nomrlization to Normalize the Kernel. Normalization
        %%% with (1/2*pi*sigma^2) is a normalization for infinite gausian.
        gausian_kernel  = gausian_kernel./sum_kernel

        %%% 2D Convolution Operation with Gausian Kernel
        %floor_m=ceil(m);
        for i=1:img_row-kernel_size+1
            for j=1:img_col-kernel_size+1
                outimg(i, j)= sum(sum(gausian_kernel.*image(i:i+kernel_size-1,j:j+kernel_size-1)));
            end
        end
        
    
elseif (detector =="HARR")
    

    type = cell2mat(varargin(1,1));
    kernel_size = cell2mat(varargin(1,2));
    
    %%% Creating the Kernels according the description at the beginning
    if(type==1)
        harr_kernel = [-1*ones(kernel_size,kernel_size), ones(kernel_size,kernel_size)];
        
    elseif (type==2)
        harr_kernel = [-1*ones(kernel_size,kernel_size); ones(kernel_size,kernel_size)];
    elseif (type==3)
        harr_kernel = [ones(kernel_size,kernel_size), -1*ones(kernel_size,kernel_size),ones(kernel_size,kernel_size)];
    elseif (type==4)
        harr_kernel = [ones(kernel_size,kernel_size); -1*ones(kernel_size,kernel_size);ones(kernel_size,kernel_size)];
    elseif (type==5)
        harr_kernel = [-1*ones(kernel_size,kernel_size), ones(kernel_size,kernel_size); ones(kernel_size,kernel_size), -1*ones(kernel_size,kernel_size)];        
    end
    
    harr_size = size(harr_kernel);
    
    %%% Convolution
    for i=1:img_row-harr_size(1)+1
        for j=1:img_col-harr_size(2)+1
            outimg(i, j)= sum(sum(harr_kernel.*image(i:i+harr_size(1)-1,j:j+harr_size(2)-1)));
        end
    end    

end

%Normalize the image, otherwise the values will be out of bound to 255 and
%will not give the correct result.

imgmin = min(min(outimg));
imgmax = max(max(outimg));
if imgmin ~= imgmax
    outimg = (outimg-imgmin)/(imgmax-imgmin)*255;
end

%%% Showing the output
out_img=uint8(outimg);
figure();
% subplot(1,2,1), imshow(gray_img);
% subplot(1,2,2), imshow(out_img);

imshow(out_img);
end
