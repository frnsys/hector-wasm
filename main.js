import wasmHector from "./build/hector.js";

let WASM;

// Log to screen
function log(msg) {
  let el = document.createElement('div');
  el.innerText = msg;
  document.body.appendChild(el);
}

function setValue(h, section, variable, value) {
  if (Array.isArray(value)) {
    if (value.length == 2 && typeof(value[1]) == 'string') {
      h._set_double_unit(section, variable, value[0], value[1]);
    } else {
      value.forEach((v) => {
        if (v.length == 3) {
          h._set_timed_double_unit(section, variable, v[0], v[1], v[2]);
        } else {
          h._set_timed_double(section, variable, v[0], v[1]);
        }
      });
    }
  } else {
    switch (typeof(value)) {
      case 'string':
        h._set_string(section, variable, value);
        break;
      case 'number':
        h._set_double(section, variable, value);
        break;
      case 'boolean':
        h._set_double(section, variable, value ? 1.0 : 0.0);
        break;
      default:
        console.error(`Unrecognized config value type: ${value}`);
        break;
    }
  }
}

function config(h, conf) {
  Object.keys(conf).forEach((section) => {
    Object.keys(conf[section]).forEach((variable) => {
      let val = conf[section][variable];
      setValue(h, section, variable, val);
    });
  });
}

function set_emissions(h, scenario) {
  const columns = Object.keys(scenario);
  Object.keys(emissions).forEach((section) => {
    emissions[section].forEach((source) => {
      if (columns.includes(source)) {
        let yearsVec = new WASM.VectorSizeT();
        Object.keys(scenario[source]).map((v) => yearsVec.push_back(parseInt(v)));
        let valuesVec = new WASM.VectorDouble();
        Object.values(scenario[source]).forEach((v) => valuesVec.push_back(v));
        h._set_timed_array(section, source, yearsVec, valuesVec);
      }
    });
  });
}


new wasmHector().then((wasm) => {
  WASM = wasm;

  log(`Hector version ${wasm.Hector.version()}`);
  try {
    let hector = new wasm.Hector();

    var t0 = performance.now()
    config(hector, defaultConfig);
    set_emissions(hector, scenario);
    var t1 = performance.now()
    log(`Loading config and emissions done in ${t1 - t0}ms`);

    let outs = ['temperature.Tgav'];
    outs.forEach((k) => {
        hector.add_observable(
          outputs[k]["component"],
          outputs[k]["variable"],
          outputs[k]["needs_date"] || false,
          false
        )
    });
    log('Running...');
    var t2 = performance.now()
    hector.run()
    var t3 = performance.now()
    log(`Done running in ${t3 - t2}ms`);

    let results = {}
    outs.forEach((k) => {
      results[k] = hector.get_observable(
          outputs[k]["component"], outputs[k]["variable"], false
      );

      // Convert to JS array
      // TODO is there a better way?
      let arr = [];
      for (let i=0; i<results[k].size(); i++) {
        arr.push(results[k].get(i));
      }
      results[k] = arr;
    });
    console.log(results);

    hector.shutdown();

    // Need to destroy to avoid memory leaks
    hector.delete();


  } catch (exception) {
    if (typeof(exception) === 'number') {
      console.error(wasm.getExceptionMessage(exception));
    } else {
      console.error(exception);
    }
  }
});
