@module("../assets/basic-level.jpeg") external basicLevelImg: string = "default"
@module("../assets/rich-feature-level.jpeg") external richFeatureLevelImg: string = "default"
@module("../assets/complex-level.jpeg") external complexLevelImg: string = "default"

@val external window: Dom.element = "window"
@send external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
@send
external removeEventListener: (Dom.element, string, unit => unit) => unit = "removeEventListener"
@val external scrollY: float = "window.scrollY"
@val external innerHeight: float = "window.innerHeight"

@react.component
let make = () => {
  open Primitives

  let (showBackToTop, setShowBackToTop) = React.useState(() => true)

  React.useEffect0(() => {
    let onScroll = () => {
      setShowBackToTop(_ => scrollY > innerHeight)
    }
    onScroll()
    window->addEventListener("scroll", onScroll)
    Some(() => window->removeEventListener("scroll", onScroll))
  })

  <>
    <div
      className="hero-bg min-h-screen flex flex-col flex-1 flex justify-center items-center flex-col"
    >
      <h1
        className="text-8xl mb-2 text-center text-gray-12 flex items-center gap-6 flex-col sm:flex-row gap-10 sm:gap-6"
      >
        <img src="/sum-zero-logo.svg" alt="Sum Zero" width="64" height="64" />
        {React.string("Sum Zero")}
      </h1>
      <h2 className="text-gray-11 text-xl font-normal mb-8">
        {React.string("A minimalist math puzzle.")}
      </h2>

      <div className="flex gap-3 sm:flex-row flex-col w-full justify-center mt-4">
        <Button size={Lg} leadingIcon={<Icon.Download />} href="#download" target=Self>
          {React.string("Download")}
        </Button>

        // TODO: Add Github repo
        <Button
          variant=Outline
          size=Lg
          leadingIcon={<Icon.Github />}
          href="https://github.com/StampedeStudios/sum-zero"
          target=Blank
          ariaLabel="Source code on GitHub (opens in new tab)"
        >
          {React.string("Source code")}
        </Button>
      </div>

      <span className="text-gray-11 mt-4 text-center text-sm">
        {React.string("Available for Android, Linux and Windows")}
      </span>
    </div>
    <div className="max-w-5xl mx-auto py-24 md:py-32 flex flex-col gap-24 md:gap-32">
      // Row 1: Image left, text right
      <div className="flex flex-col md:flex-row items-center gap-10">
        <div className="w-full sm:w-4/5 md:w-1/2 shadow-image rounded-xl">
          <img src={basicLevelImg} alt="Basic level" className="w-full rounded-xl relative z-10" />
        </div>
        <div className="w-full md:w-1/2">
          <h3 className="text-2xl font-semibold text-gray-12 mb-3">
            {React.string("Simple to pick up")}
          </h3>
          <p className="text-gray-11 text-base leading-relaxed">
            {React.string(
              "Start with clean, minimal levels that teach you the basics. Tap, combine, and reach zero — it's that simple.",
            )}
          </p>
        </div>
      </div>
      // Row 2: Text left, image right
      <div className="flex flex-col md:flex-row-reverse items-center gap-10">
        <div className="w-full sm:w-4/5 md:w-1/2 shadow-image rounded-xl">
          <img
            src={richFeatureLevelImg}
            alt="Feature-rich level"
            className="w-full rounded-xl relative z-10"
          />
        </div>
        <div className="w-full md:w-1/2">
          <h3 className="text-2xl font-semibold text-gray-12 mb-3">
            {React.string("Rich mechanics")}
          </h3>
          <p className="text-gray-11 text-base leading-relaxed">
            {React.string(
              "Discover new tile types and special rules as you progress. Each mechanic adds a fresh twist to keep you thinking.",
            )}
          </p>
        </div>
      </div>
      // Row 3: Image left, text right
      <div className="flex flex-col md:flex-row items-center gap-10">
        <div className="w-full sm:w-4/5 md:w-1/2 shadow-image rounded-xl">
          <img
            src={complexLevelImg} alt="Complex level" className="w-full rounded-xl relative z-10"
          />
        </div>
        <div className="w-full md:w-1/2">
          <h3 className="text-2xl font-semibold text-gray-12 mb-3">
            {React.string("Challenging puzzles")}
          </h3>
          <p className="text-gray-11 text-base leading-relaxed">
            {React.string(
              "Push your logic to the limit with complex, multi-step puzzles that demand creative solutions.",
            )}
          </p>
        </div>
      </div>
    </div>
    <div id="download" className="max-w-5xl mx-auto pb-24 md:pb-32">
      <h2 className="text-3xl font-semibold text-gray-12 text-center mb-3">
        {React.string("Get Sum Zero")}
      </h2>
      <p className="text-gray-11 text-center mb-10">
        {React.string("Free and open source. Available on Android, Linux and Windows.")}
      </p>
      <div
        className="border-lime-8 shadow-image-sm sm:rounded-xl p-0 py-4 sm:p-8 md:p-12 sm:bg-gray-1 border-t-1"
      >
        <Download />
      </div>
    </div>
    <footer className="py-8 px-6 text-center text-xs md:text-sm text-gray-11">
      <p>
        {React.string({
          `\u00A9 ${Int.toString(
              Date.make()->Date.getFullYear,
            )} Stampede Studios. All rights reserved.`
        })}
      </p>
    </footer>
    <div
      className={`fixed top-12 right-10 z-50 transition-all duration-300 ${if showBackToTop {
          "opacity-100 translate-y-0"
        } else {
          "opacity-0 -translate-y-4 pointer-events-none"
        }}`}
      ariaHidden={!showBackToTop}
    >
      <Button
        className="backdrop-blur-xs !bg-white/70 rounded-lg"
        variant=Outline
        size=Lg
        href="#"
        target=Self
        ariaLabel="Back to top"
      >
        {React.string("top")}
      </Button>
    </div>
  </>
}
