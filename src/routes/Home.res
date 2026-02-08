@send external scrollIntoView: (Dom.element, {"behavior": string}) => unit = "scrollIntoView"

@react.component
let make = () => {
  open Primitives
  <>
    <div
      className="hero-bg min-h-screen flex flex-col flex-1 flex justify-center items-center flex-col"
    >
      <h1 className="text-8xl mb-2 text-center text-gray-12 flex items-center gap-6">
        <img src="/sum-zero-logo.svg" alt="Sum Zero" width="64" height="64" />
        {React.string("Sum Zero")}
      </h1>
      <h2 className="text-gray-11 text-xl font-normal mb-8">
        {React.string("A minimalist math puzzle.")}
      </h2>

      <div className="flex gap-3 sm:flex-row flex-col w-full justify-center mt-4">
        <Button
          size={Lg}
          leadingIcon={<Icon.Download />}
          onClick={_ => {
            switch ReactDOM.querySelector("#download") {
            | Some(el) => el->scrollIntoView({"behavior": "smooth"})
            | None => ()
            }
          }}
        >
          {React.string("Download")}
        </Button>

        // TODO: Add Github repo
        <Button
          variant=Outline
          size=Lg
          leadingIcon={<Icon.Github />}
          href="https://github.com/StampedeStudios/sum-zero"
          target=Blank
        >
          {React.string("Source code")}
        </Button>
      </div>

      <span className="text-gray-11 mt-4 text-center text-sm">
        {React.string("Available for Android, Linux and Windows")}
      </span>
    </div>
    <div id="download">
      <Download />
    </div>
    <div className="flex flex-col items-center gap-3 mt-14 mb-40 px-6">
      <p className="text-gray-11 text-sm text-center">
        {React.string("Enjoying Sum Zero? Consider supporting the project <3!")}
      </p>
      <a href="https://ko-fi.com/K3K41CH2HE" target="_blank">
        <img
          src="https://storage.ko-fi.com/cdn/kofi6.png?v=6"
          alt="Support me on Ko-fi"
          className="h-9 hover:opacity-80 transition-opacity"
        />
      </a>
    </div>
    <footer className="pt-8 px-6 text-center text-xs md:text-sm text-gray-11 flex flex-col gap-2">
      <p>
        {React.string({
          `\u00A9 ${Int.toString(
              Date.make()->Date.getFullYear,
            )} Stampede Studios. All rights reserved.`
        })}
      </p>
    </footer>
  </>
}
