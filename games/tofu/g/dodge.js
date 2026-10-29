// 피하기: 손가락을 끌어 파란 박스를 움직이고 떨어지는 빨간 박스를 피한다. 노란 박스는 +3. 1초 버티면 +1.
T.game({
  reset: function () { this.p = { x: 360, y: 1000, w: 80, h: 80 }; this.rain = []; this.gap = 0; this.life = 0; this.sec = 0; },
  step: function (dt) {
    this.sec += dt; if (this.sec >= 1) { this.sec -= 1; this.score++; }
    this.life += dt;
    this.gap -= dt;
    if (this.gap <= 0) {
      this.gap = Math.max(0.12, 0.5 - this.life * 0.006);
      var coin = Math.random() < 0.12, s = coin ? 70 : T.rnd(50, 140);
      this.rain.push({ x: T.rnd(40, 680), y: -80, w: s, h: s, v: T.rnd(380, 620) + this.life * 6, coin: coin });
    }
    for (var i = this.rain.length - 1; i >= 0; i--) {
      var r = this.rain[i];
      r.y += r.v * dt;
      if (T.overlap(r, this.p)) {
        if (!r.coin) { this.end(); return; }
        this.score += 3; Kit.sfx('good'); this.rain.splice(i, 1); continue;
      }
      if (r.y > 1380) this.rain.splice(i, 1);
    }
  },
  paint: function (ctx) {
    for (var i = 0; i < this.rain.length; i++) T.cbox(ctx, this.rain[i], this.rain[i].coin ? T.C.d : T.C.bad);
    T.cbox(ctx, this.p, T.C.me);
  },
  // 손가락 아래가 아니라 움직인 만큼 따라온다 (손가락이 박스를 가리지 않게)
  tap: function (x, y) { this.lx = x; this.ly = y; },
  drag: function (x, y) {
    var p = this.p;
    p.x = T.clamp(p.x + (x - this.lx) * 1.2, 40, 680);
    p.y = T.clamp(p.y + (y - this.ly) * 1.2, 300, 1240);
    this.lx = x; this.ly = y;
  }
});
