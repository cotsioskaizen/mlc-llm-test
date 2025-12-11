#!/usr/bin/env bash
set -e

. /opt/conda/etc/profile.d/conda.sh
echo "conda activate mlc-build" >> ~/.bashrc

if [[ "$1" == "build" ]]; then
    echo "Building the project..."
    
    cd mlc-llm-test

    mkdir -p build && cd build
    python ../cmake/gen_cmake_config.py

    cmake .. && make -j$(nproc) && cd ..
    
    python setup.py bdist_wheel
    exit 0
fi

echo "Dev mode"

if [ $# -eq 0 ]; then
    exec bash --login -i
else
    exec "$@"
fi