#!/bin/bash

for filename in Source/FritzVisionStyle/models/*.mlmodel; do
    echo "Compiling $filename"
    xcrun coremlc compile $filename Source/FritzVisionStyle/CompiledModels/
done
