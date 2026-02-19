const btn = document.querySelector("[data-back-to-top]");

globalThis.addEventListener("scroll", () => {
  btn.style.opacity = globalThis.scrollY > 300 ? "1" : "0";
});
