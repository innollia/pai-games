// Slapjam #2 kit. 게임 만들 때는 이 파일을 고치지 않는다. 게임은 game.js에만 쓴다.
(function () {
  'use strict';
  var W = 720, H = 1280;
  var cfg = { bg: '#fff4d6', maxFps: 60, startText: '탭해서 시작' };
  var Kit = { W: W, H: H, cfg: cfg, ctx: null, img: {}, snd: {}, time: 0, debug: /[?&]debug/.test(location.search) };
  window.Kit = Kit;

  // ---- 저장 (itch iframe에서는 localStorage가 막힐 수 있다 -> 메모리로 대체) ----
  var mem = {};
  Kit.save = function (key, val) {
    mem[key] = val;
    try { localStorage.setItem('slapjam2:' + key, JSON.stringify(val)); } catch (e) {}
  };
  Kit.load = function (key, def) {
    try {
      var s = localStorage.getItem('slapjam2:' + key);
      if (s !== null) return JSON.parse(s);
    } catch (e) {}
    return key in mem ? mem[key] : def;
  };

  // ---- 소리 (첫 탭 뒤에 켠다. 파일 없이도 효과음이 난다) ----
  var ac = null, music = null, musicOn = false;
  function makeAudio() {
    if (ac) return;
    try { var AC = window.AudioContext || window.webkitAudioContext; if (AC) ac = new AC(); } catch (e) { ac = null; }
  }
  function unlockAudio() {
    makeAudio();
    if (!ac) return;
    try {
      if (ac.state !== 'running') ac.resume();
      var b = ac.createBuffer(1, 1, 22050), s = ac.createBufferSource();
      s.buffer = b; s.connect(ac.destination); s.start(0);
    } catch (e) {}
  }
  // freq Hz, dur 초, type 'sine'|'square'|'triangle'|'sawtooth', vol 0~1, slide 끝 주파수(선택)
  Kit.beep = function (freq, dur, type, vol, slide) {
    if (!ac || ac.state !== 'running') return;
    try {
      var t = ac.currentTime, o = ac.createOscillator(), g = ac.createGain();
      o.type = type || 'sine';
      o.frequency.setValueAtTime(freq, t);
      if (slide) o.frequency.exponentialRampToValueAtTime(slide, t + dur);
      g.gain.setValueAtTime(vol == null ? 0.25 : vol, t);
      g.gain.exponentialRampToValueAtTime(0.001, t + dur);
      o.connect(g); g.connect(ac.destination);
      o.start(t); o.stop(t + dur + 0.02);
    } catch (e) {}
  };
  var presets = {
    tap:  function () { Kit.beep(520, 0.08, 'square', 0.18); },
    good: function () { Kit.beep(660, 0.09, 'triangle', 0.3); setTimeout(function () { Kit.beep(990, 0.14, 'triangle', 0.3); }, 70); },
    bad:  function () { Kit.beep(220, 0.25, 'sawtooth', 0.25, 90); },
    win:  function () { [523, 659, 784, 1047].forEach(function (f, i) { setTimeout(function () { Kit.beep(f, 0.18, 'triangle', 0.3); }, i * 110); }); }
  };
  Kit.sfx = function (name) { var p = presets[name]; if (p) p(); };
  // 업로드한 소리 파일 재생. Kit.play('hit') = Game.assets.sounds.hit. 짧은 효과음용.
  Kit.play = function (name, vol) {
    var buf = Kit.snd[name];
    if (!buf || !ac || ac.state !== 'running') return;
    try {
      var s = ac.createBufferSource(), g = ac.createGain();
      s.buffer = buf; g.gain.value = vol == null ? 1 : vol;
      s.connect(g); g.connect(ac.destination); s.start(0);
    } catch (e) {}
  };
  // 배경음악은 <audio>로 스트리밍한다 (디코딩해 메모리에 올리지 않음). 한 곡만.
  Kit.music = function (url, vol) {
    try {
      if (!music) { music = new Audio(); music.loop = true; music.preload = 'auto'; }
      if (music.getAttribute('data-src') !== url) { music.src = url; music.setAttribute('data-src', url); }
      music.volume = vol == null ? 0.5 : vol;
      musicOn = true;
      var p = music.play(); if (p && p.catch) p.catch(function () {});
    } catch (e) {}
  };
  Kit.stopMusic = function () { musicOn = false; if (music) { try { music.pause(); } catch (e) {} } };
  Kit.vibrate = function (ms) { try { if (navigator.vibrate) navigator.vibrate(ms || 15); } catch (e) {} };

  // ---- 에셋 로드 (실패해도 게임은 뜬다: 해당 항목이 null) ----
  function loadImage(url) {
    return new Promise(function (res) { var i = new Image(); i.onload = function () { res(i); }; i.onerror = function () { res(null); }; i.src = url; });
  }
  function loadSound(url) {
    return new Promise(function (res) {
      makeAudio();
      if (!ac || !window.fetch) return res(null);
      fetch(url).then(function (r) { return r.arrayBuffer(); })
        .then(function (a) { return new Promise(function (ok, no) { ac.decodeAudioData(a, ok, no); }); })
        .then(res, function () { res(null); });
    });
  }
  function loadAll(assets) {
    var jobs = [];
    assets = assets || {};
    Object.keys(assets.images || {}).forEach(function (k) { jobs.push(loadImage(assets.images[k]).then(function (v) { Kit.img[k] = v; })); });
    Object.keys(assets.sounds || {}).forEach(function (k) { jobs.push(loadSound(assets.sounds[k]).then(function (v) { Kit.snd[k] = v; })); });
    return Promise.all(jobs);
  }

  // ---- 화면 맞춤: 내부 720x1280 고정, CSS로만 늘린다 (느린 폰에서 픽셀 수 고정) ----
  var canvas;
  function fit() {
    var vw = window.innerWidth || W, vh = window.innerHeight || H;
    var s = Math.min(vw / W, vh / H);
    canvas.style.width = Math.floor(W * s) + 'px';
    canvas.style.height = Math.floor(H * s) + 'px';
  }
  function toGame(e) {
    var r = canvas.getBoundingClientRect();
    return { x: (e.clientX - r.left) * W / r.width, y: (e.clientY - r.top) * H / r.height };
  }

  Kit.boot = function (Game) {
    Game = Game || {};
    canvas = document.getElementById('stage');
    var startEl = document.getElementById('start');
    var ctx = canvas.getContext('2d', { alpha: false });
    Kit.ctx = ctx;
    fit();
    window.addEventListener('resize', fit);
    window.addEventListener('orientationchange', fit);
    if (window.visualViewport) window.visualViewport.addEventListener('resize', fit);

    var started = false, loaded = false, running = false, last = 0, errs = 0;
    var fpsN = 0, fpsT = 0, fpsShow = 0;

    function call(fn, a, b, c) {
      if (!fn) return;
      try { fn.call(Game, a, b, c); } catch (e) { if (errs++ < 5 && window.console) console.error(e); }
    }
    function frame(now) {
      requestAnimationFrame(frame);
      if (!running) return;
      var dtMs = now - last;
      if (dtMs < 1000 / cfg.maxFps - 2) return;
      last = now;
      var dt = Math.min(dtMs / 1000, 0.05);
      Kit.time += dt;
      call(Game.update, dt);
      ctx.fillStyle = cfg.bg; ctx.fillRect(0, 0, W, H);
      call(Game.draw, ctx);
      if (Kit.debug) {
        fpsN++; fpsT += dtMs;
        if (fpsT >= 500) { fpsShow = Math.round(fpsN * 1000 / fpsT); fpsN = 0; fpsT = 0; }
        ctx.fillStyle = '#000'; ctx.font = '28px sans-serif'; ctx.textAlign = 'left'; ctx.textBaseline = 'top';
        ctx.fillText(fpsShow + ' fps', 8, 8);
      }
    }

    function begin() {
      if (started || !loaded) return;
      started = true;
      unlockAudio();
      startEl.style.display = 'none';
      call(Game.init);
      last = performance.now();
      running = true;
    }
    function onUnlock() { unlockAudio(); begin(); }
    ['click', 'touchend', 'pointerup'].forEach(function (n) {
      startEl.addEventListener(n, onUnlock, false);
    });
    // iOS는 소리가 끊기기도 한다: 이후 어떤 탭에서도 다시 깨운다
    document.addEventListener('pointerup', function () { if (started && ac && ac.state !== 'running') unlockAudio(); }, true);

    function gate(ev, fn) {
      canvas.addEventListener(ev, function (e) {
        e.preventDefault();
        if (!running) return;
        var p = toGame(e);
        call(fn, p.x, p.y);
      }, { passive: false });
    }
    gate('pointerdown', Game.down);
    gate('pointermove', Game.move);
    gate('pointerup', Game.up);
    canvas.addEventListener('pointercancel', function (e) { e.preventDefault(); if (running) { var p = toGame(e); call(Game.up, p.x, p.y); } });
    ['gesturestart', 'contextmenu', 'dblclick'].forEach(function (n) { document.addEventListener(n, function (e) { e.preventDefault(); }, { passive: false }); });
    document.addEventListener('touchmove', function (e) { e.preventDefault(); }, { passive: false });

    // 탭이 가려지면 멈추고 소리를 끈다
    document.addEventListener('visibilitychange', function () {
      if (document.hidden) {
        running = false;
        if (ac && ac.suspend) try { ac.suspend(); } catch (e) {}
        if (music) try { music.pause(); } catch (e) {}
      } else if (started) {
        if (ac && ac.resume) try { ac.resume(); } catch (e) {}
        if (music && musicOn) try { music.play().catch(function () {}); } catch (e) {}
        last = performance.now();
        running = true;
      }
    });

    requestAnimationFrame(frame);
    loadAll(Game.assets).then(function () {
      loaded = true;
      startEl.textContent = cfg.startText;
    });
  };
})();
