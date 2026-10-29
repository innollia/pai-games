// node games/tofu/smoke.js  -- 두부게임 전부를 브라우저 없이 90초씩 무작위 탭으로 돌려 본다 (재미 확인 아님, 오류·소리·재시작만).
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const here = __dirname;
const kit = fs.readFileSync(path.join(here, '..', 'slapjam2', 'game', 'kit.js'), 'utf8');
const tofu = fs.readFileSync(path.join(here, 'tofu.js'), 'utf8');
const names = fs.readdirSync(path.join(here, 'g')).filter((f) => f.endsWith('.js')).map((f) => f.slice(0, -3));
const listed = fs.readFileSync(path.join(here, 'index.html'), 'utf8');
let failed = 0;

function run(name) {
  const errors = [], beeps = { n: 0 }, raf = [];
  let now = 0;
  function el() {
    const h = {};
    return {
      style: {}, textContent: '', handlers: h,
      addEventListener(n, f) { (h[n] = h[n] || []).push(f); },
      getBoundingClientRect() { return { left: 0, top: 0, width: 720, height: 1280 }; },
      getContext() { return new Proxy({}, { get: (t, k) => (k in t ? t[k] : () => {}), set: (t, k, v) => { t[k] = v; return true; } }); },
    };
  }
  const canvas = el(), start = el();
  const sb = {
    console: { log() {}, warn() {}, error: (e) => errors.push(String(e && e.stack || e)) },
    location: { search: '?g=' + name }, navigator: {},
    document: { hidden: false, getElementById: (id) => (id === 'stage' ? canvas : start), addEventListener() {} },
    requestAnimationFrame: (f) => raf.push(f), performance: { now: () => now },
    setTimeout: (f) => f(), Image: function () {}, Audio: function () {}, fetch: undefined,
    AudioContext: function () {
      this.state = 'suspended'; this.currentTime = 0; this.destination = {};
      this.resume = () => { this.state = 'running'; return Promise.resolve(); };
      this.createBuffer = () => ({});
      this.createBufferSource = () => ({ connect() {}, start() {} });
      this.createOscillator = () => { beeps.n++; return { frequency: { setValueAtTime() {}, exponentialRampToValueAtTime() {} }, connect() {}, start() {}, stop() {} }; };
      this.createGain = () => ({ gain: { setValueAtTime() {}, exponentialRampToValueAtTime() {} }, connect() {} });
    },
    localStorage: (() => { const m = {}; return { getItem: (k) => (k in m ? m[k] : null), setItem: (k, v) => { m[k] = String(v); } }; })(),
    innerWidth: 720, innerHeight: 1280, addEventListener() {},
  };
  sb.window = sb;
  vm.createContext(sb);
  vm.runInContext(kit, sb); vm.runInContext(tofu, sb);
  vm.runInContext(fs.readFileSync(path.join(here, 'g', name + '.js'), 'utf8'), sb, { filename: name + '.js' });
  vm.runInContext('Kit.boot(window.Game)', sb);
  return new Promise((r) => setImmediate(r)).then(() => {
    start.handlers.click[0]({});
    const ev = (n, x, y) => canvas.handlers[n][0]({ preventDefault() {}, clientX: x, clientY: y });
    let overs = 0, restarts = 0, maxScore = 0, wasOver = false, held = null;
    for (let i = 0; i < 60 * 90; i++) {
      now += 1000 / 60;
      raf.splice(0).forEach((f) => f(now));
      const G = sb.Game;
      maxScore = Math.max(maxScore, G.score);
      if (G.over && !wasOver) overs++;
      if (!G.over && wasOver) restarts++;
      wasOver = G.over;
      if (held) { held.t--; ev('pointermove', held.x + held.dx * (8 - held.t), held.y + held.dy * (8 - held.t)); if (held.t <= 0) { ev('pointerup', held.x + held.dx * 8, held.y + held.dy * 8); held = null; } }
      else if (Math.random() < 0.12) {
        held = { x: Math.random() * 720, y: 200 + Math.random() * 1080, dx: (Math.random() - 0.5) * 40, dy: (Math.random() - 0.5) * 40, t: 8 };
        ev('pointerdown', held.x, held.y);
      }
    }
    const ok = errors.length === 0 && beeps.n > 0 && listed.includes('g=' + name) && (overs === 0 || restarts > 0);
    if (!ok) failed++;
    console.log((ok ? 'ok   ' : 'FAIL ') + name.padEnd(6) + ` 소리 ${beeps.n}  끝남 ${overs}  다시 ${restarts}  무작위최고 ${maxScore}` + (errors.length ? '\n  ' + errors[0] : ''));
  });
}

(async () => {
  for (const n of names) await run(n);
  console.log(failed ? '\n' + failed + ' 실패' : '\n전부 통과 (' + names.length + '개)');
  process.exit(failed ? 1 : 0);
})();
