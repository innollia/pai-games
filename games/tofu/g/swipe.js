// 스와이프: 파랑이면 검은 점이 있는 쪽으로, 빨강이면 반대쪽으로 민다. 늦으면 실패.
var DIRS = [[0, -1], [1, 0], [0, 1], [-1, 0]];
T.game({
  time: 30,
  reset: function () { this.lim = 1.6; this.fb = 0; this.fc = T.C.good; this.card(); },
  card: function () { this.d = (Math.random() * 4) | 0; this.red = this.score >= 4 && Math.random() < 0.35; this.left = this.lim; },
  fail: function () { Kit.sfx('bad'); Kit.vibrate(30); this.fb = 0.25; this.fc = T.C.bad; this.card(); },
  step: function (dt) { this.left -= dt; if (this.left <= 0) this.fail(); this.fb -= dt; },
  paint: function (ctx) {
    if (this.fb > 0) T.box(ctx, 0, 1150, 720, 60, this.fc);
    T.box(ctx, 210, 550, 300, 300, this.red ? T.C.bad : T.C.b);
    T.box(ctx, 360 + DIRS[this.d][0] * 110 - 40, 700 + DIRS[this.d][1] * 110 - 40, 80, 80, T.C.ink);
    T.box(ctx, 60, 1000, 600 * Math.max(0, this.left / this.lim), 24, T.C.ink);
  },
  tap: function (x, y) { this.sx = x; this.sy = y; },
  lift: function (x, y) {
    var dx = x - this.sx, dy = y - this.sy;
    if (dx * dx + dy * dy < 80 * 80) return;
    var got = Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? 1 : 3) : (dy > 0 ? 2 : 0);
    var want = this.red ? (this.d + 2) % 4 : this.d;
    if (got !== want) { this.fail(); return; }
    this.score++; Kit.sfx('good'); this.fb = 0.2; this.fc = T.C.good;
    this.lim = Math.max(0.6, this.lim - 0.04);
    this.card();
  }
});
