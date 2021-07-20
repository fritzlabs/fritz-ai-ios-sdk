//
//  PoseUtils.m
//  CarPoseDemo
//
//  Created by cc on 3/26/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

//

#include "opencv2/core/core.hpp"
#include <opencv2/opencv.hpp>
#include <math.h>

#import "PoseUtils.h"


using namespace std;
using namespace cv;


@implementation PoseResult
@end


@implementation PoseUtils

+ (PoseResult*) estimate3DPoseFromPose:(double*)pose2d
                          numKeypoints:(int)numPoints
                           modelPoints:(double*)modelPoints3d
                           focalLength:(double)focal_length
                               centerX:(double)center_x
                               centerY:(double)center_y {
  vector<Point2d> image_points;
  vector<Point3d> model_points;

  for ( int i = 0; i < numPoints; i ++ ) {
    image_points.push_back( Point2d(pose2d[2 * i], pose2d[2 * i + 1]) );
    model_points.push_back( Point3d(modelPoints3d[3*i], modelPoints3d[3*i+1], modelPoints3d[3*i+2]));
  }

  if ( image_points.size() < 4 ) {
    return nil;
  }


  cv::Mat camera_matrix = (cv::Mat_<double>(3,3) <<
                           focal_length, 0           , center_x,
                           0           , focal_length, center_y,
                           0,          0             , 1       );

  // No lens distortion, 4 rows and 1 column.
  cv::Mat dist_coeffs = cv::Mat::zeros(5, 1, cv::DataType<double>::type);

  cv::Mat rvec(3,1,cv::DataType<double>::type);
  cv::Mat tvec(3,1,cv::DataType<double>::type);
  cv::Mat inliers;

  solvePnPRansac(model_points,
                 image_points,
                 camera_matrix,
                 dist_coeffs,
                 rvec,
                 tvec,
                 false,
                 100,
                 1.0,
                 0.65,
                 inliers
                 );

  cv::Mat rotationMat(3, 3, cv::DataType<double>::type);
  cv::setIdentity(rotationMat);
  rotationMat.at<double>(4) = -1;
  rotationMat.at<double>(8) = -1;
  tvec = rotationMat * tvec;
  std::cout << "" << std::endl;
  rvec = rotationMat * rvec;

  PoseResult * result = [PoseResult new];
  if (abs(tvec.at<double>(0)) > 1e10) {
    return result;
  }

  SCNVector4 rotationVector = SCNVector4Make(rvec.at<double>(0), rvec.at<double>(1), rvec.at<double>(2), norm(rvec));
  SCNVector3 translationVector = SCNVector3Make(tvec.at<double>(0), tvec.at<double>(1), tvec.at<double>(2));

  result.translationVector = translationVector;
  result.rotationVector = rotationVector;

  Mat expandedR;
  Rodrigues(rvec, expandedR);

  SCNMatrix4 transform = SCNMatrix4Identity;

  // mCR, 1 based indexing
  // x
  transform.m11 = expandedR.at<double>(0,0);
  transform.m12 = expandedR.at<double>(1,0);
  transform.m13 = expandedR.at<double>(2,0);

  transform.m21 = expandedR.at<double>(0,1);
  transform.m22 = expandedR.at<double>(1,1);
  transform.m23 = expandedR.at<double>(2,1);

  transform.m31 = expandedR.at<double>(0,2);
  transform.m32 = expandedR.at<double>(1,2);
  transform.m33 = expandedR.at<double>(2,2);

  // translation
  transform.m41 = tvec.at<double>(0,0);
  transform.m42 = tvec.at<double>(1,0);
  transform.m43 = tvec.at<double>(2,0);

  result.scenekitCameraTransform = transform;

  return result;
}

@end
