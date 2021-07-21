# Setup

If you don't have it, [download and setup Emscripten](https://emscripten.org/docs/getting_started/downloads.html):

```
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
```

The build script (see below) expects that the Emscripten SDK is available in `emsdk/`, so if you already have an installation, symlink it there.

Then you need to prepare the `hector` code:

```
git clone https://github.com/JGCRI/hector
cd hector
git checkout 417a174d2df2f3bbe928c0e7bccf8ca7c43bd700

# Apply a patch that effectively lets us disable logging,
# which removes the need for Boost Filesystem
git apply no_logging.patch
```

# Compiling

Just run:

```
./build.sh
```

To create a debug build:

```
DEBUG=true ./build.sh
```

# Usage

See `main.js` for an example.

# Known Issues

Currently the optimized build runs into an `index out of bounds` error unless the `-s NO_DISABLE_EXCEPTION_CATCHING` flag is included, which results in larger file sizes (about 1.1MB total; without that flag its about 600KB) and [slower execution](https://github.com/emscripten-core/emscripten/blob/main/src/settings.js#L647).

_Update: This is now fixed_:

The problem was in [this try-catch block in `CarbonCycleSolver::run`](https://github.com/JGCRI/hector/blob/73673ac230958ec8312c8a8061b9b96290e99efe/src/carbon-cycle-solver.cpp#L261):

```
try {
    using namespace boost::numeric::odeint;
    typedef runge_kutta_dopri5<std::vector<double> > error_stepper_type;
    integrate_adaptive( make_controlled<error_stepper_type>( eps_abs, eps_rel ),
             odeFunctor, c, t_start, t_target, dt, odeFunctor );
} catch( bad_derivative_exception& e ) {
    stat = e.errorFlag;
}
```

When exception catching is disabled, the program just crashes here, rather than catching the exception and moving on.

Instead of using the `-s NO_DISABLE_EXCEPTION_CATCHING`, which enables all exception catching and adds size/performance overhead everywhere, instead the `-s EXCEPTION_CATCHING_ALLOWED` flag is used to allow exceptions only for that specific method. Since it's C++ we have to get the mangled name to give to Emscripten. This is already in the `build.sh` script, but for posterity, here's how you get the name:

Compile a debug build or just a regular build but with `EMCC_DEBUG=1`. Emscripten will output intermediate files to `/tmp/emscripten_temp`. Then run:

```
/.emsdk/upstream/bin/llvm-nm /tmp/emscripten_temp/carbon-cycle-solver_5.o | grep run
```

One of those should be the `CarbonCycleSolver::run` method.

Compiled in this way the resulting total file size is about 600k (for both the `.js` and `.wasm` files total).

# Performance

From [the Emscripten documentation](https://emscripten.org/docs/optimizing/Optimizing-Code.html):

> Emscripten-compiled code can currently achieve approximately half the speed of a native build.

It takes under 1 second to run in both Firefox (92.0a1) and Chrome (91.0.4472.164) (in Chrome I hit under 500ms). This is when using only one observer/output variable; more will add to the runtime. For reference, `pyhector` (which uses Hector 2.4.0, this WASM build is using 2.5.0) with the three default observers/outputs runs in about 1.5-2 seconds (this is a very rough comparison).

About a quarter of that time is setting the scenario emissions--the overhead is probably from the conversion of JS arrays into vectors.

Before the fix for the exception issue above it took about ~3 seconds to run in Firefox and ~1.5-2 seconds in Chrome.

# File sizes

See <https://emscripten.org/docs/optimizing/Optimizing-Code.html>

# Citations

The glue C++ code is almost entirely from the excellent [`pyhector`](https://github.com/openclimatedata/pyhector) project, with minor modifications (to the namespace and return types, so that it's not using numpy datatypes).

- Hartin, C. A., Patel, P., Schwarber, A., Link, R. P., and Bond-Lamberty, B. P.: A simple object-oriented and open-source model for scientific and policy analyses of the global climate system – Hector v1.0, Geosci. Model Dev., 8, 939-955, doi:10.5194/gmd-8-939-2015, 2015.
- Willner, Sven, & Gieseke, Robert. (2019, August 6). pyhector (Version v2.4.0.0). Zenodo. http://doi.org/10.5281/zenodo.3361624
