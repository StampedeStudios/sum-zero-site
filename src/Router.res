let hashToPath = (hash: string) => {
  hash
  ->String.slice(~start=1, ~end=String.length(hash))
  ->String.split("/")
  ->Array.filter(s => s !== "")
  ->List.fromArray
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let path = if url.hash !== "" {
    hashToPath(url.hash)
  } else {
    list{}
  }
  switch path {
  | list{} => <Home />
  | list{"about"} => <About />
  | _ => <NotFound />
  }
}
