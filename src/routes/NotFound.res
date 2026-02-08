@react.component
let make = () => {
  open Primitives
  <div className="hero-bg min-h-screen flex flex-col justify-center items-center">
    <h1 className="text-8xl mb-2 text-center text-gray-12"> {React.string("404")} </h1>
    <h2 className="text-gray-11 text-xl font-normal mb-8"> {React.string("Page not found.")} </h2>
    <Button size=Lg leadingIcon={<Icon.ArrowLeft />} href="/">
      {React.string("Back to home")}
    </Button>
  </div>
}
