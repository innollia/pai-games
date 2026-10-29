// 점프: 탭하면 뛴다. 다가오는 빨간 박스를 넘는다.
var GY = 1000;
T.game({
  reset: function () { this.p = { x: 170, y: GY - 45, w: 90, h: 90, vy: 0 }; this.obs = []; this.gap = 1; this.v = 520; },
  step: function (dt) {
    var p = this.p;
    p.vy += 4200 * dt; p.y += p.vy * dt;
    if (p.y > GY - 45) { p.y = GY - 45; p.vy = 0; }
    this.v += 10 * dt;
    this.gap -= dt;
    if (this.gap <= 0) {
      var h = T.rnd(60, 160), w = T.rnd(60, 120);
      this.obs.push({ x: 800, y: GY - h / 2, w: w, h: h, done: false });
      this.gap = T.rnd(0.8, 1.6) * 560 / this.v;
    }
    for (var i = this.obs.length - 1; i >= 0; i--) {
      var o = this.obs[i];
      o.x -= this.v * dt;
      if (T.overlap(o, p)) { this.end(); return; }
      if (!o.done && o.x < p.x) { o.done = true; this.score++; Kit.beep(700, 0.06, 'triangle', 0.2); }
      if (o.x < -100) this.obs.splice(i, 1);
    }
  },
  paint: function (ctx) {
    T.box(ctx, 0, GY, 720, 280, T.C.soft);
    for (var i = 0; i < this.obs.length; i++) T.cbox(ctx, this.obs[i], T.C.bad);
    T.cbox(ctx, this.p, T.C.me);
  },
  tap: function () {
    if (this.p.y >= GY - 46) { this.p.vy = -1500; Kit.beep(380, 0.1, 'square', 0.18, 760); }
  }
});
