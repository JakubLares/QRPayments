# CMakeLists.txt for QRPaymentsCore JNI Bridge

cmake_minimum_required(VERSION 3.22.1)

project("qrpaymentsbridge")

# Create our JNI bridge library
add_library(qrpaymentsbridge SHARED
    swift_jni_bridge.c
)

# Add the jniLibs directory to the library search path for build-time linking
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

# Link against the Swift library BY NAME ONLY (not absolute path)
# This allows Android's runtime linker to find it in the same directory
target_link_libraries(qrpaymentsbridge
    QRPaymentsCore
    log
)

# Include directories
target_include_directories(qrpaymentsbridge PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
