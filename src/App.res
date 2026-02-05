@react.component
let make = () => {
  <div className="min-h-screen flex flex-col p-8">
    <main className="flex-1 flex justify-center items-center flex-col">
      <Router />
    </main>
    <footer className="pt-8 px-6 text-center text-xs md:text-sm text-gray-9 flex flex-col gap-2">
      <p> {React.string("Sum Zero is a game by Stampede Studios")} </p>
      <p>
        {React.string({
          `\u00A9 ${Int.toString(
              Date.make()->Date.getFullYear,
            )} Stampede Studios. All rights reserved.`
        })}
      </p>
    </footer>
  </div>
}
