// The pocket minigame: grab the wallet and draw it out along the line.
// The street keeps moving underneath, so suspicion and witnesses still count while you trace.
import {TYPES} from './engine.js?v=20261024-4';
const W=640,H=400;
// tol: how far off the line the hand may wander. bends: how twisty the line is. Speed caps keep the minimum time close to each type's hold time.
const STYLE={civilian:{tol:30,bends:3,swing:70,coat:'#6d5440',lining:'#3a2b20',slip:.14},wealthy:{tol:23,bends:5,swing:105,coat:'#2c3550',lining:'#151a2a',slip:.16},police:{tol:17,bends:7,swing:125,coat:'#1d2c4a',lining:'#0d1526',slip:.18}};
const START={x:118,y:212};
function buildPath(type,seed){let r=seed;const rand=()=>{r=(r*16807)%2147483647;return r/2147483647;};const s=STYLE[type],pts=[{...START},{x:178,y:START.y}];for(let i=1;i<=s.bends;i++){const x=178+(560-178)*i/(s.bends+1);pts.push({x,y:Math.max(70,Math.min(H-70,H/2+(rand()*2-1)*s.swing))});}pts.push({x:568,y:H/2+(rand()*2-1)*40});
 // Catmull-Rom through the control points, then resample every 3px so progress is measured in pixels.
 const dense=[];for(let i=0;i<pts.length-1;i++){const p0=pts[Math.max(0,i-1)],p1=pts[i],p2=pts[i+1],p3=pts[Math.min(pts.length-1,i+2)];for(let k=0;k<24;k++){const t=k/24,t2=t*t,t3=t2*t;dense.push({x:.5*(2*p1.x+(-p0.x+p2.x)*t+(2*p0.x-5*p1.x+4*p2.x-p3.x)*t2+(-p0.x+3*p1.x-3*p2.x+p3.x)*t3),y:.5*(2*p1.y+(-p0.y+p2.y)*t+(2*p0.y-5*p1.y+4*p2.y-p3.y)*t2+(-p0.y+3*p1.y-3*p2.y+p3.y)*t3)});}}dense.push(pts.at(-1));
 const path=[dense[0]];let acc=0;for(let i=1;i<dense.length;i++){const a=dense[i-1],b=dense[i],d=Math.hypot(b.x-a.x,b.y-a.y);acc+=d;while(acc>=3){acc-=3;const k=1-acc/d;path.push({x:a.x+(b.x-a.x)*k,y:a.y+(b.y-a.y)*k});}}path.push(dense.at(-1));return path;}
