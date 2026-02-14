%%raw("import './style/index.css'")

@get external innerHTML: Dom.element => string = "innerHTML"

switch ReactDOM.querySelector("#root") {
| Some(domElement) =>
  let app =
    <React.StrictMode>
      <App />
    </React.StrictMode>
  // Production builds pre-render HTML into #root (see scripts/prerender.mjs),
  // so we hydrate to attach event handlers to the existing DOM.
  // In dev mode #root is empty, so we use createRoot for a fresh render.
  if domElement->innerHTML->String.length > 0 {
    ReactDOM.Client.hydrateRoot(domElement, app)->ignore
  } else {
    ReactDOM.Client.createRoot(domElement)->ReactDOM.Client.Root.render(app)
  }
| None => ()
}
