// 두더지: 켜지는 칸 중 초록만 탭한다. 빨강을 탭하면 -2.
T.game({
  time: 30,
  reset: function () {
    this.cells = [];
    for (var r = 0; r < 4; r++) for (var c = 0; c < 3; c++) this.cells.push({ x: 140 + c * 220, y: 420 + r * 220, w: 190, h: 190, on: 0, red: false, hit: 0 });
    this.gap = 0;
  },
  step: function (dt) {
    var el = 30 - this.t, i, c;
    this.gap -= dt;
    if (this.gap <= 0) {
      this.gap = Math.max(0.25, 0.7 - el * 0.015);
      var free = [];
      for (i = 0; i < this.cells.length; i++) if (this.cells[i].on <= 0) free.push(this.cells[i]);
      if (free.length) { c = T.pick(free); c.on = Math.max(0.5, 1.1 - el * 0.02); c.red = Math.random() < 0.3; }
    }
    for (i = 0; i < this.cells.length; i++) { c = this.cells[i]; c.on -= dt; c.hit -= dt; }
  },
  paint: function (ctx) {
    for (var i = 0; i < this.cells.length; i++) {
      var c = this.cells[i];
      T.cbox(ctx, c, c.hit > 0 ? '#ffffff' : c.on > 0 ? (c.red ? T.C.bad : T.C.good) : T.C.soft);
    }
  },
  tap: function (x, y) {
    for (var i = 0; i < this.cells.length; i++) {
      var c = this.cells[i];
      if (c.on > 0 && T.inside(c, x, y, 10)) {
        c.on = 0; c.hit = 0.15;
        if (c.red) { this.score = Math.max(0, this.score - 2); Kit.sfx('bad'); Kit.vibrate(30); }
        else { this.score++; Kit.sfx('good'); }
        return;
      }
    }
  }
});
