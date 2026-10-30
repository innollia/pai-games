// 평가·아이디어를 Firestore 에 쌓는다 (로그인 없음). Godot 은 JavaScriptBridge.eval 로 아래 window.* 를 부른다.
// JavaScriptBridge 는 Promise 를 못 기다리므로 결과는 window.tofuLast 에 "wait" -> "ok"|"fail" 로 남긴다.
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import { getFirestore, collection, addDoc, serverTimestamp }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const cfg = {
  apiKey: "AIzaSyCu1xkC5vL_crDyBBujk7UpCK_MtEQ8hh0",
  authDomain: "innollia-blog.firebaseapp.com",
  projectId: "innollia-blog",
  appId: "1:435062365847:web:6cf3b416b51d9edc8753d2",
};

let db = null;
try {
  db = getFirestore(initializeApp(cfg));
} catch (e) {
  console.warn("tofu_fb: init failed", e);
}

window.tofuLast = "";

function clip(s, n) {
  return String(s == null ? "" : s).slice(0, n);
}

async function send(col, data) {
  window.tofuLast = "wait";
  try {
    if (!db) throw new Error("no db");
    await addDoc(collection(db, col), data);
    window.tofuLast = "ok";
    return true;
  } catch (e) {
    console.warn("tofu_fb: " + col + " write failed:", e && e.code ? e.code : e);
    window.tofuLast = "fail";
    return false;
  }
}

window.tofuRate = function (game, ver, stars, text, score) {
  const s = Math.max(1, Math.min(5, Math.round(Number(stars) || 0)));
  return send("tofu_ratings", {
    game: clip(game, 40),
    ver: clip(ver, 40),
    stars: s,
    text: clip(text, 500),
    score: Math.round(Number(score) || 0),
    ua: clip(navigator.userAgent, 300),
    ts: serverTimestamp(),
  });
};

window.tofuIdea = function (text, ver) {
  const t = clip(text, 2000).trim();
  if (!t) { window.tofuLast = "fail"; return Promise.resolve(false); }
  return send("tofu_ideas", {
    text: t,
    ver: clip(ver, 40),
    ua: clip(navigator.userAgent, 300),
    ts: serverTimestamp(),
  });
};

// 별 없이 한마디만: tofu_ideas 에 game 을 붙여 쌓는다 (규칙은 text 만 본다). feedback.py 가 그 게임 한마디에 합친다.
window.tofuNote = function (game, ver, text) {
  const t = clip(text, 2000).trim();
  if (!t) { window.tofuLast = "fail"; return Promise.resolve(false); }
  return send("tofu_ideas", {
    text: t,
    game: clip(game, 40),
    ver: clip(ver, 40),
    ua: clip(navigator.userAgent, 300),
    ts: serverTimestamp(),
  });
};

window.tofuAsk = function (msg) {
  try {
    const r = window.prompt(msg);
    return r == null ? "" : String(r);
  } catch (e) {
    return "";
  }
};
