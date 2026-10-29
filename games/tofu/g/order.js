// 순서: 1부터 차례로 탭한다. 다 누르면 하나 더 많은 판이 나온다. 틀리면 -2초.
T.game({
  time: 40,
  reset: function () { this.n = 4; this.deal(); },
  deal: function () {
    var spots = [], i, j, s;
    for (var r = 0; r < 5; r++) for (var c = 0; c < 4; c++) spots.push({ x: 120 + c * 160, y: 380 + r * 170 });
    for (i = spots.length - 1; i > 0; i--) { j = (Math.random() * (i + 1)) | 0; s = spots[i]; spots[i] = spots[j]; spots[j] = s; }
    this.bs = [];
    for (i = 0; i < this.n; i++) this.bs.push({ x: spots[i].x, y: spots[i].y, w: 130, h: 130, k: i + 1, done: false });
    this.want = 1;
  },
  paint: function (ctx) {
    for (var i = 0; i < this.bs.length; i++) {
      var b = this.bs[i];
      if (b.done) continue;
      T.cbox(ctx, b, T.C.b);
      T.text(ctx, b.k, b.x, b.y, 64, '#ffffff');
    }
  },
  tap: function (x, y) {
    for (var i = 0; i < this.bs.length; i++) {
      var b = this.bs[i];
      if (b.done || !T.inside(b, x, y, 12)) continue;
      if (b.k !== this.want) { Kit.sfx('bad'); Kit.vibrate(30); this.t = Math.max(0.01, this.t - 2); return; }
      b.done = true; this.want++; this.score++;
      Kit.beep(400 + b.k * 60, 0.08, 'triangle', 0.25);
      if (this.want > this.n) { Kit.sfx('win'); this.n = Math.min(12, this.n + 1); this.deal(); }
      return;
    }
  }
});
