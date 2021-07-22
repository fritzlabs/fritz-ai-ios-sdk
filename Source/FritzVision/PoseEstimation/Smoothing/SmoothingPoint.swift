//
//  accelPoint.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 08/12/2016.
//  Copyright © 2016 Alex Gubbay. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// The software implementation below is NOT designed to be used in any situation where the failure of the algorithms code on which they rely or mathematical assumptions made therin could lead to the harm of the user or others, property or the environment. It is NOT designed to prevent silent failures or fail safe.

/// Data object representing a set of sensor readings from a single point in time.
public class SmoothingPoint {

  public var xAccel = 0.0
  public var yAccel = 0.0
  public var zAccel = 0.0
  var xGyro = 0.0
  var yGyro = 0.0
  var zGyro = 0.0
  var xMag = 0.0
  var yMag = 0.0
  var zMag = 0.0
  var count = 0

  public init(dataX: Double, dataY: Double, dataZ: Double, count: Int) {
    self.xAccel = dataX
    self.yAccel = dataY
    self.zAccel = dataZ
    self.count = count
  }

  public init() {
    self.xAccel = 0
    self.yAccel = 0
    self.zAccel = 0
    self.count = 0
  }

  /**
   Allows for dynamic runtime selction of a the axis to return.
   - parameter axis: x,y,z the axis of acceleration to return.
   - returns: The value of the axis passed in, or -100.
   */
  func getAccelAxis(axis: String) -> Double {

    switch axis {
    case "x":
      return xAccel
    case "y":
      return yAccel
    case "z":
      return zAccel
    default:
      print("cant get value, axis not valid")
      return -100
    }
  }

  /**
   Allows for dynamic runtime selction of a the axis to return.
   - parameter axis: x,y,z the axis of rotational velocity  to return.
   - returns: The value of the axis passed in, or -100.
   */
  func getGyroAxis(axis: String) -> Double {

    switch axis {
    case "x":
      return xGyro
    case "y":
      return yGyro
    case "z":
      return zGyro
    default:
      print("cant get value, axis not valid")
      return -100
    }
  }

  /**
   Allows for dynamic runtime selction of a the axis to return.
   - parameter axis: x,y,z the axis of magnetic field to return.
   - returns: The value of the axis passed in, or -100.
   */
  func getMagAxis(axis: String) -> Double {

    switch axis {
    case "x":
      return xMag
    case "y":
      return yMag
    case "z":
      return zMag
    default:
      print("cant get value, axis not valid")
      return -100
    }
  }

  /**
   Allows for dynamic runtime selction of a the axis to set.
   - parameter axis: x,y,z the axis of acceleration to set.
   - parameter data: The value to set.
   */
  func setAccelAxis(axis: String, data: Double) {

    switch axis {
    case "x":
      xAccel = data
    case "y":
      yAccel = data
    case "z":
      zAccel = data
    default:
      print("cant set value, axis not valid")
    }
  }

  /**
   Allows for dynamic runtime selction of a the axis to set.
   - parameter axis: x,y,z the axis of rotational velcoity to set.
   - parameter data: The value to set.
   */
  func setGyroAxis(axis: String, data: Double) {

    switch axis {
    case "x":
      xGyro = data
    case "y":
      yGyro = data
    case "z":
      zGyro = data
    default:
      print("cant set value, axis not valid")
    }
  }

  /**
   Allows for dynamic runtime selction of a the axis to set.
   - parameter axis: x,y,z the axis of magnetic field to set.
   - parameter data: The value to set.
   */
  func setMagAxis(axis: String, data: Double) {

    switch axis {
    case "x":
      xMag = data
    case "y":
      yMag = data
    case "z":
      zMag = data
    default:
      print("cant set value, axis not valid")
    }
  }
}
