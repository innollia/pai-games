// 분류: 줄지어 내려오는 박스의 맨 아래 것을, 같은 색 쪽(왼쪽 주황, 오른쪽 파랑)을 탭해 보낸다.
var SC = [T.C.a, T.C.b];
T.game({
  time: 45,
  reset: function () { this.q = []; this.fly = []; this.gap = 0; this.v = 240; this.flash = 0; },
  miss: function () { Kit.sfx('bad'); Kit.vibrate(30); this.t = Math.max(0.01, this.t - 3); this.flash = 0.25; },
  step: function (dt) {
    var el = 45 - this.t;
    this.gap -= dt;
    if (this.gap <= 0) { this.gap = Math.max(0.3, 0.9 - el * 0.015); this.q.push({ x: 360, y: 230, w: 150, h: 110, k: (Math.random() * 2) | 0 }); }
    this.v = 240 + el * 6;
    for (var i = 0; i < this.q.length; i++) this.q[i].y += this.v * dt;
    if (this.q.length && this.q[0].y > 1120) { this.q.shift(); this.miss(); }
    for (var j = this.fly.length - 1; j >= 0; j--) { var f = this.fly[j]; f.x += f.dir * 2400 * dt; if (f.x < -200 || f.x > 920) this.fly.splice(j, 1); }
    this.flash -= dt;
  },
  paint: function (ctx) {
    T.box(ctx, 0, 1180, 356, 100, SC[0]); T.box(ctx, 364, 1180, 356, 100, SC[1]);
    if (this.flash > 0) T.box(ctx, 0, 1150, 720, 24, T.C.bad);
    for (var i = 0; i < this.q.length; i++) T.cbox(ctx, this.q[i], SC[this.q[i].k]);
    for (var j = 0; j < this.fly.length; j++) T.cbox(ctx, this.fly[j], SC[this.fly[j].k]);
  },
  tap: function (x) {
    var b = this.q.shift();
    if (!b) return;
    var side = x < 360 ? 0 : 1;
    b.dir = side ? 1 : -1; this.fly.push(b);
    if (side === b.k) { this.score++; Kit.beep(side ? 720 : 560, 0.07, 'triangle', 0.28); } else this.miss();
  }
});
