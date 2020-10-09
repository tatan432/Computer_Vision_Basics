################################################################
#3##############################################################
###
### FILENAME: orb_match.py
### Created by: Sayan Kumar
### Date: 01/03/2020
###
### Description: The program takes two subsequent video frames
### and matches the relevant keypoints.It can also use two images
### takes from differnet viewpoint to match. Flann Matching or 
### Brute force hamming matching can be selected by switch. The 
### progam uses OpenCV version of 3.2.0
###
################################################################
################################################################




from __future__ import print_function
import cv2
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg 
import csv
import time



#################PARAMETERS to Control the Program#################

MAX_FEATURES = 500
GOOD_MATCH_PERCENT = 0.15
flann=1 #Nearest Neighbour Matching by Flann Matching
brute_force_hamming=0 #Nearest Neighbour Matching by Brute Force Hamming
ratio_matching=1  #Threshold Matching applied after flann and brute has done their work
min_distance_match=0  #distance from minmum residue 
match_file_path = 'match_perf.csv' 
#std::vector< DMatch > matches;//Way to Define a DMatch Matrix
image_match_show=1 #Show the image with matching points
image_novel_show=0 #Show the (i+1)th image with novel keypoints

####################################################################


 
def matchframe(im1, im2,threshold):



######Convert images to grayscale if in color##################

  im1_shape=(len(im1.shape))
  if(im1_shape==3):
      channel=im1.shape[2]
  else:
      channel=1
  print("Channel No= ",channel)
  if(channel==3):
      im1Gray = cv2.cvtColor(im1, cv2.COLOR_BGR2GRAY)
      im2Gray = cv2.cvtColor(im2, cv2.COLOR_BGR2GRAY)

  elif(channel==1):
      im1Gray=im1
      im2Gray=im2

###############################################################



########## Detect ORB features and compute descriptors.#######

  start=time.time() 
  orb = cv2.ORB_create(nfeatures=400)
  keypoints1, descriptors1 = orb.detectAndCompute(im1Gray, None)
  keypoints2, descriptors2 = orb.detectAndCompute(im2Gray, None)
  key_pt_des_time=(time.time()-start) 

##############################################################
  

########## KNN Matching With FLANN ###########################

  raw_match=0
  if (flann==1):
      # BFMatcher with default params
      bf = cv2.BFMatcher()
      matches = bf.knnMatch(descriptors1, descriptors2, k=2)
      raw_match=int(len(matches))
      
  elif (brute_force_hamming==1): 
      # Match features.
      matcher = cv2.DescriptorMatcher_create(cv2.DESCRIPTOR_MATCHER_BRUTEFORCE_HAMMING)
      matches = matcher.match(descriptors1, descriptors2, None)
      raw_match=int(len(matches))
      

  else:
      print ("Select a Valid Matcher")


###############################################################      


############ Thresholding on KNN Matches ######################

  numGoodMatches=0
  #Apply Low'e Ration Test. Understandign how it works. Please read. 
  #https://www.cs.ubc.ca/~lowe/papers/ijcv04.pdf - Section 7.1
  if(ratio_matching==1): #My Created Variable. Not there in original Code
      good_matches = []
      novel=[]
      for m,n in matches:
          if m.distance < 0.75*n.distance:
              good_matches.append(m)
          else:
              novel.append(m)
      numGoodMatches=int(len(good_matches))

  elif (min_distance_match==1): #My Created Variable. Not there in original Code

      # Sort matches by score
      matches.sort(key=lambda x: x.distance, reverse=False)
      min_distance_match=matches[0].distance
      print(min_distance_match)
      idx=0
      for match_i in matches:
          if(match_i.distance <= 2*min_distance_match):
              idx=idx+1
              #Remove not so good matches
              #numGoodMatches = int(len(GoodMatches))#* GOOD_MATCH_PERCENT)
      numGoodMatches = idx
      good_matches = matches[:numGoodMatches]
      novel=matches[numGoodMatches:]

  else:
      print ("Select a good thresholding Technique")

################################################################



################# Further Refinement of Matches by RANSAC ####### 


  #RANSAC Test on Good Matches to find more refined match.
  #cv2.FM_RANSAC requires minimum 8 matching points
  # Param1: maximum distance from a point to an epipolar line in pixels, beyond which the point is considered an outlier
  # Param2: Confidence Level
  #inliers: Mask Matrix. inlier[0]>0 indicates it is an inlier
  
  if(numGoodMatches>=8):
      ransac_matches = []
      points1, points2 = [], []
      for match in good_matches:
      	points1.append(keypoints1[match.queryIdx].pt)
      	points2.append(keypoints2[match.trainIdx].pt)
      
      fundamental, inliers = cv2.findFundamentalMat(np.float32(points1), np.float32(points2), method=cv2.FM_RANSAC, param1=3, param2=0.99)

      for inlier, match in zip(inliers, good_matches):
          if inlier[0] > 0:
              ransac_matches.append(match)

      ransac_match_no=int(len(ransac_matches))

  else:
      ransac_match_no=0


##################################################################

 
############## Determine Novel and Matching Points################

  imnovel=None
  novel_pt=[]
  for nv_pt in novel:
      novel_pt.append(keypoints1[nv_pt.queryIdx])

  # Draw top matches
  imMatches = cv2.drawMatches(im1, keypoints1, im2, keypoints2, ransac_matches, None)
  imnovel = cv2.drawKeypoints(im1, novel_pt, imnovel, color=(0,255,0), flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

###################################################################


############## Image Viewing Functions ############################

  if(image_match_show==1):
     cv2.imwrite("match_boat.jpg", imMatches)
     img=mpimg.imread("match_boat.jpg")
     plt.imshow(img)
     plt.show()

######################################################################


########## Write Results in CSV ######################################

  try:
      fp = open(match_file_path)
  except IOError:
      # If not exists, create the file
      #fp = open(match_file_path, 'w+')
      with open(match_file_path, 'a', newline='') as csvfile:
          fieldnames = ['feature_no','threshold','flann/brut match','RANSAC Match']
          writer = csv.writer(csvfile)
          writer.writerow(fieldnames)
  with open(match_file_path, 'a', newline='') as csvfile:
     fields = [raw_match,threshold,numGoodMatches,ransac_match_no]
     writer = csv.writer(csvfile)
     writer.writerow(fields)

######################################################################

 
 
if __name__ == '__main__':
   
  # Read reference image
  nxtFilename = "boat_pic1.png"
  print("Reading reference image : ", nxtFilename)
  imnxt = cv2.imread(nxtFilename, cv2.IMREAD_COLOR)
 
  # Read image to be aligned
  prevFilename = "boat_pic2.png"
  print("Reading image to align : ", prevFilename);  
  imprev = cv2.imread(prevFilename, cv2.IMREAD_COLOR)
   
  print("Matching images ...")
  matchframe(imnxt, imprev,threshold)

  
