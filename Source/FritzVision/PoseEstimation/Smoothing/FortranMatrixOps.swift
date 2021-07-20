//Copyright (c) 2014-present FontAwesome.swift contributors
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.
//
//  fortranMatrixOps.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 01/02/2017.
//  Copyright © 2017 Alex Gubbay. All rights reserved.
//

import Foundation

/// A translation of Fortran Matrix operations relied upon by the Savitzky Golay algorithm for coeff generation. Original:
///
/// J-P Moreau. (n.d.). LU Decomposition Routines - f90. Retrieved February 7, 2017, from http://jean-pierre.moreau.pagesperso-orange.fr/Fortran/lu_f90.txt
class FortranMatrixOps {

  func luBacksubstitute(a: [[Double]], n: Int, np: Int, index: [Int], b: [Double]) -> [Double] {
    var wB = b
    let wA = a
    let wIndex = index
    var sum = 0.0
    var ii = 0
    for i in 1...n {
      let ll = wIndex[i]
      sum = wB[ll]
      wB[ll] = wB[i]
      if ii != 0 {
        for j in ii...i-1 {
          sum = sum - wA[i][j] * wB[j]

        }
      } else if sum != 0 {
        ii = i
      }
      wB[i] = sum
    }
    for i in stride(from: n, to: 0, by: -1) {
      sum = wB[i]
      if i < n {
        for j in i+1...n {
          sum = sum - wA[i][j] * wB[j]
        }
      }
      wB[i] = sum/wA[i][i]
    }
    return wB
  }

  func luDecomposition(a: [[Double]], n: Int, index: [Int], d: Double) -> (
    index: [Int], a: [[Double]]
  ) {
    let nmax = 100
    let tiny = 1.0e-20
    var wA = a
    var wIndex = index
    var wD = d
    var sum = 0.0
    var dum = 0.0
    var vv = Array(repeating: 0.0, count: nmax)
    var aamax = 0.0
    var imax = 0
    wD = 1
    for i in 1...n {
      aamax = 0.0
      for j in 1...n {

        let absA = abs(wA[i][j])
        if absA > aamax {
          aamax = absA
        }
      }
      if aamax == 0 {
        print("singular matrix")
      }
      vv[i] = 1.0/aamax
    }
    for j in 1...n {
      if j > 1 {
        for i in 1...j-1 {
          sum = wA[i][j]
          if i > 1 {
            for k in 1...i-1 {
              sum = sum - wA[i][k] * wA[k][j]
            }
            wA[i][j] = sum
          }
        }
      }
      aamax = 0.0
      for i in j...n {
        sum = wA[i][j]
        if j > 1 {
          for k in 1...j-1 {
            sum = sum - wA[i][k] * wA[k][j]
          }
          wA[i][j] = sum
        }
        dum = vv[i] * abs(sum)
        if dum >= aamax {
          imax = i
          aamax = dum
        }
      }
      if j != imax {
        for k in 1...n {
          dum = wA[imax][k]
          wA[imax][k] = wA[j][k]
          wA[j][k] = dum
        }
        wD = -wD
        vv[imax] = vv[j]
      }
      wIndex[j] = imax
      if j != n {
        if wA[j][j] == 0.0 {
          wA[j][j] = tiny
        }
        dum = 1/wA[j][j]
        for i in j+1...n {
          wA[i][j] = wA[i][j] * dum
        }
      }
    }
    if wA[n][n] == 0 {
      wA[n][n] = tiny
    }
    return (wIndex, wA)
  }
}
