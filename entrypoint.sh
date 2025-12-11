#!/usr/bin/env bash
set -e


. /opt/conda/etc/profile.d/conda.sh
echo "conda activate mlc-build" >> ~/.bashrc

if [[ "$1" == "build" ]]; then
    echo "Building the project..."
    
    cd mlc-llm-test

    mkdir -p build && cd build
    CONFIG_CMAKE_PATH="../cmake/config.cmake"
if [ ! -f "$CONFIG_CMAKE_PATH" ]; then
    cat > "$CONFIG_CMAKE_PATH" <<EOF
set(TVM_SOURCE_DIR 3rdparty/tvm)
set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(USE_CUDA OFF)
set(USE_CUTLASS OFF)
set(USE_CUBLAS OFF)
set(USE_ROCM OFF)
set(USE_VULKAN ON)
set(USE_METAL OFF)
set(USE_OPENCL OFF)
set(USE_OPENCL_ENABLE_HOST_PTR OFF)
EOF
fi
    
    cmake .. && make -j$(nproc) && cd ..
    
    python python/setup.py bdist_wheel
    exit 0
fi

echo "Dev mode"

if [ $# -eq 0 ]; then
    exec bash --login -i
else
    exec "$@"
fi