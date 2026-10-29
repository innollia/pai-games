// 3줄 달리기: 화면 왼쪽/오른쪽을 탭해 줄을 바꾸고 내려오는 빨간 박스를 피한다.
var LX = [150, 360, 570];
T.game({
  reset: function () { this.lane = 1; this.p = { x: 360, y: 1060, w: 120, h: 120 }; this.obs = []; this.gap = 0.6; this.v = 560; },
  step: function (dt) {
    var p = this.p;
    p.x += (LX[this.lane] - p.x) * Math.min(1, dt * 18);
    this.v += 8 * dt;
    this.gap -= dt;
    if (this.gap <= 0) {
      this.gap = Math.max(0.32, 0.85 - this.score * 0.008);
      var free = (Math.random() * 3) | 0, others = [0, 1, 2].filter(function (k) { return k !== free; });
      if (Math.random() < 0.5) others.reverse();
      var n = Math.random() < 0.35 ? 2 : 1;
      for (var k = 0; k < n; k++) this.obs.push({ x: LX[others[k]], y: -60, w: 170, h: 90 });
    }
    for (var i = this.obs.length - 1; i >= 0; i--) {
      var o = this.obs[i];
      o.y += this.v * dt;
      if (T.overlap(o, p)) { this.end(); return; }
      if (o.y > 1360) { this.obs.splice(i, 1); this.score++; }
    }
  },
  paint: function (ctx) {
    for (var k = 0; k < 3; k++) T.box(ctx, LX[k] - 95, 0, 190, 1280, T.C.soft);
    for (var i = 0; i < this.obs.length; i++) T.cbox(ctx, this.obs[i], T.C.bad);
    T.cbox(ctx, this.p, T.C.me);
  },
  tap: function (x) {
    var n = this.lane + (x < 360 ? -1 : 1);
    if (n >= 0 && n <= 2) { this.lane = n; Kit.beep(480, 0.05, 'square', 0.15); }
  }
});
