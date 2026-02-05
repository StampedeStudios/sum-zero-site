open Vitest

let stubGlobalFetch: (string => promise<Fetch.response>) => unit = %raw(`
  function(fn) { globalThis.fetch = fn }
`)

let removeGlobalFetch: unit => unit = %raw(`
  function() { delete globalThis.fetch }
`)

let makeOkResponse: JSON.t => Fetch.response = %raw(`
  function(body) {
    return { ok: true, status: 200, statusText: "OK", json: () => Promise.resolve(body) }
  }
`)

let makeErrorResponse: (int, string) => Fetch.response = %raw(`
  function(status, statusText) {
    return { ok: false, status: status, statusText: statusText, json: () => Promise.reject(new Error("HTTP error")) }
  }
`)

let makeBadJsonResponse: unit => Fetch.response = %raw(`
  function() {
    return { ok: true, status: 200, statusText: "OK", json: () => Promise.reject(new SyntaxError("Unexpected token")) }
  }
`)

afterEach(() => {
  removeGlobalFetch()
})

describe("Fetch.fetch", () => {
  testAsync("returns Ok(response) on successful request", async t => {
    let body = JSON.Encode.object(Dict.fromArray([("key", JSON.Encode.string("value"))]))
    stubGlobalFetch(async _url => makeOkResponse(body))

    let result = await Fetch.fetch("https://example.com/api")

    switch result {
    | Ok(_response) => t->expect(true)->Expect.toBe(true)
    | Error(_) => t->expect(false)->Expect.toBe(true)
    }
  })

  testAsync("returns Error(HttpError(status)) on non-2xx response", async t => {
    stubGlobalFetch(async _url => makeErrorResponse(404, "Not Found"))

    let result = await Fetch.fetch("https://example.com/missing")

    switch result {
    | Ok(_) => t->expect(false)->Expect.toBe(true)
    | Error(HttpError(status)) => t->expect(status)->Expect.toBe(404)
    | Error(_) => t->expect(false)->Expect.toBe(true)
    }
  })

  testAsync("returns Error(HttpError) with correct status for 500", async t => {
    stubGlobalFetch(async _url => makeErrorResponse(500, "Internal Server Error"))

    let result = await Fetch.fetch("https://example.com/error")

    switch result {
    | Error(HttpError(status)) => t->expect(status)->Expect.toBe(500)
    | _ => t->expect(false)->Expect.toBe(true)
    }
  })

  testAsync("returns Error(NetworkError) when fetch throws", async t => {
    let throwingFetch: string => promise<Fetch.response> = %raw(`
      function(url) { return Promise.reject(new TypeError("Failed to fetch")) }
    `)
    stubGlobalFetch(throwingFetch)

    let result = await Fetch.fetch("https://unreachable.example.com")

    switch result {
    | Error(NetworkError(msg)) => t->expect(msg)->Expect.String.toContain("Failed to fetch")
    | _ => t->expect(false)->Expect.toBe(true)
    }
  })
})

describe("Fetch.json", () => {
  testAsync("returns Ok(json) when response body is valid JSON", async t => {
    let body = JSON.Encode.object(Dict.fromArray([("id", JSON.Encode.int(42))]))
    let response = makeOkResponse(body)

    let result = await Fetch.json(response)

    switch result {
    | Ok(json) => t->expect(json)->Expect.toEqual(body)
    | Error(_) => t->expect(false)->Expect.toBe(true)
    }
  })

  testAsync("returns Error(ParseError) when response body is invalid", async t => {
    let response = makeBadJsonResponse()

    let result = await Fetch.json(response)

    switch result {
    | Error(ParseError(msg)) => t->expect(msg)->Expect.String.toContain("Unexpected token")
    | _ => t->expect(false)->Expect.toBe(true)
    }
  })
})
