@react.component
let make = () => {
  open Primitives
  <>
    <h1 className="text-8xl mb-2 text-center"> {React.string("Sum Zero")} </h1>
    <h5 className="text-gray-11"> {React.string("Minimal math puzzle game")} </h5>
    <hr className="mb-8" />

    <div className="flex flex-row gap-3">
      <Button size={Lg} leadingIcon={<Icon.Download />} href="/download">
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

    <span className="text-gray-10 mt-4 text-center">
      {React.string("Available for Windows, Linux and Android")}
    </span>
  </>
}
