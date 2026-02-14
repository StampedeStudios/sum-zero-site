import { renderToString } from "react-dom/server";
import { createElement } from "react";
import { make as App } from "../src/App.res.mjs";

export function render() {
  return renderToString(createElement(App));
}
