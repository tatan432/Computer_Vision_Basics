# Folder Description
There are many basic algorithms of computer vision which are either implemented in MATLAB or Python-OpenCV. They can be downloaded or consulted for understanding.

## MATLAB Folders:Denoted By PARTX
1. The folder can be saved to any directory.
2. There are six partx_xx folders.
3. Steps to Run the each part -
	a. Go to each part and extract vlfeat-0.9.21.rar folder. This folder contains the code for SIFT which has been downloaded from -
	   https://www.vlfeat.org/overview/sift.html and is highly cited work.
	
	b. First matlab working path should be the set to the part directory. For me to run the part1 code I need to set the working directory as -
	
	   E:\<Assignment_directory>\Assignment_1_Sayan_Kumar\Part1
	   Similarly to run the code for part2 change the MATLAB working directory to  
	   E:\<Assignment_directory>\Assignment_1_Sayan_Kumar\Part2
	   
	b. To run each part the following command to run -

		part1: 
		>> image= detect_edge("SOBEL","im01.jpg")
		>> image= detect_edge("GAUSIAN","im01.jpg",sigma,kernel_size) - Example : detect_edge("GAUSIAN","im01.jpg",1,3)
		>> image= detect_edge("HARR","im01.jpg",type,kernel_size) - Example 1:Unit Size Harr Feature Kernel of type 1- >> detect_edge("HARR","im01.jpg",1,1)
		   Example 2: Harr Feature Kernel of type  of size 3- detect_edge("HARR","im01.jpg",5,3)
		   %%% Unit Size Harr Kernel Types:
		   %%% type 1 : (-1,+1) 
		   %%% type2: tranpose(-1,+1)
		   %%% type 3: (+1,-1,+1)
		   %%% type 4: trnaspose(+1,-1,+1)
		   %%% type 5: (-1,+1;+1,-1)
		   %%% kernel_size will make the kernel bigger by kernel_size times.

		part2:
		>> [keypoints, descriptor]=sift_detector("im01.jpg")

		Part3:
		>> [H,image]=get_homography("h1.jpg","h2.jpg")  --> h1 to h2 homography
		>> [H,image]=get_homography("h2.jpg","h1.jpg")  --> h2 to h1 homography	

		Part4:
		>> [Hm,image]=get_homography_manual("im02.jpg","im01.jpg")  --> im02 to im01 homography and stitching

		Part5:
		>> [H12,image]=get_ransac_homography("im01.jpg","im02.jpg")  --> im01 to im02 automatic homography and stitching	
		>> [H21,image]=get_ransac_homography("im01.jpg","im02.jpg")  --> im01 to im02 automatic homography and stitching	

		Part6:
		>>[image]=get_basic_panorama("im01.jpg","im02.jpg","im03.jpg");
    
    ## Other Folder : 
    ORB_MATCHING: ORB Python-OPENCV Program has been implemented to match two images.
	   .
