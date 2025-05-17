# ffmpeg-android-minimal

---

**Minimal FFmpeg `.so` builds for Android**, focused on audio file conversion — with support for both **4 KB** and **16 KB** memory page-size devices.

> 🎯 Designed to be simple, fast, and extendable. Start with audio, scale to video, tagging, or streaming later.

---

## 🚀 Features

- ✅ Converts audio formats (e.g., `.webm` → `.mp3`)  
- ✅ Native `.so` libraries for Android (`arm64-v8a`, `armeabi-v7a`, etc.)  
- ✅ Built with support for both **4 KB and 16 KB** paging (Android compatibility)  
- ✅ GitHub Actions workflow — no local build needed  
- ✅ Easy to include in any Android app  

---

## 📦 Included Libraries

This repository builds and exports the following minimal FFmpeg shared libraries:

- `libavcodec.so`  
- `libavformat.so`  
- `libavutil.so`  
- *(optional: `libffmpeg_bridge.so` if JNI wrapper is used)*  

---

## 🛠️ How the `.so` Files Are Built

We use GitHub Actions to build FFmpeg for Android using the Android NDK and Linux cross-compilation tools.

### Build Highlights

- Targets Android API 24+  
- Includes only essential FFmpeg components (audio codecs & muxers)  
- Adds linker flag `-Wl,-z,max-page-size=16384` for 16 KB page-size compatibility  

### Folder Layout After Build

```text
artifacts/
└── ffmpeg-libs/
    └── arm64-v8a/
        ├── libavcodec.so
        ├── libavformat.so
        ├── libavutil.so
````

> You can download the `.so` files directly from the GitHub Actions **Artifacts** section after a build completes.

---

## 📲 How to Use in Your Android Project

1. **Copy `.so` files** into your app module:

   ```
   app/src/main/jniLibs/arm64-v8a/
   ```

   *(Repeat for other ABIs like `armeabi-v7a` if needed)*

2. **Create a `jniLibs` directory** if it doesn’t exist:

   ```
   mkdir -p app/src/main/jniLibs/arm64-v8a
   ```

3. **Load libraries** in your Kotlin or Java code:

   ```kotlin
   System.loadLibrary("avutil")
   System.loadLibrary("avformat")
   System.loadLibrary("avcodec")
   ```

4. **(Optional)** Use a JNI wrapper if included (e.g., `libffmpeg_bridge.so`) to call FFmpeg functionality directly.

5. **Build your app** as usual. The `.so` files will be bundled and accessible on device.

---

## 🌱 Planned Features

* [x] Minimal audio conversion support
* [ ] JNI wrapper for direct FFmpeg API use
* [ ] Tagging metadata support (ID3, FLAC, etc.)
* [ ] Video conversion support
* [ ] Prebuilt `.so` releases

---

## 🤖 Built with Help from AI

This project was created and iteratively refined with the help of AI, assisting in:

* NDK configuration
* Paging compatibility (4 KB and 16 KB)
* Build optimization
* Clean automation & documentation

---

## 📄 License

This repository includes only custom build scripts and automation helpers.

* **FFmpeg itself is not included.**
* You must comply with FFmpeg’s own license terms, which are:

  * **LGPL** by default
  * **GPL** if you enable specific features during build

🔗 See: [https://ffmpeg.org/legal.html](https://ffmpeg.org/legal.html)

---

## 🙌 Contributions Welcome

Want to improve the build process, add more codecs, or expand compatibility?

Feel free to open an issue or submit a pull request!

