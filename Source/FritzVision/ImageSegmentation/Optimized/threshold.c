//
//  threshold.c
//  FritzVisionSegmentationPredictor
//
//  Created by Christopher Kelly on 11/15/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

#include "threshold.h"


/// Sets values above threshold to 1, setting value below to zero.
///
/// Arguments:
///  - matrix: Base array
///  - values: Output matrix.
///  - thresh: Threshold value.
///  - n: Size of single row in matrix.
void arrayThreshold(float * restrict matrix, float * restrict values, float thresh, size_t n) {
    for (size_t i = 0; i < n; i++) {
        values[i] = matrix[i] > thresh;
    }
}


/// Sets values above threshold to 1 while keeping values below at original value.
///
/// Arguments:
///  - matrix: Base array
///  - values: Output matrix.
///  - thresh: Threshold value.
///  - minAllowed: Lowest value to keep prediction score for.  Values below are 0.
///  - n: Size of single row in matrix.
void fuzzyArrayThreshold(float * restrict matrix, float * restrict values, float thresh, float minAllowed, size_t n) {
    for (size_t i = 0; i < n; i++) {
        float val = matrix[i];
        if (val > thresh) {
            val = 1.0f;
        } else if (val < minAllowed) {
            val = 0.0f;
        }

        values[i] = val;
    }
}


/// Argmax function.  Assumes C x N array
///
/// Arguments:
///  - matrix: Base array
///  - output: Array to store argmax value in.
///  - min_threshold: Minimum confidence value to accept.
///  - n_classes: Number of classes to perform armax across
///  - n: Size of single row in matrix.
void argmax(float * restrict matrix, int * restrict output, float min_threshold, size_t n_classes, size_t n) {
    for (int i = 0; i < n; i++) {
        float val = -1.0;
        int index = -1;

        for (int j = 0; j < n_classes; j++) {
            float currentVal = matrix[j * n + i];
            if (currentVal > val) {
                val = currentVal;
                index = j;
            }
        }
        if (val < min_threshold) {
            index = 0;
        }
        output[i] = index;
    }
}

void classesToColor(int * restrict classMatrix, uint8_t * restrict colors, uint8_t * restrict output, size_t n) {

    int COLOR_WIDTH = 4;
    int R_INDEX = 0;
    int G_INDEX = 1;
    int B_INDEX = 2;
    int A_INDEX = 3;

    for (int i = 0; i < n; i++) {
        int classIdx = classMatrix[i];

        output[i * COLOR_WIDTH + R_INDEX] = colors[classIdx * COLOR_WIDTH + R_INDEX];
        output[i * COLOR_WIDTH + G_INDEX] = colors[classIdx * COLOR_WIDTH + G_INDEX];
        output[i * COLOR_WIDTH + B_INDEX] = colors[classIdx * COLOR_WIDTH + B_INDEX];
        // For outputs of the none class, do not want any alpha value.
        output[i * COLOR_WIDTH + A_INDEX] = classIdx > 0 ? colors[classIdx * COLOR_WIDTH + A_INDEX] : 0;
    }

}
