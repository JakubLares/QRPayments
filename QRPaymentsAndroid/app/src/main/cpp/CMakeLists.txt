# CMakeLists.txt for QRPaymentsCore JNI Bridge

cmake_minimum_required(VERSION 3.22.1)

project("qrpaymentsbridge")

# Add the jniLibs directory to the library search path BEFORE creating the library
# This must come before add_library() to take effect
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

# Create our JNI bridge library
add_library(qrpaymentsbridge SHARED
    swift_jni_bridge.c
)

# Link against the Swift library BY NAME ONLY (not absolute path)
# Since we added the jniLibs directory to link_directories above,
# the linker can find libQRPaymentsCore.so at build time
# At runtime, Android's linker finds it in the same directory (lib/arm64-v8a/)
target_link_libraries(qrpaymentsbridge
    QRPaymentsCore
    log
)

# Include directories
target_include_directories(qrpaymentsbridge PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
