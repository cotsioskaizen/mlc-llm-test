Param(
    [string]$PythonVersion = "3.13",
    [string]$BuildType = "Release"
)

Write-Host "=== Building MLC-LLM Windows Wheel ==="
Write-Host "`n--- Installing Python deps ---"
pip install --upgrade pip
pip install build wheel setuptools

$configPath = "cmake/config.cmake"
@"
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
"@ | Set-Content $configPath -Encoding ASCII

if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
}
New-Item -ItemType Directory -Path "build" | Out-Null

Push-Location build

cmake .. `
    -G "Visual Studio 17 2022" `
    -A x64 `
    -DCMAKE_BUILD_TYPE=$BuildType `
    -DCMAKE_INSTALL_PREFIX=install

cmake --build . --config $BuildType --parallel

Pop-Location

$runtimeDir = "python/mlc_llm/runtime"

if (Test-Path $runtimeDir) {
    Remove-Item -Recurse -Force $runtimeDir
}
New-Item -ItemType Directory -Path $runtimeDir | Out-Null

Copy-Item "build/$BuildType/tvm_runtime.dll" "$runtimeDir/tvm_runtime.dll"

Write-Host "`n--- Building Python wheel ---"

Push-Location python
python -m build --wheel
Pop-Location

Write-Host "`n=== Build complete! ==="
Write-Host "Wheel produced at: python/dist/*.whl"
