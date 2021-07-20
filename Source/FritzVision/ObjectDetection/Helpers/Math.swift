import Accelerate
import Foundation

enum Math {
  static func add(_ x: UnsafeMutablePointer<Double>, _ y: Double, _ count: Int) {
    var y = y
    vDSP_vsaddD(x, 1, &y, x, 1, vDSP_Length(count))
  }

  static func exp(_ x: UnsafeMutablePointer<Double>, _ count: Int) {
    var cnt = Int32(count)
    vvexp(x, x, &cnt)
  }

  static func negate(_ x: UnsafeMutablePointer<Double>, _ count: Int) {
    vDSP_vnegD(x, 1, x, 1, vDSP_Length(count))
  }

  static func reciprocal(_ x: UnsafeMutablePointer<Double>, _ count: Int) {
    var cnt = Int32(count)
    vvrec(x, x, &cnt)
  }

  // Logistic sigmoid: 1 / (1 + np.exp(-x))
  static func sigmoid(_ x: UnsafeMutablePointer<Double>, _ count: Int) {
    Math.negate(x, count)
    Math.exp(x, count)
    Math.add(x, 1, count)
    Math.reciprocal(x, count)
  }
}
