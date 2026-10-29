// 타이밍: 줄어드는 박스가 검은 테두리와 같은 크기가 될 때 탭한다.
T.game({
  time: 30,
  reset: function () { this.dur = 1.6; this.s = 0; this.msg = 0; this.col = T.C.b; this.ts = 260; },
  size: function () { return 700 * (1 - this.s); },
  judge: function (err) {
    if (err <= 18) { this.score += 3; Kit.sfx('good'); this.col = T.C.good; }
    else if (err <= 50) { this.score += 1; Kit.beep(600, 0.08, 'triangle', 0.25); this.col = T.C.d; }
    else { Kit.sfx('bad'); this.col = T.C.bad; }
    this.dur = err <= 50 ? Math.max(0.6, this.dur - 0.05) : Math.min(1.6, this.dur + 0.1);
    this.msg = 0.3; this.s = 0; this.ts = T.rnd(160, 380);
  },
  step: function (dt) {
    this.s += dt / this.dur;
    if (this.s >= 1) this.judge(999);
    this.msg -= dt;
  },
  paint: function (ctx) {
    var z = this.size();
    T.box(ctx, 360 - z / 2, 700 - z / 2, z, z, this.msg > 0 ? this.col : T.C.b);
    ctx.strokeStyle = T.C.ink; ctx.lineWidth = 10;
    ctx.strokeRect(360 - this.ts / 2, 700 - this.ts / 2, this.ts, this.ts);
  },
  tap: function () { this.judge(Math.abs(this.size() - this.ts)); }
});
