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
    ~disabled=false,
  ) => {
    let colorClass = switch color {
    | Accent => "color-accent"
    | Danger => "color-danger"
    }

    let variantClass = switch variant {
    | Solid => "[background-color:var(--btn-9)] hover:[background-color:var(--btn-10)] [color:var(--btn-contrast)] border-transparent [box-shadow:var(--btn-11)_0_-2px_0_0_inset,_var(--btn-3)_0_1px_3px_0] hover:[box-shadow:none] active:not-disabled:[box-shadow:none]"
    | Soft => "[background-color:var(--btn-3)] hover:[background-color:var(--btn-4)] [color:var(--btn-11)] border-transparent"
    | Outline => "bg-transparent hover:[background-color:var(--btn-2)] [color:var(--btn-11)] [border-color:var(--btn-7)] hover:[border-color:var(--btn-8)]"
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
      "group select-none tracking-tight rounded-sm inline-flex items-center justify-center text-nowrap border lg:active:not-disabled:translate-y-px lg:active:not-disabled:scale-[.99] disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none",
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

    switch href {
    | Some(href) =>
      let target = target->Option.map(t =>
        switch t {
        | Blank => "_blank"
        | Self => "_self"
        | Parent => "_parent"
        | Top => "_top"
        }
      )
      <a className={className} href={href} ?target> content </a>
    | None => <button className={className} disabled={disabled}> content </button>
    }
  }
}
