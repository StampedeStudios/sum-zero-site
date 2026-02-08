type asset = {
  name: string,
  downloadUrl: string,
}

type release = {
  tagName: string,
  publishedAt: string,
  assets: array<asset>,
}

type state =
  | Loading
  | Loaded(release)
  | Failed(Fetch.error)

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

let fetchLatestRelease = async () => {
  switch await Fetch.fetch(
    "https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest",
  ) {
  | Ok(response) =>
    switch await response->Fetch.json {
    | Ok(json) =>
      switch Parse.release(json) {
      | Some(release) => Loaded(release)
      | None => Failed(ParseError("Invalid release format"))
      }
    | Error(err) => Failed(err)
    }
  | Error(err) => Failed(err)
  }
}

open Primitives
@react.component
let make = () => {
  let (state, setState) = React.useState(() => Loading)

  React.useEffect(() => {
    let _ = fetchLatestRelease()->Promise.thenResolve(result => setState(_ => result))
    None
  }, [])

  let loading = state == Loading

  let (tagName, publishedAt, assets) = switch state {
  | Loaded({tagName, publishedAt, assets}) => (Some(tagName), Some(publishedAt), assets)
  | _ => (None, None, [])
  }

  let downloadButtons = [
    ("Linux", <Icon.Linux width="16" height="16" />, "", "linux"),
    ("Windows", <Icon.Windows width="16" height="16" />, "Intel/AMD", "windows"),
  ]

  <div className="w-full md:w-2/3 lg:w-1/2 xl:w-1/3 mx-auto">
    <h1 className="text-lime-12 font-mono flex justify-between items-center gap-3 mb-3">
      {switch tagName {
      | Some(v) => React.string(v)
      | None => <span className="inline-block w-30 h-10 bg-lime-7 rounded animate-pulse" />
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
      | None => <span className="inline-block w-40 h-6 bg-lime-7 rounded animate-pulse" />
      }}
    </h2>
    {switch state {
    | Failed(_) => <p> {React.string("Failed to load release information.")} </p>
    | _ =>
      <ul className="flex flex-col gap-4">
        <li>
          // Android Button
          <h5 className="mb-2 text-lime-11 flex items-center gap-2 font-semibold">
            <Icon.Android width="16" height="16" />
            {React.string("Android")}
          </h5>
          <Button
            leadingIcon={<Icon.ExternalLink />}
            href="https://play.google.com/store/apps/details?id=it.stampede.sumzero"
            target={Blank}
            className="w-full"
          >
            {React.string("Open")}
          </Button>
          <Subtitle text="7.0 or later" />
        </li>
        <li>
          // Itch page
          <h5 className="mb-2 text-lime-11 flex items-center gap-2 font-semibold">
            <Icon.Itch width="16" height="16" />
            {React.string("Web")}
          </h5>
          <Button
            leadingIcon={<Icon.ExternalLink />}
            href="https://stampede-studios.itch.io/sum-zero"
            target={Blank}
            className="w-full"
          >
            {React.string("Open")}
          </Button>
        </li>
        {downloadButtons
        ->Array.map(((label, icon, subtitle, keyword)) => {
          let url = if loading {
            None
          } else {
            findAssetUrl(assets, keyword)
          }
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
              >
                {React.string("Download")}
              </Button>
            | None =>
              <Button disabled=true className="w-full"> {React.string("Loading...")} </Button>
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
    }}
  </div>
}
