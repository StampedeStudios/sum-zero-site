type asset = {
  name: string,
  downloadUrl: string,
}

type release = {
  tagName: string,
  publishedAt: string,
  assets: array<asset>,
}

@module("../assets/release-data.json") external releaseDataRaw: Nullable.t<JSON.t> = "default"
@module("../assets/playstore-qr.svg") external playstoreQr: string = "default"

module Subtitle = {
  @react.component
  let make = (~text: string) =>
    <div className="text-gray-11 text-sm font-normal mb-2 mt-1"> {React.string(text)} </div>
}

let findAssetUrl = (assets: array<asset>, keyword: string): option<string> =>
  assets
  ->Array.find(({name}) => name->String.toLowerCase->String.includes(keyword))
  ->Option.map(({downloadUrl}) => downloadUrl)

module Parse = {
  let asset = (json: JSON.t): option<asset> => {
    json
    ->JSON.Decode.object
    ->Option.flatMap(obj => {
      let name = obj->Dict.get("name")->Option.flatMap(JSON.Decode.string)
      let url = obj->Dict.get("browser_download_url")->Option.flatMap(JSON.Decode.string)
      switch (name, url) {
      | (Some(name), Some(downloadUrl)) => Some({name, downloadUrl})
      | _ => None
      }
    })
  }

  let release = (json: JSON.t): option<release> => {
    json
    ->JSON.Decode.object
    ->Option.flatMap(obj => {
      let tagName = obj->Dict.get("tag_name")->Option.flatMap(JSON.Decode.string)
      let publishedAt = obj->Dict.get("published_at")->Option.flatMap(JSON.Decode.string)
      let assets =
        obj
        ->Dict.get("assets")
        ->Option.flatMap(JSON.Decode.array)
        ->Option.map(arr => arr->Array.filterMap(asset))
      switch (tagName, publishedAt, assets) {
      | (Some(tagName), Some(publishedAt), Some(assets)) => Some({tagName, publishedAt, assets})
      | _ => None
      }
    })
  }
}

let preloadedRelease: option<release> =
  releaseDataRaw
  ->Nullable.toOption
  ->Option.flatMap(Parse.release)

type mediaQueryList = {matches: bool}

@val external matchMedia: string => mediaQueryList = "window.matchMedia"
@send external addMqlListener: (mediaQueryList, string, unit => unit) => unit = "addEventListener"
@send
external removeMqlListener: (mediaQueryList, string, unit => unit) => unit = "removeEventListener"

let useIsDesktop = () => {
  let (isDesktop, setIsDesktop) = React.useState(() => false)

  React.useEffect0(() => {
    let mql = matchMedia("(min-width: 640px)")
    setIsDesktop(_ => mql.matches)
    let onChange = () => setIsDesktop(_ => mql.matches)
    mql->addMqlListener("change", onChange)
    Some(() => mql->removeMqlListener("change", onChange))
  })

  isDesktop
}

