// 여기가 게임이다. AI는 이 파일(과 assets/)만 고친다. 좌표는 720x1280, 왼쪽 위가 (0,0).
// 이 예제는 "떠오르는 동그라미 30초 터뜨리기"다. 통째로 바꿔도 된다.
window.Game = {
  // 쓸 그림/소리 파일 목록(경로는 README 참고). 그림은 Kit.img.이름, 소리는 Kit.play(이름)
  assets: { images: {}, sounds: {} },

  init: function () {
    this.best = Kit.load('best', 0);
    this.reset();
  },
  reset: function () {
    this.t = 30; this.score = 0; this.over = false; this.gap = 0; this.dots = [];
  },
  update: function (dt) {
    if (this.over) return;
    this.t -= dt;
    if (this.t <= 0) {
      this.t = 0; this.over = true;
      if (this.score > this.best) { this.best = this.score; Kit.save('best', this.best); }
      Kit.sfx('win');
      return;
    }
    this.gap -= dt;
    if (this.gap <= 0 && this.dots.length < 8) {
      this.gap = 0.55;
      this.dots.push({ x: 120 + Math.random() * 480, y: Kit.H + 90, r: 70 + Math.random() * 30, v: 150 + Math.random() * 120, c: COLORS[(Math.random() * COLORS.length) | 0] });
    }
    for (var i = this.dots.length - 1; i >= 0; i--) {
      var d = this.dots[i];
      d.y -= d.v * dt;
      if (d.y < -120) this.dots.splice(i, 1);
    }
  },
  draw: function (ctx) {
    for (var i = 0; i < this.dots.length; i++) {
      var d = this.dots[i];
      ctx.fillStyle = d.c;
      ctx.beginPath(); ctx.arc(d.x, d.y, d.r, 0, 6.2832); ctx.fill();
    }
    ctx.fillStyle = '#3a2a1a'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.font = '700 96px sans-serif';
    ctx.fillText(String(this.score), 360, 110);
    ctx.font = '700 48px sans-serif';
    ctx.fillText(String(Math.ceil(this.t)), 360, 190);
    if (this.over) {
      ctx.font = '700 120px sans-serif'; ctx.fillText(String(this.score), 360, 560);
      ctx.font = '700 56px sans-serif'; ctx.fillText('최고 ' + this.best, 360, 680);
      ctx.fillText('탭해서 다시', 360, 800);
    }
  },
  down: function (x, y) {
    if (this.over) { this.reset(); Kit.sfx('tap'); return; }
    for (var i = this.dots.length - 1; i >= 0; i--) {
      var d = this.dots[i], dx = x - d.x, dy = y - d.y, r = d.r + 24; // 손가락 여유 24px
      if (dx * dx + dy * dy <= r * r) {
        this.dots.splice(i, 1); this.score++;
        Kit.sfx('good'); Kit.vibrate(10);
        return;
      }
    }
    Kit.sfx('bad');
  }
};
var COLORS = ['#ff6b6b', '#4dabf7', '#51cf66', '#ffa94d', '#b197fc'];
