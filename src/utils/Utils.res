@module("tailwind-merge") external twMerge: string => string = "twMerge"

let cx = (classes: array<string>) => classes->Array.filter(s => s !== "")->Array.join(" ")->twMerge

let cxOpt = (classes: array<option<string>>) =>
  classes->Array.filterMap(x => x)->Array.join(" ")->twMerge
