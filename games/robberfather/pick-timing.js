// Minigame (trial): a marker sweeps across a gauge. Click or press Space while it is in the gold zone to lift the wallet one notch.
// To take this minigame out of the game, delete its line in GAMES in pickpocket.js.
// steps: notches to lift. zone: gold zone width (0-1). sweep: seconds for the marker to cross once.
const STYLE={civilian:{steps:3,zone:.24,sweep:1.25},wealthy:{steps:4,zone:.18,sweep:1.05},police:{steps:5,zone:.13,sweep:.9}};
const BAR={x:280,y:326,w:330,h:32};
export class Timing{
 static id='timing';static hint='pickHintTiming';
 constructor({type,seed,start}){this.s=STYLE[type];this.start=start;this.r=seed;this.step=0;this.pos=0;this.dir=1;this.flash=0;this.hit=0;this.note='noteTap';this.newZone();}
 rand(){this.r=(this.r*16807)%2147483647;return this.r/2147483647;}
 newZone(){const w=this.s.zone;this.zone=[.08+this.rand()*(.84-w),0];this.zone[1]=this.zone[0]+w;}
 get fraction(){return this.step/this.s.steps;}
 // The fingers stay on the wallet the whole time the window is open.
 get touching(){return true;}
 resume(){this.note='noteResume';}
 down(){this.tap();}
 move(){}
 up(){}
 tap(){if(this.pending)return;const hit=this.pos>=this.zone[0]&&this.pos<=this.zone[1];if(hit){this.step++;this.hit=.25;this.note='noteGood';this.newZone();}else{this.pending=true;this.flash=.35;this.note='noteMiss';}}
 // Returns true on a mistake (a mistimed pinch).
 update(dt){this.flash=Math.max(0,this.flash-dt);this.hit=Math.max(0,this.hit-dt);this.pos+=this.dir*dt/this.s.sweep;if(this.pos>1){this.pos=2-this.pos;this.dir=-1;}if(this.pos<0){this.pos=-this.pos;this.dir=1;}if(this.pending){this.pending=false;return true;}return false;}
 draw(c,danger){const b=BAR,k=this.fraction,st=this.start,end={x:st.x+150,y:st.y-130};
  // The wallet climbs out of the pocket notch by notch.
  c.strokeStyle='#ffffff22';c.lineWidth=3;c.setLineDash([8,8]);c.beginPath();c.moveTo(st.x,st.y);c.lineTo(end.x,end.y);c.stroke();c.setLineDash([]);
  for(let i=1;i<=this.s.steps;i++){const q=i/this.s.steps,x=st.x+(end.x-st.x)*q,y=st.y+(end.y-st.y)*q;c.fillStyle=i<=this.step?'#e7c27a':'#ffffff30';c.beginPath();c.arc(x,y,6,0,Math.PI*2);c.fill();}
  c.fillStyle='#0b1512';c.fillRect(b.x-6,b.y-6,b.w+12,b.h+12);c.fillStyle=this.flash>0?'#5a1d17':'#22302b';c.fillRect(b.x,b.y,b.w,b.h);
  c.fillStyle=this.hit>0?'#fff0b8':'#e7c27a';c.fillRect(b.x+b.w*this.zone[0],b.y,b.w*(this.zone[1]-this.zone[0]),b.h);
  const mx=b.x+b.w*this.pos;c.fillStyle='#ffffff';c.fillRect(mx-3,b.y-12,6,b.h+24);
  c.fillStyle='#e1dcc0';c.font='bold 18px sans-serif';c.textAlign='center';c.fillText(`${this.step} / ${this.s.steps}`,b.x+b.w/2,b.y-18);
  return{x:st.x+(end.x-st.x)*k,y:st.y+(end.y-st.y)*k,danger:danger||this.flash>0,ring:false,grabbing:true};}
}
