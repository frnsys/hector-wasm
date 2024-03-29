all: install_emsdk setup build

setup:
    #!/usr/bin/env bash
    git clone https://github.com/JGCRI/hector
    cd hector
    git checkout 417a174d2df2f3bbe928c0e7bccf8ca7c43bd700

    # Apply a patch that effectively lets us disable logging,
    # which removes the need for Boost Filesystem
    cp ../no_logging.patch .
    git apply no_logging.patch

    # Remove all logging statements
    # Saves about 60KB in the compiled WASM
    sed -i 's/^.*H_LOG[^}]*//' src/*.cpp
    sed -i 's/^.*<<.*//' src/*.cpp

build:
    #!/usr/bin/env bash
    # See <https://emscripten.org/docs/tools_reference/emcc.html>
    source emsdk/emsdk_env.sh

    sources=(
    "src/main.cpp"
    "src/Hector.cpp"
    "src/Observable.cpp"
    "hector/src/bc_component.cpp"
    "hector/src/carbon-cycle-model.cpp"
    "hector/src/carbon-cycle-solver.cpp"
    "hector/src/ch4_component.cpp"
    "hector/src/core.cpp"
    "hector/src/dependency_finder.cpp"
    "hector/src/forcing_component.cpp"
    "hector/src/h_interpolator.cpp"
    "hector/src/halocarbon_component.cpp"
    "hector/src/logger.cpp"
    "hector/src/n2o_component.cpp"
    "hector/src/o3_component.cpp"
    "hector/src/oc_component.cpp"
    "hector/src/ocean_component.cpp"
    "hector/src/ocean_csys.cpp"
    "hector/src/oceanbox.cpp"
    "hector/src/oh_component.cpp"
    "hector/src/simpleNbox.cpp"
    "hector/src/slr_component.cpp"
    "hector/src/so2_component.cpp"
    "hector/src/spline_forsythe.cpp"
    "hector/src/temperature_component.cpp"
    "hector/src/unitval.cpp"
    )

    mkdir -p dist

    OPT_ARGS=()
    if [ "$DEBUG" = true ]; then
        # https://emscripten.org/docs/porting/Debugging.html
        echo "Compiling debug..."
        OPT_ARGS+=( -g )
        export EMCC_DEBUG=1
    else
        echo "Compiling..."
        OPT_ARGS+=( -O3 -flto )
    fi

    em++ --std=c++14 \
        -Iinclude/ -Ihector/inst/include/ \
        -DNO_LOGGING \
        --bind --no-entry \
        "${OPT_ARGS[@]}" \
        -s EXCEPTION_CATCHING_ALLOWED=["_ZN6Hector17CarbonCycleSolver3runEd"] \
        -s ALLOW_MEMORY_GROWTH=1 \
        -s MALLOC=emmalloc \
        -s USE_BOOST_HEADERS=1 \
        -s FILESYSTEM=0 \
        -s WASM=1 \
        -s MODULARIZE=1 \
        -s EXPORT_ES6=1 \
        -s USE_ES6_IMPORT_META=1 \
        -s ENVIRONMENT='web' \
        -o dist/hector.js "${sources[@]}"

    echo "Done."

install_emsdk:
    git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk && ./emsdk install latest && ./emsdk activate latest
