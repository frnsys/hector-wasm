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

Currently the optimized build runs into an `index out of bounds` error unless the `-s ASSERTIONS=1 -s NO_DISABLE_EXCEPTION_CATCHING` flags are included, which results in larger file sizes (about 1.1MB total; without those flags its about 600KB) and [slower execution](https://github.com/emscripten-core/emscripten/blob/main/src/settings.js#L647).

I have no idea why this error occurs unless `NO_DISABLE_EXCEPTION_CATCHING` is set...possibly related to: <https://github.com/emscripten-core/emscripten/issues/11544>?

# Performance

It takes about ~3 seconds to run once in Firefox 92.0a1 and about ~1-2 seconds on Chrome 91.0.4472.164. This is when using only one observer/output variable; more will add to the runtime.

If the above known issue can be resolved it should go faster.

# Citations

The glue C++ code is almost entirely from the excellent [`pyhector`](https://github.com/openclimatedata/pyhector) project, with minor modifications (to the namespace and return types, so that it's not using numpy datatypes).

- Hartin, C. A., Patel, P., Schwarber, A., Link, R. P., and Bond-Lamberty, B. P.: A simple object-oriented and open-source model for scientific and policy analyses of the global climate system – Hector v1.0, Geosci. Model Dev., 8, 939-955, doi:10.5194/gmd-8-939-2015, 2015.
- Willner, Sven, & Gieseke, Robert. (2019, August 6). pyhector (Version v2.4.0.0). Zenodo. http://doi.org/10.5281/zenodo.3361624
