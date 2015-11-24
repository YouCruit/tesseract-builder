#!/bin/bash -eux

leptonica_version="1.72"
tesseract_version="3.04.00"
tesseract_languages=(swe eng dan nor)
build_dir="$base_dir/build"
output_dir="$base_dir/output"
artifact="$base_dir/tesseract_${tesseract_version}.tgz"


function compile() {
    mkdir -p "$output_dir"
    mkdir -p "$build_dir"

    # Build dependencies
    if ! [ -f "${output_dir}/lib/liblept.so" ]; then
    (
        cd "$build_dir"
        wget -O- -nv http://www.leptonica.org/source/leptonica-${leptonica_version}.tar.gz | tar zx
        cd leptonica-${leptonica_version}
        ./configure --prefix="${output_dir}"
        make -j4
        make install
    )
    fi

    # Build tesseract
    if ! [ -f "${output_dir}/bin/tesseract" ]; then
    (
        cd "$build_dir"
        export CPPFLAGS="-I${output_dir}/include"
        export LDFLAGS="-L${output_dir}/lib"
        git clone --single-branch --branch ${tesseract_version} --depth 1 https://github.com/tesseract-ocr/tesseract tesseract
        cd tesseract
        export LIBLEPT_HEADERSDIR="${output_dir}/include"
        ./configure --prefix="${output_dir}"
        make -j4
        make install
    )
    fi

    (
        cd "$build_dir"
        if [ -d tessdata ]; then
            cd tessdata
            git fetch
            git checkout --detach "${tesseract_version}"
        else
            if [[ "${TESSDATA_LOCAL_MIRROR+x}" != "" ]]; then
                git clone --branch ${tesseract_version} "${TESSDATA_LOCAL_MIRROR}" tessdata
            else
                git clone --single-branch --branch ${tesseract_version} --depth 1 https://github.com/tesseract-ocr/tessdata tessdata
            fi
            cd tessdata
        fi
        tessdata="${output_dir}/share/tessdata/"
        mkdir -p "$tessdata"
        for lang in "${tesseract_languages[@]}"; do
            cp -v "${lang}"* "$tessdata"
        done
    )
    # Strip
    strip "$output_dir/bin/"*
    rm -rf "$output_dir/lib/"*.a "$output_dir/lib/"*.la "$output_dir/"lib/pkgconfig/ "$output_dir/"include "$output_dir/"share/man
}


if ! gcc -v 2>&1 | grep -F "Target: x86_64-linux-gnu"; then
    echo "Only accepting x64 build environment"
    exit 1
fi


compile

