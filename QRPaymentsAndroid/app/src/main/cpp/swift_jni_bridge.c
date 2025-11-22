//
// swift_jni_bridge.c
//
// JNI wrapper that connects Kotlin external functions to Swift @_cdecl exports
//

#include <jni.h>
#include <stdlib.h>
#include <string.h>

// Swift @_cdecl function declarations
extern char* Swift_QRPaymentsCore_generateSPAYD(
    const char* prefix,
    const char* accountNumber,
    const char* bankCode,
    const char* amount,
    const char* variableSymbol,
    const char* message
);

extern char* Swift_QRPaymentsCore_convertToIBAN(
    const char* prefix,
    const char* accountNumber,
    const char* bankCode
);

// Helper function to convert jstring to C string
static const char* jstring_to_cstring(JNIEnv* env, jstring jstr) {
    if (jstr == NULL) return NULL;
    return (*env)->GetStringUTFChars(env, jstr, NULL);
}

// Helper function to release C string
static void release_cstring(JNIEnv* env, jstring jstr, const char* cstr) {
    if (jstr != NULL && cstr != NULL) {
        (*env)->ReleaseStringUTFChars(env, jstr, cstr);
    }
}

// JNI implementation for nativeGenerateSPAYD
JNIEXPORT jstring JNICALL
Java_com_qrpayments_bridge_SwiftBridge_nativeGenerateSPAYD(
    JNIEnv* env,
    jobject obj,
    jstring prefix,
    jstring accountNumber,
    jstring bankCode,
    jstring amount,
    jstring variableSymbol,
    jstring message
) {
    // Convert Java strings to C strings
    const char* c_prefix = jstring_to_cstring(env, prefix);
    const char* c_accountNumber = jstring_to_cstring(env, accountNumber);
    const char* c_bankCode = jstring_to_cstring(env, bankCode);
    const char* c_amount = jstring_to_cstring(env, amount);
    const char* c_variableSymbol = jstring_to_cstring(env, variableSymbol);
    const char* c_message = jstring_to_cstring(env, message);

    // Call Swift function
    char* result = Swift_QRPaymentsCore_generateSPAYD(
        c_prefix,
        c_accountNumber,
        c_bankCode,
        c_amount,
        c_variableSymbol,
        c_message
    );

    // Convert result to Java string
    jstring jresult = NULL;
    if (result != NULL) {
        jresult = (*env)->NewStringUTF(env, result);
        free(result); // Free the strdup'd string from Swift
    }

    // Release C strings
    release_cstring(env, prefix, c_prefix);
    release_cstring(env, accountNumber, c_accountNumber);
    release_cstring(env, bankCode, c_bankCode);
    release_cstring(env, amount, c_amount);
    release_cstring(env, variableSymbol, c_variableSymbol);
    release_cstring(env, message, c_message);

    return jresult;
}

// JNI implementation for nativeConvertToIBAN
JNIEXPORT jstring JNICALL
Java_com_qrpayments_bridge_SwiftBridge_nativeConvertToIBAN(
    JNIEnv* env,
    jobject obj,
    jstring prefix,
    jstring accountNumber,
    jstring bankCode
) {
    // Convert Java strings to C strings
    const char* c_prefix = jstring_to_cstring(env, prefix);
    const char* c_accountNumber = jstring_to_cstring(env, accountNumber);
    const char* c_bankCode = jstring_to_cstring(env, bankCode);

    // Call Swift function
    char* result = Swift_QRPaymentsCore_convertToIBAN(
        c_prefix,
        c_accountNumber,
        c_bankCode
    );

    // Convert result to Java string
    jstring jresult = NULL;
    if (result != NULL) {
        jresult = (*env)->NewStringUTF(env, result);
        free(result); // Free the strdup'd string from Swift
    }

    // Release C strings
    release_cstring(env, prefix, c_prefix);
    release_cstring(env, accountNumber, c_accountNumber);
    release_cstring(env, bankCode, c_bankCode);

    return jresult;
}
