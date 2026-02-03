%%raw("import './style/index.css'")

switch ReactDOM.querySelector("#root") {
| Some(domElement) =>
  GridBackground.init()
  ReactDOM.Client.createRoot(domElement)->ReactDOM.Client.Root.render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  )
| None => ()
}
