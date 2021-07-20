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
//  Savitzky-Golay.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 01/02/2017.
//  Copyright © 2017 Alex Gubbay. All rights reserved.
//

/// Implementation of the Savitzky-Golay filter. Described in: Fasano, G., Franceschini, A., & Peacock, J. A. (1986). 4.8 Savitzky-Golay Smoothing Filters. In NUMERICAL RECIPES IN FORTRAN 77: THE ART OF SCIENTIFIC COMPUTING (Vol. 2253, pp. 155–170). Cambridge University Press.

extension Double {
  /**
   Utility function for rounding doubles to a specified number of places.
   */
  func roundTo(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

precedencegroup PowerPrecedence {
  higherThan: MultiplicationPrecedence
}
infix operator ^^: PowerPrecedence

/// Utility function to ease raising a number to the power. Allows for `x^^y` to denote rasing x to y.
func ^^ (first: Double, second: Double) -> Double {
  return pow(Double(first), Double(second))
}

public class SavitzkyGolayFilter<PointT: SmoothingPointable>: PointFilterable {

  var params = [String: Double]()

  var count = 0
  var coeffs = [Double]()
  var index = Array(repeating: 0, count: 50)
  var id = 0
  var buffer = [SmoothingPoint]()
  var size = 0

  public class Options: FilterOptions {

    let leftScan: Int
    let rightScan: Int
    let polonomialOrder: Int

    public init(leftScan: Int = 2, rightScan: Int = 2, polonomialOrder: Int = 2) {
      self.leftScan = leftScan
      self.rightScan = rightScan
      self.polonomialOrder = polonomialOrder
    }

    public required init() {
      self.leftScan = 2
      self.rightScan = 2
      self.polonomialOrder = 2
    }
  }

  public required init(options: Options) {
    params["rightScan"] = Double(options.leftScan)
    params["leftScan"] = Double(options.rightScan)
    size = Int(params["leftScan"]!) + Int(params["rightScan"]!) + 1

    params["filterPolynomial"] = Double(options.polonomialOrder)
    coeffs
      = calculateCoeffs(
        nl: Int(params["leftScan"]!),
        nr: Int(params["rightScan"]!),
        m: Int(params["filterPolynomial"]!)
      )
  }

  public func setParameter(name: String, value: Double) {
    params[name] = value
    coeffs
      = calculateCoeffs(
        nl: Int(params["leftScan"]!),
        nr: Int(params["rightScan"]!),
        m: Int(params["filterPolynomial"]!)
      )
    size = Int(params["leftScan"]!) + Int(params["rightScan"]!) + 1
  }

  public func filter(_ point: PointT) -> PointT {
    let smoothingPoint = point.buildSmoothingPoint(count: count)
    let result = addAndProcessDataPoint(dataPoint: smoothingPoint)
    count += 1
    return PointT(result)
  }

  func addAndProcessDataPoint(dataPoint: SmoothingPoint) -> SmoothingPoint {
    if self.buffer.count < self.size {
      self.buffer.append(dataPoint)
      return dataPoint
    }
    self.buffer.append(dataPoint)
    let current = self.buffer[(self.size-Int(self.params["rightScan"]!))]
    let newPoint = self.applyFilter(pointToProcess: current, buffer: self.buffer)
    self.buffer.removeFirst()
    return newPoint
  }

  // Applies the filter to the given point and buffer.
  public func applyFilter(pointToProcess: SmoothingPoint, buffer: [SmoothingPoint])
    -> SmoothingPoint
  {

    let nr = Int(params["rightScan"]!)
    let nl = Int(params["leftScan"]!)
    let newPoint = SmoothingPoint()
    newPoint.count = pointToProcess.count+nr
    let size = nl + nr + 1
    var tempX = 0.0
    var tempY = 0.0
    var tempZ = 0.0
    for i in 0...size-1 {
      let coeff = coeffs[i]
      tempX = tempX + (buffer[i].xAccel * coeff)
      tempY = tempY + (buffer[i].yAccel * coeff)
      tempZ = tempZ + (buffer[i].zAccel * coeff)
    }
    newPoint.xAccel = tempX
    newPoint.yAccel = tempY
    newPoint.zAccel = tempZ

    return newPoint
  }

  func calculateCoeffs(nl: Int, nr: Int, m: Int) -> [Double] {

    let ld = 0
    let np = nl + nr + 1
    var c = Array(repeating: 0.0, count: np + 2)
    let matrix = FortranMatrixOps()
    let max = 6
    var kk = 0
    var mm = 0
    var index = Array(repeating: 0, count: max+2)
    let d = 0.0
    var fac = 0.0
    var sum = 0.0
    var a = Array(repeating: Array(repeating: 0.0, count: max+2), count: max+2)
    var b = Array(repeating: 0.0, count: max+2)

    if (np < (nl+nr+1)) || (nl < 0) || (nr < 0) || (ld > m) || (m > max) || (nl + nr < m) {
      print("Invalid arguments passed into coeff calc.")
    }

    for ipj in 0...(m * 2) {  //14
      sum = 0.0
      if ipj == 0 {
        sum = 1.0
      }
      for k in 1...nr {  //11
        sum = sum + (Double(k)^^Double(ipj))
      }
      for k in 1...nl {  //12
        sum = sum + (Double((-k))^^Double(ipj))
      }
      mm = min(ipj, 2 * m - ipj)
      for imj in stride(from: -mm, to: mm+1, by: 2) {  //13
        a[1+(ipj+imj)/2][1+(ipj-imj)/2] = sum
      }
    }
    let decompOutput = matrix.luDecomposition(a: a, n: m+1, index: index, d: d)
    index = decompOutput.index
    a = decompOutput.a
    for j in 1...(m+1) {  //15
      b[j] = 0
    }
    b[ld+1] = 1
    b = matrix.luBacksubstitute(a: a, n: m+1, np: max+1, index: index, b: b)
    for kk in 1...np {  //16
      c[kk] = 0.0
    }
    for k in -nl...nr {  //18
      sum = b[1]
      fac = 1
      for mm in 1...m {  //17
        fac = fac*Double(k)
        sum = sum + b[mm+1] * fac
      }
      kk = ((np-k) % np) + 1
      c[kk] = sum
    }
    c.removeFirst()
    c.removeLast()
    let output = shift(index: nr+1, input: c)
    return output
  }

  public func shift(index: Int, input: [Double]) -> [Double] {
    var output = input[index..<input.count]
    output += input[0..<index]
    return Array(output)
  }
}
