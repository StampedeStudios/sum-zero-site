let init: unit => unit = %raw(`
  function() {
    const existing = document.getElementById('grid-bg');
    if (existing) return;
    const canvas = document.createElement('canvas');
    canvas.id = 'grid-bg';
    canvas.style.cssText = 'position:fixed;inset:0;z-index:-1;pointer-events:none';
    document.body.prepend(canvas);

    const ctx = canvas.getContext('2d');
    let mouseX = -1000;
    let mouseY = -1000;
    let animId = 0;
    let cellSize = window.innerWidth < 640 ? 28 : window.innerWidth < 1024 ? 36 : 44;
    let dpr = 1;
    const mouseRadius = 100;
    const scrambleRadius = 30;
    const animDuration = 200;
    const chars = '@#%&$?!+=-~:;.,|/\\(){}[]<>^*01';
    const scrambled = {};
    const wasNear = {};
    const animating = {};
    const prevChar = {};

    function resize() {
      dpr = Math.min(window.devicePixelRatio || 1, 1);
      cellSize = window.innerWidth < 640 ? 28 : window.innerWidth < 1024 ? 36 : 44;
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      canvas.style.width = window.innerWidth + 'px';
      canvas.style.height = window.innerHeight + 'px';
    }

    function onMouseMove(e) {
      mouseX = e.clientX;
      mouseY = e.clientY;
    }

    function onMouseLeave() {
      mouseX = -1000;
      mouseY = -1000;
    }

    function edgeFalloff(x, y, w, h) {
      const cx = w / 2;
      const cy = h / 2;
      const dx = (x - cx) / cx;
      const dy = (y - cy) / cy;
      const dist = Math.sqrt(dx * dx + dy * dy);
      return Math.max(0, 1 - dist * 0.85);
    }

    function isZeroCell(cx, cy, w, h) {
      const ex = w / 2;
      const ey = h / 2;
      const ry = h * 0.40;
      const rx = ry * 0.71;
      const nx = (cx - ex) / rx;
      const ny = (cy - ey) / ry;
      const d = Math.sqrt(nx * nx + ny * ny);
      return d > 0.75 && d < 1.0;
    }

    function draw() {
      const now = performance.now();
      const w = window.innerWidth;
      const h = window.innerHeight;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const colCount = Math.ceil(w / cellSize);
      const rowCount = Math.ceil(h / cellSize);
      const offsetX = (w - colCount * cellSize) / 2;
      const offsetY = (h - rowCount * cellSize) / 2;
      const fontSize = Math.round(cellSize * 0.55 * dpr) + 'px "JetBrains Mono", monospace';

      ctx.font = fontSize;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      for (let col = 0; col <= colCount; col++) {
        for (let row = 0; row <= rowCount; row++) {
          const x = offsetX + col * cellSize;
          const y = offsetY + row * cellSize;
          const dx = x - mouseX;
          const dy = y - mouseY;
          const dist = Math.sqrt(dx * dx + dy * dy);
          const mouseFactor = Math.max(0, 1 - dist / mouseRadius);
          const edge = edgeFalloff(x, y, w, h);
          const baseAlpha = 0.06 * edge;
          const highlightAlpha = mouseFactor * 0.35 * edge;

          const px = Math.round(x * dpr) + 0.5;
          const py = Math.round(y * dpr) + 0.5;

          // zero shape characters
          if (x + cellSize <= w && y + cellSize <= h) {
            const cellCx = x + cellSize / 2;
            const cellCy = y + cellSize / 2;
            if (isZeroCell(cellCx, cellCy, w, h)) {
              const fillAlpha = 0.5 * edge;
              const key = col + ',' + row;

              if (!scrambled[key]) {
                scrambled[key] = chars[Math.floor(Math.random() * chars.length)];
              }

              const sdx = cellCx - mouseX;
              const sdy = cellCy - mouseY;
              const scrambleDist = Math.sqrt(sdx * sdx + sdy * sdy);
              const isNear = scrambleDist < scrambleRadius;
              if (isNear && !wasNear[key]) {
                prevChar[key] = scrambled[key];
                scrambled[key] = chars[Math.floor(Math.random() * chars.length)];
                animating[key] = now;
                wasNear[key] = true;
              } else if (!isNear && wasNear[key]) {
                wasNear[key] = false;
              }

              const ch = scrambled[key];
              const centerX = Math.round((x + cellSize / 2) * dpr);
              const centerY = Math.round((y + cellSize / 2) * dpr);
              const textAlpha = fillAlpha * 0.6;

              ctx.save();
              ctx.beginPath();
              ctx.rect(Math.round(x * dpr), Math.round(y * dpr), Math.round(cellSize * dpr), Math.round(cellSize * dpr));
              ctx.clip();

              if (animating[key]) {
                const aElapsed = now - animating[key];
                const t = Math.min(1, aElapsed / animDuration);
                const ease = 1 - Math.pow(1 - t, 3);
                const offset = cellSize * dpr * (1 - ease);

                ctx.fillStyle = 'rgba(148, 181, 91, ' + textAlpha + ')';
                ctx.fillText(ch, centerX, centerY - offset);

                const oldCh = prevChar[key] || ' ';
                const oldAlpha = textAlpha * (1 - t);
                ctx.fillStyle = 'rgba(148, 181, 91, ' + oldAlpha + ')';
                ctx.fillText(oldCh, centerX, centerY + cellSize * dpr * ease);

                if (t >= 1) delete animating[key];
              } else {
                ctx.fillStyle = 'rgba(148, 181, 91, ' + textAlpha + ')';
                ctx.fillText(ch, centerX, centerY);
              }

              ctx.restore();
            }
          }

          // vertical line segment
          if (y + cellSize <= h) {
            const py2 = Math.round((y + cellSize) * dpr) + 0.5;
            ctx.beginPath();
            ctx.moveTo(px, py);
            ctx.lineTo(px, py2);
            if (highlightAlpha > 0.01) {
              ctx.strokeStyle = 'rgba(148, 181, 91, ' + (baseAlpha + highlightAlpha) + ')';
            } else {
              ctx.strokeStyle = 'rgba(192, 220, 151, ' + baseAlpha + ')';
            }
            ctx.lineWidth = 1;
            ctx.stroke();
          }

          // horizontal line segment
          if (x + cellSize <= w) {
            const px2 = Math.round((x + cellSize) * dpr) + 0.5;
            ctx.beginPath();
            ctx.moveTo(px, py);
            ctx.lineTo(px2, py);
            const dx2 = (x + cellSize / 2) - mouseX;
            const dy2 = y - mouseY;
            const dist2 = Math.sqrt(dx2 * dx2 + dy2 * dy2);
            const mf2 = Math.max(0, 1 - dist2 / mouseRadius);
            const ha2 = mf2 * 0.35 * edge;
            if (ha2 > 0.01) {
              ctx.strokeStyle = 'rgba(148, 181, 91, ' + (baseAlpha + ha2) + ')';
            } else {
              ctx.strokeStyle = 'rgba(192, 220, 151, ' + baseAlpha + ')';
            }
            ctx.lineWidth = 1;
            ctx.stroke();
          }
        }
      }

      animId = requestAnimationFrame(draw);
    }

    resize();
    window.addEventListener('resize', resize);
    window.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseleave', onMouseLeave);
    animId = requestAnimationFrame(draw);
  }
`)
