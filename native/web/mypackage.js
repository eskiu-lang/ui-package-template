// <mypackage> on the web: navigator.getBattery, as an emscripten library defining the
// externs. Module.uiEmit posts a report on the "mypackage" channel; where the browser has no
// battery API the level is unknown.
mergeInto(LibraryManager.library, {
  mypackage_start: function() {
    const report = battery => Module.uiEmit('mypackage', battery
      ? `battery ${Math.round(battery.level * 100)} ${battery.charging ? 1 : 0}` : 'battery -1 0');
    if (!navigator.getBattery) { setTimeout(() => report(null), 0); return; }
    navigator.getBattery().then(battery => {
      Module.mypackageBattery = battery;
      Module.mypackageReport = () => report(battery);
      battery.addEventListener('levelchange', Module.mypackageReport);
      battery.addEventListener('chargingchange', Module.mypackageReport);
      report(battery);
    });
  },
  mypackage_stop: function() {
    const battery = Module.mypackageBattery;
    if (!battery) return;
    battery.removeEventListener('levelchange', Module.mypackageReport);
    battery.removeEventListener('chargingchange', Module.mypackageReport);
    Module.mypackageBattery = null;
  },
});
