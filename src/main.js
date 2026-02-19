const btn = document.querySelector('[data-back-to-top]')

window.addEventListener('scroll', () => {
  btn.style.opacity = window.scrollY > 300 ? '1' : '0'
})
