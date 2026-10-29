// 맞추기: 넓어졌다 좁아졌다 하는 박스를 탭해 멈춘다. 위 벽의 틈보다 조금만 작으면 고득점, 크면 부딪힌다.
var WY = 360, WH = 80, BXH = 70;
T.game({
  time: 40,
  reset: function () { this.round(); },
  round: function () { this.gw = T.rnd(140, 520); this.w = 40; this.dw = 1; this.phase = 0; this.by = 1100; this.res = 0; this.col = T.C.me; },
  step: function (dt) {
    if (this.phase === 0) {
      this.w += this.dw * (600 + this.score * 15) * dt;
      if (this.w > 700) { this.w = 700; this.dw = -1; }
      if (this.w < 40) { this.w = 40; this.dw = 1; }
    } else if (this.phase === 1) {
      this.by -= 2600 * dt;
      var stop = this.w > this.gw ? WY + WH + BXH / 2 : 280;
      if (this.by <= stop) { this.by = stop; this.judge(); }
    } else {
      this.res -= dt;
      if (this.res <= 0) this.round();
    }
  },
  judge: function () {
    var d = this.gw - this.w;
    this.phase = 2; this.res = 0.45;
    if (d < 0) { Kit.sfx('bad'); Kit.vibrate(30); this.col = T.C.bad; this.t = Math.max(0.01, this.t - 3); }
    else if (d < 30) { this.score += 3; Kit.sfx('good'); this.col = T.C.good; }
    else if (d < 90) { this.score += 1; Kit.beep(600, 0.08, 'triangle', 0.25); this.col = T.C.d; }
    else { Kit.beep(250, 0.1, 'square', 0.15); this.col = T.C.soft; }
  },
  paint: function (ctx) {
    T.box(ctx, 0, WY, 360 - this.gw / 2, WH, T.C.ink);
    T.box(ctx, 360 + this.gw / 2, WY, 360 - this.gw / 2, WH, T.C.ink);
    T.box(ctx, 360 - this.w / 2, this.by - BXH / 2, this.w, BXH, this.col);
  },
  tap: function () { if (this.phase === 0) { this.phase = 1; Kit.beep(420, 0.06, 'square', 0.15); } }
});
