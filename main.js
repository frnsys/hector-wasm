import loadHector from "./lib.js";

// Log to screen
function log(msg) {
  let el = document.createElement('div');
  el.innerText = msg;
  document.body.appendChild(el);
}

let outputVars = ['temperature.Tgav'];
loadHector().then(({Hector, run}) => {
  log(`Hector version ${Hector.version()}`);

  log('Running...');
  var t0 = performance.now()
  let results = run(defaultConfig, scenario, outputVars);
  var t1 = performance.now()
  log(`Done running in ${t1 - t0}ms`);

  log('Results:');
  Object.keys(results).forEach((k) => {
    log(`> ${k}: ${results[k]}`);
  });
});
