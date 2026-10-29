// node tools/smoke_test.js  -- 브라우저 없이 kit.js + game.js 가 도는지 확인한다 (플레이테스트 아님).
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const dir = path.join(__dirname, '..', 'game');
let failed = 0;
function check(name, ok, extra) {
  console.log((ok ? 'ok   ' : 'FAIL ') + name + (extra ? ' ' + extra : ''));
  if (!ok) failed++;
}

function el() {
  const h = {};
  const o = {
    style: {}, textContent: '', width: 720, height: 1280, handlers: h,
    addEventListener(n, f) { (h[n] = h[n] || []).push(f); },
    getBoundingClientRect() { return { left: 0, top: 0, width: 360, height: 640 }; },
    getContext() { calls.ctx++; return new Proxy({}, { get: (t, k) => (k in t ? t[k] : () => {}), set: (t, k, v) => { t[k] = v; return true; } }); },
  };
  return o;
}
const calls = { ctx: 0, beeps: 0 };
const canvas = el(), start = el();
const docHandlers = {};
const rafQueue = [];
let nowMs = 0;
const storageBroken = process.argv.includes('--no-storage');

const sandbox = {
  console,
  location: { search: '' },
  navigator: {},
  Promise, setTimeout, Math, JSON, Object, Array, String, Number,
  document: {
    hidden: false,
    getElementById: (id) => (id === 'stage' ? canvas : start),
    addEventListener(n, f) { (docHandlers[n] = docHandlers[n] || []).push(f); },
  },
  requestAnimationFrame: (f) => { rafQueue.push(f); return rafQueue.length; },
  performance: { now: () => nowMs },
  Image: function () { setTimeout(() => this.onload && this.onload(), 0); },
  Audio: function () { this.play = () => Promise.resolve(); this.pause = () => {}; this.setAttribute = () => {}; this.getAttribute = () => null; },
  AudioContext: function () {
    this.state = 'suspended';
    this.currentTime = 0;
    this.destination = {};
    this.resume = () => { this.state = 'running'; return Promise.resolve(); };
    this.suspend = () => { this.state = 'suspended'; };
    this.createBuffer = () => ({});
    this.createBufferSource = () => ({ connect() {}, start() {}, stop() {} });
    this.createOscillator = () => { calls.beeps++; return { type: '', frequency: { setValueAtTime() {}, exponentialRampToValueAtTime() {} }, connect() {}, start() {}, stop() {} }; };
    this.createGain = () => ({ gain: { setValueAtTime() {}, exponentialRampToValueAtTime() {}, value: 1 }, connect() {} });
  },
  fetch: undefined,
};
sandbox.window = sandbox;
sandbox.innerWidth = 390; sandbox.innerHeight = 844;
sandbox.addEventListener = () => {};
sandbox.localStorage = storageBroken
  ? { getItem() { throw new Error('blocked'); }, setItem() { throw new Error('blocked'); } }
  : (() => { const m = {}; return { getItem: (k) => (k in m ? m[k] : null), setItem: (k, v) => { m[k] = String(v); } }; })();
vm.createContext(sandbox);

const errors = [];
sandbox.console = { log() {}, warn() {}, error: (e) => errors.push(e) };

try {
  vm.runInContext(fs.readFileSync(path.join(dir, 'kit.js'), 'utf8'), sandbox, { filename: 'kit.js' });
  vm.runInContext(fs.readFileSync(path.join(dir, 'game.js'), 'utf8'), sandbox, { filename: 'game.js' });
  check('kit.js/game.js load', !!sandbox.Kit && !!sandbox.Game);
  vm.runInContext('Kit.boot(window.Game);', sandbox);
} catch (e) {
  check('boot', false, String(e));
  process.exit(1);
}

(async () => {
  await new Promise((r) => setTimeout(r, 20));
  check('start text set after load', start.textContent === '탭해서 시작', JSON.stringify(start.textContent));
  check('canvas fitted to 390x844 portrait', canvas.style.width === '390px' && canvas.style.height === '693px', canvas.style.width + 'x' + canvas.style.height);

  start.handlers.click[0]({});
  check('start overlay hidden after tap', start.style.display === 'none');
  check('audio running after tap', vm.runInContext('Kit.time', sandbox) === 0);

  function tick(n, step) {
    for (let i = 0; i < n; i++) {
      nowMs += step;
      const q = rafQueue.splice(0);
      q.forEach((f) => f(nowMs));
    }
  }
  tick(120, 16.7);
  check('game time advances', vm.runInContext('Kit.time', sandbox) > 1);
  check('dots spawned', vm.runInContext('Game.dots.length', sandbox) > 0);

  const dot = vm.runInContext('Game.dots[0]', sandbox);
  const before = vm.runInContext('Game.score', sandbox);
  // 내부 좌표 -> 화면 좌표(절반 크기 rect)
  canvas.handlers.pointerdown[0]({ preventDefault() {}, clientX: dot.x / 2, clientY: dot.y / 2 });
  check('tap on dot scores', vm.runInContext('Game.score', sandbox) === before + 1);
  check('sfx produced a beep', calls.beeps > 0, String(calls.beeps));

  tick(60 * 31, 16.7);
  check('round ends after 30s', vm.runInContext('Game.over', sandbox) === true);
  check('best saved & readable', vm.runInContext('Kit.load("best", -1)', sandbox) >= 0);

  nowMs += 10; docHandlers.visibilitychange && (sandbox.document.hidden = true, docHandlers.visibilitychange.forEach((f) => f()));
  const tBefore = vm.runInContext('Kit.time', sandbox);
  tick(30, 16.7);
  check('paused while hidden', vm.runInContext('Kit.time', sandbox) === tBefore);
  sandbox.document.hidden = false; docHandlers.visibilitychange.forEach((f) => f());
  tick(10, 16.7);
  check('resumes when visible', vm.runInContext('Kit.time', sandbox) > tBefore);

  check('no script errors', errors.length === 0, errors.map(String).join(' | '));
  console.log(failed ? '\n' + failed + ' 실패' : '\n전부 통과' + (storageBroken ? ' (저장소 차단 모드)' : ''));
  process.exit(failed ? 1 : 0);
})();
