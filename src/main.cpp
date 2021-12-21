#include "Hector.h"
#include "Observable.h"
#include <emscripten/bind.h>

using namespace emscripten;

namespace wasm_hector {

EMSCRIPTEN_BINDINGS(hector) {
  // Register vector types for input/output
  // across the JS/C++ boundary
  register_vector<double>("VectorDouble");
  register_vector<std::size_t>("VectorSizeT");

  class_<Hector>("Hector")
    .constructor()
    .function("run", &Hector::run)
    .function("reset", &Hector::reset)
    .function("shutdown", &Hector::shutdown)
    .function("prepareToRun", &Hector::prepareToRun)
    .function("add_observable", &Hector::add_observable)
    .function("get_observable", &Hector::get_observable)
    .function("_set_string",
        (void (Hector::*)(const std::string&, const std::string&, const std::string&)) & Hector::set)
    .function("_set_double",
        (void (Hector::*)(const std::string&, const std::string&, double)) & Hector::set)
    .function("_set_double_unit",
        (void (Hector::*)(const std::string&, const std::string&, double, const std::string&)) & Hector::set)
    .function("_set_timed_double",
        (void (Hector::*)(const std::string&, const std::string&, std::size_t, double)) & Hector::set)
    .function("_set_timed_double_unit",
        (void (Hector::*)(const std::string&, const std::string&, std::size_t, double, const std::string&)) & Hector::set)
    .function("_set_timed_array",
        (void (Hector::*)(const std::string&, const std::string&, const std::vector<std::size_t>&, const std::vector<double>&)) & Hector::set)
    .function("_set_timed_array_unit",
        (void (Hector::*)(const std::string&, const std::string&, const std::vector<std::size_t>&, const std::vector<double>&, const std::string&)) & Hector::set)
    .class_function("version", &Hector::version)
    ;
}

}


// For catching exceptions.
// In Javascript we get a pointer to the exception,
// this gets the actual exception so we can log it.
std::string getExceptionMessage(intptr_t exceptionPtr) {
  return std::string(reinterpret_cast<std::exception *>(exceptionPtr)->what());
}
EMSCRIPTEN_BINDINGS(Bindings) {
  emscripten::function("getExceptionMessage", &getExceptionMessage);
};
