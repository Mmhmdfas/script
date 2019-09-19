#!bin/bash
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
git clone https://github.com/Haseo97/Clang-10.0.0.git -b clang-10.0.0 clang
git clone https://github.com/najahiiii/priv-toolchains.git -b non-elf/gcc-9.2.0/arm64 gcc
git clone https://github.com/najahiiii/priv-toolchains.git -b non-elf/gcc-9.2.0/arm gcc32
git clone https://github.com/Mmhmdfas/anykernel3.git
echo "Done"
GCC="$(pwd)/gcc/bin/aarch64-linux-gnu-"
GCC32="$(pwd)/gcc32/bin/arm-linux-gnueabi-"
CT="$(pwd)/clang/bin/clang"
tanggal=$(TZ=Etc/GMT-7 date +'%H%M-%d%m%y')
START=$(date +"%s")
export ARCH=arm64
export KBUILD_BUILD_USER=Mmhmdfas
export KBUILD_BUILD_HOST=LinuxClangKernel
# sticker plox
function sticker() {
        curl -s -X POST "https://api.telegram.org/bot905061652:AAHKYGa3P9xkLoCK52RjDNW8s-AEf6twhNQ/sendSticker" \
                        -d sticker="CAADBQADCAEAAn1Cwy6ay-eWBf1msRYE" \
                        -d chat_id=-1001168028608
}
# Send info plox
function sendinfo() {
        curl -s -X POST "https://api.telegram.org/bot905061652:AAHKYGa3P9xkLoCK52RjDNW8s-AEf6twhNQ/sendMessage" \
                        -d chat_id=-1001168028608 \
                        -d "disable_web_page_preview=true" \
                        -d "parse_mode=html" \
                        -d text="<b>DarkEagle</b> new build is up%0AFor device <b>ROLEX</b> (Redmi 4A)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code> (Android 9.0/Pie)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0ACompiler: <code>$(${CT} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0AStarted on <code>$(TZ=Etc/GMT-7 date)</code>%0A<b>Build Status:</b> #untested"
}
# Send private info
function sendpriv() {
        curl -s -X POST "https://api.telegram.org/bot905061652:AAHKYGa3P9xkLoCK52RjDNW8s-AEf6twhNQ/sendMessage" \
                        -d chat_id=784548477 \
                        -d "disable_web_page_preview=true" \
                        -d "parse_mode=html" \
                        -d text="DarkEagle Started%0AJob Name: DragonTC 10%0A<b>Pipeline jobs</b> <a href='${CIRCLE_BUILD_URL}'>here</a>"
}
# Push kernel to channel
function push() {
        cd anykernel3
	ZIP=$(echo dark*.zip)
	curl -F document=@$ZIP "https://api.telegram.org/bot905061652:AAHKYGa3P9xkLoCK52RjDNW8s-AEf6twhNQ/sendDocument" \
			-F chat_id="-1001168028608" \
			-F "disable_web_page_preview=true" \
			-F "parse_mode=html" \
			-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Fin Error
function finerr() {
        paste
        curl -s -X POST "https://api.telegram.org/bot905061652:AAHKYGa3P9xkLoCK52RjDNW8s-AEf6twhNQ/sendMessage" \
			-d chat_id="-1001168028608" \
			-d "disable_web_page_preview=true" \
			-d "parse_mode=markdown" \
			-d text="Build throw an error(s) | **Build logs** [here](${HASIL})"
        exit 1
}
# Compile plox
function compile() {
        make -s -C $(pwd) O=out rolex_defconfig
        make -s -C $(pwd) CC=${CT} CROSS_COMPILE_ARM32=${GCC32} CROSS_COMPILE=${GCC} O=out -j32 -l32 2>&1| tee build.log
            if ! [ -a $IMAGE ]; then
                finerr
                exit 1
            fi
        cp out/arch/arm64/boot/Image.gz-dtb anykernel3/zImage
        paste
}
# Zipping
function zipping() {
        cd anykernel3
        zip -r9 darkeagle-pie-${tanggal}.zip *
        cd ..
}
sticker
sendinfo
sendpriv
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
