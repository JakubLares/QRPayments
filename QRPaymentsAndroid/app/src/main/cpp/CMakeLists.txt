# CMakeLists.txt for QRPaymentsCore JNI Bridge

cmake_minimum_required(VERSION 3.22.1)

project("qrpaymentsbridge")

# Create our JNI bridge library
add_library(qrpaymentsbridge SHARED
    swift_jni_bridge.c
)

# Import the pre-built Swift library
add_library(QRPaymentsCore SHARED IMPORTED)
set_target_properties(QRPaymentsCore PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libQRPaymentsCore.so
)

# Link against the Swift library
target_link_libraries(qrpaymentsbridge
    QRPaymentsCore
    log
)

# Include directories
target_include_directories(qrpaymentsbridge PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
