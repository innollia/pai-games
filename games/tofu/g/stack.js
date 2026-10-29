// 쌓기: 좌우로 오가는 박스를 탭해 멈춘다. 아래 박스 밖으로 나간 부분은 잘린다.
var BH = 64, COL = [T.C.a, T.C.b, T.C.c, T.C.d];
T.game({
  reset: function () { this.tower = [{ x: 360, w: 420 }]; this.cur = { x: 210, w: 420, dir: 1 }; this.speed = 360; this.cam = 0; },
  step: function (dt) {
    var c = this.cur;
    c.x += c.dir * this.speed * dt;
    if (c.x + c.w / 2 > 720) { c.x = 720 - c.w / 2; c.dir = -1; }
    if (c.x - c.w / 2 < 0) { c.x = c.w / 2; c.dir = 1; }
    var want = Math.max(0, this.tower.length - 10) * BH;
    this.cam += (want - this.cam) * Math.min(1, dt * 8);
  },
  paint: function (ctx) {
    for (var i = 0; i <= this.tower.length; i++) {
      var b = i < this.tower.length ? this.tower[i] : this.cur;
      var y = 1200 - (i + 1) * BH + this.cam;
      if (y < 1280) T.box(ctx, b.x - b.w / 2, y, b.w, BH - 6, COL[i % 4]);
    }
  },
  tap: function () {
    var top = this.tower[this.tower.length - 1], c = this.cur;
    var l = Math.max(top.x - top.w / 2, c.x - c.w / 2), r = Math.min(top.x + top.w / 2, c.x + c.w / 2);
    if (r - l < 6) { this.end(); return; }
    var perfect = Math.abs(c.x - top.x) < 12;
    var w = perfect ? top.w : r - l, x = perfect ? top.x : (l + r) / 2;
    this.tower.push({ x: x, w: w });
    this.score += perfect ? 2 : 1;
    if (perfect) Kit.sfx('good'); else Kit.beep(300 + this.tower.length * 12, 0.08, 'square', 0.2);
    this.speed = Math.min(950, this.speed + 15);
    var left = this.tower.length % 2 === 0;
    this.cur = { x: left ? w / 2 : 720 - w / 2, w: w, dir: left ? 1 : -1 };
  }
});
