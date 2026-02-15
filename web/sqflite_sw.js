// sqflite service worker
importScripts("sql-wasm.js");

let _sqlJs;

async function initSqlJs() {
  if (!_sqlJs) {
    _sqlJs = await initSqlJsPromise;
  }
  return _sqlJs;
}

self.addEventListener("message", function (event) {
  const data = event.data;

  if (data.type === "init") {
    initSqlJs()
      .then(() => {
        self.postMessage({
          type: "init",
          success: true,
        });
      })
      .catch((error) => {
        self.postMessage({
          type: "init",
          success: false,
          error: error.toString(),
        });
      });
  }
});
