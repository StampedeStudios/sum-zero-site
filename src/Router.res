type route = Home | About | NotFound

let fromUrl = (url: RescriptReactRouter.url) =>
  switch url.path {
  | list{} => Home
  | list{"about"} => About
  | _ => NotFound
  }

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path {
  | list{} => <Home />
  | list{"about"} => <About />
  | _ => <NotFound />
  }
}
