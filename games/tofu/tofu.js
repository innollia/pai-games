// 두부게임 공통. 사각형만 그리고, 판 시간·점수·최고점·다시하기를 맡는다.
// 게임 파일은 T.game({ time, reset, step(dt), paint(ctx), tap(x,y), drag(x,y), lift(x,y), ... }) 하나만 부른다.
// time이 있으면 시간 제한 판, 없으면 this.end()를 부를 때까지 계속된다. def 안의 this가 곧 Game이다.
(function () {
  'use strict';
  var C = { ink: '#3a2a1a', me: '#3b5bdb', good: '#37b24d', bad: '#f03e3e', a: '#ff922b', b: '#4dabf7', c: '#cc5de8', d: '#fcc419', soft: '#efe1c4' };
  var id = (location.search.match(/[?&]g=([a-z0-9_]+)/) || [])[1] || 'x';
  var T = { C: C, id: id };

  T.box = function (ctx, x, y, w, h, c) { ctx.fillStyle = c; ctx.fillRect(x, y, w, h); };
  // 가운데 기준 박스 {x, y, w, h}
  T.cbox = function (ctx, b, c) { ctx.fillStyle = c; ctx.fillRect(b.x - b.w / 2, b.y - b.h / 2, b.w, b.h); };
  T.text = function (ctx, s, x, y, size, c) {
    ctx.fillStyle = c || C.ink; ctx.font = '700 ' + size + 'px sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(String(s), x, y);
  };
  T.inside = function (b, x, y, pad) { pad = pad || 0; return Math.abs(x - b.x) <= b.w / 2 + pad && Math.abs(y - b.y) <= b.h / 2 + pad; };
  T.overlap = function (a, b) { return Math.abs(a.x - b.x) < (a.w + b.w) / 2 && Math.abs(a.y - b.y) < (a.h + b.h) / 2; };
  T.rnd = function (a, b) { return a + Math.random() * (b - a); };
  T.pick = function (arr) { return arr[(Math.random() * arr.length) | 0]; };
  T.clamp = function (v, a, b) { return v < a ? a : v > b ? b : v; };

  T.game = function (def) {
    var G = {
      init: function () { G.best = Kit.load('best_' + id, 0); G.restart(); },
      restart: function () { G.score = 0; G.over = false; G.wait = 0; G.held = false; G.t = def.time || 0; call('reset'); },
      end: function () {
        if (G.over) return;
        G.over = true; G.wait = 0.7;
        if (G.score > G.best) { G.best = G.score; Kit.save('best_' + id, G.best); }
        Kit.sfx(def.time ? 'win' : 'bad'); Kit.vibrate(40);
      },
      update: function (dt) {
        if (G.over) { G.wait -= dt; return; }
        if (def.time) { G.t -= dt; if (G.t <= 0) { G.t = 0; G.end(); return; } }
        call('step', dt);
      },
      draw: function (ctx) {
        call('paint', ctx);
        T.text(ctx, G.score, 360, 90, 88);
        if (def.time) T.text(ctx, Math.ceil(G.t), 360, 170, 44);
        if (G.over) {
          T.box(ctx, 110, 440, 500, 400, '#ffffff');
          T.text(ctx, G.score, 360, 560, 130);
          T.text(ctx, '최고 ' + G.best, 360, 680, 52);
          if (G.wait <= 0) T.text(ctx, '탭해서 다시', 360, 770, 44);
        }
      },
      down: function (x, y) {
        if (G.over) { if (G.wait <= 0) { G.restart(); Kit.sfx('tap'); } return; }
        G.held = true; call('tap', x, y);
      },
      move: function (x, y) { if (G.held && !G.over) call('drag', x, y); },
      up: function (x, y) { if (G.held) { G.held = false; if (!G.over) call('lift', x, y); } }
    };
    function call(n, a, b) { if (def[n]) def[n].call(G, a, b); }
    // def의 보조 함수(next, judge 등)도 this.이름 으로 부를 수 있게 붙인다
    for (var k in def) if (!(k in G)) G[k] = def[k];
    window.Game = G;
    return G;
  };
  window.T = T;
})();
