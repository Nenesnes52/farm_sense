# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.Interpreter
-keep class org.tensorflow.lite.InterpreterApi
-keep class org.tensorflow.lite.Delegate
-keep class org.tensorflow.lite.DelegateFactory
-keep class org.tensorflow.lite.Tensor
-keep class org.tensorflow.lite.DataType
-keep class org.tensorflow.lite.support.** { *; }
-keep interface org.tensorflow.lite.support.** { *; }

# Ini spesifik untuk error yang Anda alami (GpuDelegate)
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; } # Aturan keep untuk inner class GpuDelegate
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; } # Aturan keep yang paling penting untuk error Anda

# Tambahkan dari missing_rules.txt
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Jika Anda menggunakan TensorFlow Lite Support Library (opsional, tapi sering berguna)
-keep class org.tensorflow.lite.support.image.** { *; }
-keep class org.tensorflow.lite.support.tensorbuffer.** { *; }
-keep class org.tensorflow.lite.support.common.** { *; }
-keep class org.tensorflow.lite.support.metadata.** { *; }