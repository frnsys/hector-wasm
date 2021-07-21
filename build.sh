#!/bin/bash
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

mkdir -p build
if [ "$DEBUG" = true ]; then
    # https://emscripten.org/docs/porting/Debugging.html
    echo "Compiling debug..."
    EMCC_DEBUG=1 em++ --std=c++14 -Iinclude/ -Ihector/inst/include/ -DNO_LOGGING --bind --no-entry -g -s ASSERTIONS=1 -s NO_DISABLE_EXCEPTION_CATCHING -s LLD_REPORT_UNDEFINED -s ALLOW_MEMORY_GROWTH=1 -s USE_BOOST_HEADERS=1 -s WASM=1 -o build/hector.js "${sources[@]}"
else
    echo "Compiling..."
    em++ --std=c++14 -Iinclude/ -Ihector/inst/include/ -DNO_LOGGING --bind --no-entry -O3 -flto -s EXCEPTION_CATCHING_ALLOWED=["_ZN6Hector17CarbonCycleSolver3runEd"] -s ALLOW_MEMORY_GROWTH=1 -s USE_BOOST_HEADERS=1 -s WASM=1 -o build/hector.js "${sources[@]}"
fi
echo "Done."