open Primitives
@react.component
let make = () => {
  let (tagName, publishedAt, assets) = switch preloadedRelease {
  | Some({tagName, publishedAt, assets}) => (Some(tagName), Some(publishedAt), assets)
  | None => (None, None, [])
  }

  let isDesktop = useIsDesktop()

  let downloadButtons = [
    ("Linux", <Icon.Linux width="16" height="16" />, "", "linux"),
    ("Windows", <Icon.Windows width="16" height="16" />, "Intel/AMD", "windows"),
  ]

  <div className="w-full md:w-2/3 mx-auto">
    <h1 className="text-lime-12 font-mono flex justify-between items-center gap-3 mb-3">
      {switch tagName {
      | Some(v) => React.string(v)
      | None => React.null
      }}
    </h1>
    <h2 className="text-lime-12 text-xl mb-6">
      {switch publishedAt {
      | Some(dateStr) => {
          let date = Date.fromString(dateStr)
          let formatted =
            Intl.DateTimeFormat.make(
              ~locales=["en-US"],
              ~options={year: #numeric, month: #long, day: #numeric},
            )->Intl.DateTimeFormat.format(date)
          React.string(formatted)
        }
      | None => React.null
      }}
    </h2>
    <ul className="flex flex-col gap-4">
      <li>
        <h5 className="mb-2 text-lime-11 flex items-center gap-2 font-semibold">
          <Icon.Android width="16" height="16" />
          {React.string("Android")}
        </h5>
        <Button
          leadingIcon={<Icon.ExternalLink />}
          href="https://play.google.com/store/apps/details?id=it.stampede.sumzero"
          target={Blank}
          className="w-full"
          ariaLabel="Open Sum Zero on Google Play (opens in new tab)"
        >
          {React.string("Open")}
        </Button>
        <details className="mt-4" open_={isDesktop}>
          <summary
            className="text-sm text-lime-11 cursor-pointer hover:text-lime-12 w-fit list-none [&::-webkit-details-marker]:hidden flex items-center gap-1"
          >
            {React.string("QR code")}
            <Icon.ChevronDown className="qr-chevron" />
          </summary>
          <div className="mt-3 flex justify-center">
            <div
              className="border-2 border-gray-6 rounded-lg bg-white w-fit p-6 flex flex-col items-center gap-3"
            >
              <img
                src={playstoreQr} alt="QR code to Sum Zero on Google Play" className="w-48 h-48"
              />
              <span className="text-xs text-gray-11">
                {React.string("Scan to open on Google Play")}
              </span>
            </div>
          </div>
        </details>
      </li>
      <Subtitle text="7.0 or later" />
      <hr className="text-gray-6" />
      <li>
        <h5 className="mb-2 text-lime-11 flex items-center gap-2 font-semibold">
          <Icon.Itch width="16" height="16" />
          {React.string("Web")}
        </h5>
        <Button
          leadingIcon={<Icon.ExternalLink />}
          href="https://stampede-studios.itch.io/sum-zero"
          target={Blank}
          className="w-full"
          ariaLabel="Play Sum Zero on itch.io (opens in new tab)"
        >
          {React.string("Open")}
        </Button>
      </li>
      {downloadButtons
      ->Array.map(((label, icon, subtitle, keyword)) => {
        let url = findAssetUrl(assets, keyword)
        <li key={label}>
          <h5 className="mb-2 text-lime-11 flex items-center gap-2 font-semibold">
            icon
            {React.string(label)}
          </h5>
          {switch url {
          | Some(url) =>
            <Button
              leadingIcon={<Icon.Download />}
              href={url}
              variant=Outline
              target={Blank}
              className="w-full"
              ariaLabel={`Download Sum Zero for ${label} (opens in new tab)`}
            >
              {React.string("Download")}
            </Button>
          | None =>
            <Button disabled=true className="w-full"> {React.string("Unavailable")} </Button>
          }}
          {if subtitle !== "" {
            <Subtitle text={subtitle} />
          } else {
            React.null
          }}
        </li>
      })
      ->React.array}
    </ul>
    <div className="flex flex-col items-center gap-3 mt-10 pt-8 border-t border-gray-6">
      <p className="text-gray-11 text-sm text-center">
        {React.string("Enjoying Sum Zero? Consider supporting the project <3!")}
      </p>
      <a
        className="focus-visible:outline-3 focus-visible:outline-lime-8 focus-visible:outline-offset-2 transition-opacity rounded-sm"
        href="https://ko-fi.com/K3K41CH2HE"
        target="_blank"
        ariaLabel="Support Sum Zero on Ko-fi (opens in new tab)"
      >
        <img
          src="https://storage.ko-fi.com/cdn/kofi6.png?v=6"
          alt="Support me on Ko-fi"
          className="h-10 hover:opacity-80"
        />
      </a>
    </div>
  </div>
}
