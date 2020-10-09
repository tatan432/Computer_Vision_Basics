import numpy as np
import cv2
from matplotlib import pyplot as plt
print (cv2.__version__)

img = cv2.imread('boat_pic1.png',cv2.IMREAD_COLOR)
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
img2=None

# Initiate STAR detector
orb = cv2.ORB_create(nfeatures=10000)
print("Max Features= ",orb.getMaxFeatures(),',')
print("ScaleFactor= ",orb.getScaleFactor(),',')
print("NLevels= ",orb.getNLevels(),',')
print("EdgeThreshold= ",orb.getEdgeThreshold(),',')
print("FirstLevel= ",orb.getFirstLevel(),',')
print("WTA_K= ",orb.getWTA_K(),',')
print("ScoreType= ",orb.getScoreType(),',')
print("PatchSize= ",orb.getPatchSize(),',')
print("FastThreshold= ",orb.getFastThreshold(),',')
print("DefaultName`= ",orb.getDefaultName)

#CV_WRAP virtual void setPatchSize(int patchSize) = 0;
#CV_WRAP virtual int getPatchSize() const = 0;

# find the keypoints with ORB
kp = orb.detect(img_gray,None)
#print(kp)

# compute the descriptors with ORB
kp, des = orb.compute(img_gray, kp)

# draw only keypoints location,not size and orientation
img2 = cv2.drawKeypoints(img,kp,img2,color=(0,255,0), flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
plt.imshow(img2),plt.show()
