type response

type error =
  | NetworkError(string)
  | HttpError(int)
  | ParseError(string)

type headers = Dict.t<string>
type requestInit = {headers: headers}
@val external _fetch: string => promise<response> = "fetch"
@val external _fetchWithInit: (string, requestInit) => promise<response> = "fetch"
@send external _json: response => promise<JSON.t> = "json"
@get external _ok: response => bool = "ok"
@get external _status: response => int = "status"
@get external _statusText: response => string = "statusText"

let fetch = async (url: string, ~headers: option<headers>=?): result<response, error> => {
  try {
    let response = switch headers {
    | Some(h) => await _fetchWithInit(url, {headers: h})
    | None => await _fetch(url)
    }
    if response->_ok {
      Ok(response)
    } else {
      let status = response->_status
      Console.error2(
        `[Fetch] HTTP ${response->_status->Int.toString} ${response->_statusText}:`,
        url,
      )
      Error(HttpError(status))
    }
  } catch {
  | exn =>
    let message = switch exn {
    | JsExn(err) => err->JsExn.message->Option.getOr("Unknown error")
    | _ => "Unknown error"
    }
    Console.error2(`[Fetch] Network error: ${message}`, url)
    Error(NetworkError(message))
  }
}

let json = async (response: response): result<JSON.t, error> => {
  try {
    let json = await response->_json
    Ok(json)
  } catch {
  | exn =>
    let message = switch exn {
    | JsExn(err) => err->JsExn.message->Option.getOr("Unknown error")
    | _ => "Unknown error"
    }
    Console.error(`[Fetch] JSON parse error: ${message}`)
    Error(ParseError(message))
  }
}
