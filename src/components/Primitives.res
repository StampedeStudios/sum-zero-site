type variant = Solid | Soft | Outline
type size = Sm | Md | Lg
type color = Accent | Danger
type target = Blank | Self | Parent | Top
module Button = {
  @react.component
  let make = (
    ~variant: variant=Solid,
    ~color: color=Accent,
    ~size: size=Md,
    ~href: option<string>=?,
    ~target: option<target>=?,
    ~leadingIcon: option<React.element>=?,
    ~trailingIcon: option<React.element>=?,
    ~children,
    ~className: option<string>=?,
    ~disabled=false,
    ~onClick: option<ReactEvent.Mouse.t => unit>=?,
    ~ariaLabel: option<string>=?,
  ) => {
    let colorClass = switch color {
    | Accent => "color-accent"
    | Danger => "color-danger"
    }

    let variantClass = switch variant {
    | Solid => "[background-color:var(--btn-9)] hover:[background-color:var(--btn-10)] [color:var(--btn-contrast)] [border-color:var(--btn-8)] [box-shadow:0_3px_0_var(--btn-8)] active:not-disabled:[box-shadow:none] active:not-disabled:translate-y-[3px] focus-visible:[box-shadow:none] transition-all duration-150"
    | Soft => "[background-color:var(--btn-3)] hover:[background-color:var(--btn-4)] [color:var(--btn-11)] border-transparent active:not-disabled:translate-y-[3px] transition-transform duration-150"
    | Outline => "[background-color:var(--btn-1)] text-gray-11 hover:[background-color:var(--btn-2)] [color:var(--btn-11)] [border-color:var(--btn-7)] hover:[border-color:var(--btn-8)] active:not-disabled:translate-y-[3px] transition-transform duration-150"
    }

    let hasLeading = leadingIcon->Option.isSome
    let hasTrailing = trailingIcon->Option.isSome

    let sizeClass = switch (size, hasLeading, hasTrailing) {
    | (Sm, true, _) => "h-7 pl-1.5 pr-2 text-xs gap-1"
    | (Sm, _, true) => "h-7 pl-2 pr-1.5 text-xs gap-1"
    | (Sm, _, _) => "h-7 px-2 text-xs gap-1"
    | (Md, true, _) => "h-9 pl-2 pr-3 text-sm gap-1.5"
    | (Md, _, true) => "h-9 pl-3 pr-2 text-sm gap-1.5"
    | (Md, _, _) => "h-9 pl-2.5 pr-3 text-sm gap-1.5"
    | (Lg, true, _) => "h-11 pl-3 pr-4 text-base gap-2"
    | (Lg, _, true) => "h-11 pl-4 pr-3 text-base gap-2"
    | (Lg, _, _) => "h-11 px-4 text-base gap-2"
    }

    let className = Utils.cx([
      colorClass,
      variantClass,
      sizeClass,
      "group select-none tracking-tight rounded-sm inline-flex items-center justify-center text-nowrap border disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none focus-visible:outline-3 focus-visible:outline-lime-8 focus-visible:outline-offset-3",
      className->Option.getOr(""),
    ])

    let content =
      <>
        {switch leadingIcon {
        | Some(icon) => icon
        | None => React.null
        }}
        children
        {switch trailingIcon {
        | Some(icon) => icon
        | None => React.null
        }}
      </>

    let isExternal = switch (href, target) {
    | (Some(h), _) if String.startsWith(h, "http") => true
    | (_, Some(_)) => true
    | _ => false
    }

    switch href {
    | Some(href) if !isExternal =>
      <a
        className={className}
        href={"#" ++ href}
        ?ariaLabel
        onClick={e => {
          ReactEvent.Mouse.preventDefault(e)
          Navigation.push(href)
        }}
      >
        content
      </a>
    | Some(href) =>
      let target = target->Option.map(t =>
        switch t {
        | Blank => "_blank"
        | Self => "_self"
        | Parent => "_parent"
        | Top => "_top"
        }
      )
      <a className={className} href={href} ?target ?ariaLabel> content </a>
    | None =>
      <button className={className} disabled={disabled} ?onClick ?ariaLabel> content </button>
    }
  }
}
