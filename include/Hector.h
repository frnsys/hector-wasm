#include <memory>
#include <string>
#include <vector>
#include "Observable.h"
#include "core.hpp"
#include "avisitor.hpp"

namespace hector = Hector;

namespace wasm_hector {

class Hector {
  private:
    std::unique_ptr<hector::Core> core_;

  protected:
    class Visitor : hector::AVisitor {
        friend class Hector;

      protected:
        double current_date = 0;
        std::vector<Observable> observables;
        std::size_t spinup_size = 0;

      public:
        bool shouldVisit(const bool in_spinup, const double date);
        void visit(hector::Core* core);
    };

    Visitor visitor;
    inline hector::Core* core();

  public:
    static std::string version();
    void add_observable(std::string component, std::string name, bool need_date, bool in_spinup);
    std::vector<double> get_observable(const std::string& component, const std::string& name, bool in_spinup) const;
    void clear_observables();
    std::size_t run_size();
    std::size_t spinup_size() const;
    double end_date();
    double start_date();
    void run(double endDate);
    void prepareToRun();

    void shutdown();
    void reset(double resetDate);
    void set(const std::string& section, const std::string& variable, const std::string& value);
    void set(const std::string& section, const std::string& variable, double value);
    void set(const std::string& section, const std::string& variable, std::size_t year, double value);
    void set(const std::string& section, const std::string& variable, const std::size_t* years, const double* values, size_t size);
    void set(const std::string& section, const std::string& variable, const std::vector<std::size_t>& years, const std::vector<double>& values);
    void set(const std::string& section, const std::string& variable, double value, const std::string& unit);
    void set(const std::string& section, const std::string& variable, std::size_t year, double value, const std::string& unit);
    void set(const std::string& section, const std::string& variable, const std::size_t* years, const double* values, size_t size, const std::string& unit);
    void set(const std::string& section,
             const std::string& variable,
             const std::vector<std::size_t>& years,
             const std::vector<double>& values,
             const std::string& unit);
};

}  // namespace wasm_hector

