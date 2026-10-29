// 튕기기: 아무 데나 누르고 뒤로 당겼다 놓으면 파란 박스가 반대쪽으로 날아간다. 초록 목표를 맞힌다.
T.game({
  time: 45,
  reset: function () { this.ball(); this.target(); this.aim = null; },
  ball: function () { this.b = { x: 360, y: 1100, w: 90, h: 90, vx: 0, vy: 0, go: false }; },
  target: function () {
    var v = this.score >= 5 ? T.pick([-1, 1]) * (120 + this.score * 12) : 0;
    this.g = { x: T.rnd(140, 580), y: T.rnd(300, 650), w: 140, h: 140, vx: v };
  },
  step: function (dt) {
    var g = this.g, b = this.b;
    g.x += g.vx * dt;
    if (g.x < 80 || g.x > 640) { g.x = T.clamp(g.x, 80, 640); g.vx = -g.vx; }
    if (!b.go) return;
    b.x += b.vx * dt; b.y += b.vy * dt;
    var f = Math.pow(0.35, dt); b.vx *= f; b.vy *= f;
    if (b.x < 45 || b.x > 675) { b.x = T.clamp(b.x, 45, 675); b.vx = -b.vx; Kit.beep(260, 0.04, 'square', 0.12); }
    if (T.overlap(b, g)) { this.score++; Kit.sfx('good'); Kit.vibrate(15); this.ball(); this.target(); return; }
    if (b.y < -60 || b.y > 1340 || b.vx * b.vx + b.vy * b.vy < 6400) { Kit.beep(200, 0.15, 'sawtooth', 0.18, 120); this.ball(); }
  },
  paint: function (ctx) {
    T.cbox(ctx, this.g, T.C.good);
    T.cbox(ctx, this.b, T.C.me);
    var a = this.aim;
    if (a) {
      var dx = a.x0 - a.x, dy = a.y0 - a.y;
      for (var i = 1; i <= 6; i++) T.box(ctx, this.b.x + dx * 0.35 * i - 8, this.b.y + dy * 0.35 * i - 8, 16, 16, T.C.ink);
    }
  },
  tap: function (x, y) { if (!this.b.go) this.aim = { x0: x, y0: y, x: x, y: y }; },
  drag: function (x, y) { if (this.aim) { this.aim.x = x; this.aim.y = y; } },
  lift: function () {
    var a = this.aim; this.aim = null;
    if (!a) return;
    var dx = a.x0 - a.x, dy = a.y0 - a.y;
    if (dx * dx + dy * dy < 1600) return;
    this.b.vx = dx * 7; this.b.vy = dy * 7; this.b.go = true;
    Kit.beep(300, 0.12, 'triangle', 0.25, 700);
  }
});
