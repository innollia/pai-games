// 연타 줄다리기: 화면을 마구 탭해 파란 박스를 위 초록 끝까지 끌어 올린다. 판마다 상대가 세진다.
var TOP = 300, BOT = 1150;
T.game({
  reset: function () { this.y = 700; this.pull = 110; this.cool = 0; },
  step: function (dt) {
    if (this.cool > 0) { this.cool -= dt; return; }
    this.y += (this.pull + Math.sin(Kit.time * 3) * 40) * dt;
    if (this.y <= TOP) { this.score++; Kit.sfx('win'); this.pull += 20; this.y = 700; this.cool = 0.8; }
    if (this.y >= BOT) this.end();
  },
  paint: function (ctx) {
    T.box(ctx, 300, TOP, 120, BOT - TOP, T.C.soft);
    T.box(ctx, 220, TOP - 30, 280, 30, T.C.good);
    T.box(ctx, 220, BOT, 280, 30, T.C.bad);
    T.box(ctx, 280, this.y - 40, 160, 80, this.cool > 0 ? T.C.good : T.C.me);
  },
  tap: function () {
    if (this.cool > 0) return;
    this.y -= 26;
    Kit.beep(300 + (BOT - this.y) * 0.5, 0.05, 'square', 0.15);
  }
});
