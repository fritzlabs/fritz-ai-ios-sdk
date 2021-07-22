Fritz Swift SDK
===============

An open-source version of the Fritz AI SDK.

This SDK functions identically to the closed-source Fritz SDK with the exception
of features that make calls to the Fritz AI backend service. This version of the
SDK does not support OTA model downloads, data collection, model encryption, or
telemetry data collection.

This version of the Fritz SDK corresponded to version `7.0.1` in Cocoapods. Please
update all Podfiles to reference this version for each Fritz pod you install,
including any individual model pods.

E.g.

```
pod "Fritz", "7.0.1"
pod "Fritz/VisionPoseModel/Human/Fast", "7.0.1"
```

Minimal code changes are required, if any. Functions that previously made calls to
the Fritz AI backend service now simply return `null`.

Finally, the `CoreMLHelpers` module name has been changed to `FritzCoreMLHelpers`

```
- import CoreMLHelpers
+ import FritzCoreMLHelpers
```
