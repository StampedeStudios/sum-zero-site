@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path {
  | list{} => <Home />
  | list{"download"} => <Download />
  | list{"about"} => <About />
  | _ => <NotFound />
  }
}