export class Pickpocket{
 constructor(root,t){this.root=root;this.t=t;this.canvas=root.querySelector('canvas');this.c=this.canvas.getContext('2d');this.active=false;this.pointer=null;this.down=false;
  const pos=e=>{const r=this.canvas.getBoundingClientRect();return{x:(e.clientX-r.left)*W/r.width,y:(e.clientY-r.top)*H/r.height};};
  this.canvas.addEventListener('pointerdown',e=>{if(!this.active)return;e.preventDefault();this.canvas.setPointerCapture(e.pointerId);this.down=true;this.pointer=pos(e);const hand=this.path[this.index];if(Math.hypot(this.pointer.x-hand.x,this.pointer.y-hand.y)<46){this.grabbing=true;this.note='noteFollow';}else this.note='noteGrab';this.render();});
  this.canvas.addEventListener('pointermove',e=>{if(this.active)this.pointer=pos(e);});
  const up=()=>{this.down=false;if(this.grabbing){this.grabbing=false;this.note='noteRegrab';}};this.canvas.addEventListener('pointerup',up);this.canvas.addEventListener('pointercancel',up);}
 open(target,seed){const type=target.type,kind=TYPES[type];this.type=type;this.targetId=target.id;this.style=STYLE[type];this.path=buildPath(type,Math.floor(seed*7919)%2147483646+1);this.length=(this.path.length-1)*3;this.speed=this.length/(kind.hold*.8);this.index=0;this.carry=0;this.warn=false;this.grabbing=false;this.down=false;this.shake=0;this.note='noteGrab';this.slips=0;this.active=true;this.root.hidden=false;this.root.querySelector('[data-pick-title]').textContent=this.t('pickTitle',{name:this.t(type)});this.render();}
 close(){this.active=false;this.grabbing=false;this.root.hidden=true;}
 get fraction(){return this.active?this.index/(this.path.length-1):0;}
 // Returns the suspicion added this frame (a slip), or 0.
 update(dt){if(!this.active)return 0;this.shake=Math.max(0,this.shake-dt);let slip=0;
  if(this.grabbing&&this.pointer){const p=this.pointer,path=this.path,tol=this.style.tol;let best=this.index,bestD=Infinity;const hi=Math.min(path.length-1,this.index+30);for(let i=Math.max(0,this.index-8);i<=hi;i++){const d=Math.hypot(p.x-path[i].x,p.y-path[i].y);if(d<bestD){bestD=d;best=i;}}
   const hand=path[this.index],lead=Math.hypot(p.x-hand.x,p.y-hand.y);
   if(bestD>tol)slip=this.slip('noteOff');else if(lead>tol+62)slip=this.slip('noteFast');else{const step=Math.floor(this.speed*dt/3+this.carry);this.carry=(this.speed*dt/3+this.carry)%1;if(best>this.index)this.index=Math.min(best,this.index+Math.max(0,step));this.warn=lead>tol+30;}}
  else this.warn=false;this.render();return slip;}
 // The wallet slides back into the pocket a little and the victim may feel it.
 slip(note){this.grabbing=false;this.slips++;this.shake=.35;this.note=note;this.index=Math.max(0,this.index-Math.round((this.path.length-1)*.22));return this.style.slip;}
 render(){const c=this.c,s=this.style,path=this.path;c.save();c.clearRect(0,0,W,H);if(this.shake>0)c.translate(Math.sin(this.shake*90)*6*this.shake/.35,0);
  // Coat fabric with a little weave.
  c.fillStyle=s.coat;c.fillRect(0,0,W,H);c.globalAlpha=.08;c.fillStyle='#000';for(let y=0;y<H;y+=4)c.fillRect(0,y,W,1);if(this.type==='wealthy'){c.globalAlpha=.16;c.fillStyle='#c9c3a6';for(let x=12;x<W;x+=26)c.fillRect(x,0,1,H);}c.globalAlpha=1;
  if(this.type==='police'){c.fillStyle='#c9a64f';c.beginPath();c.moveTo(560,40);c.lineTo(584,52);c.lineTo(580,82);c.lineTo(560,96);c.lineTo(540,82);c.lineTo(536,52);c.closePath();c.fill();}
  // Pocket opening around the wallet.
  c.fillStyle=s.lining;c.beginPath();c.ellipse(START.x-6,START.y,58,78,0,0,Math.PI*2);c.fill();c.strokeStyle='#00000066';c.lineWidth=5;c.stroke();c.strokeStyle='#ffffff22';c.lineWidth=2;c.setLineDash([6,6]);c.beginPath();c.ellipse(START.x-6,START.y,64,84,0,0,Math.PI*2);c.stroke();c.setLineDash([]);
  // The way out: dashed guide, gold where the wallet has already travelled.
  c.lineCap='round';c.lineJoin='round';c.strokeStyle='#ffffff18';c.lineWidth=s.tol*2;c.beginPath();path.forEach((p,i)=>i?c.lineTo(p.x,p.y):c.moveTo(p.x,p.y));c.stroke();
  c.strokeStyle='#f1e4c2aa';c.lineWidth=3;c.setLineDash([10,9]);c.beginPath();path.forEach((p,i)=>i?c.lineTo(p.x,p.y):c.moveTo(p.x,p.y));c.stroke();c.setLineDash([]);
  c.strokeStyle='#e7c27a';c.lineWidth=6;c.beginPath();for(let i=0;i<=this.index;i++)i?c.lineTo(path[i].x,path[i].y):c.moveTo(path[i].x,path[i].y);c.stroke();
  // Your sleeve waits at the end.
  const end=path.at(-1);c.fillStyle='#24302b';c.beginPath();c.arc(end.x+30,end.y,34,0,Math.PI*2);c.fill();c.strokeStyle='#e7c27a';c.lineWidth=3;c.setLineDash([5,5]);c.beginPath();c.arc(end.x+30,end.y,34,0,Math.PI*2);c.stroke();c.setLineDash([]);
  // The wallet in your fingers.
  const hand=path[this.index],danger=this.warn||this.shake>0;c.save();c.translate(hand.x,hand.y);c.fillStyle=danger?'#a8432f':'#4a2e1e';c.fillRect(-24,-16,48,32);c.fillStyle=danger?'#d2654a':'#6e4630';c.fillRect(-24,-16,48,9);c.fillStyle='#e7c27a';c.fillRect(14,-3,6,6);
  c.strokeStyle=this.grabbing?'#f4dc9e':'#f4dc9e88';c.lineWidth=this.grabbing?4:2;if(!this.grabbing){c.setLineDash([4,5]);c.lineDashOffset=-performance.now()/40;}c.beginPath();c.arc(0,0,38,0,Math.PI*2);c.stroke();c.setLineDash([]);c.restore();
  c.restore();
  this.root.querySelector('[data-pick-note]').textContent=this.t(this.note);this.root.querySelector('[data-pick-note]').classList.toggle('bad',this.note==='noteOff'||this.note==='noteFast');this.root.querySelector('[data-pick-bar]').style.width=`${this.fraction*100}%`;}
}
