let cx = (classes: array<string>) => classes->Array.filter(s => s !== "")->Array.join(" ")

let cxOpt = (classes: array<option<string>>) => classes->Array.filterMap(x => x)->Array.join(" ")
