// Pure simulation. Display text belongs to i18n.js and story.js.
export const WIDTH=1440,HEIGHT=840,WORLD=4400,GROUND=650;
export const RULES={capacity:3,maxCaught:2,daySeconds:150,stamina:42,sprintDrain:26,regen:8,walk:126,run:246,discardHold:1.4,hiddenEscape:1.2,recognizeCalm:3,lookTime:1.4};
// behind: fixed suspicion per second while your hand is in the pocket. wait: seconds between the victim turning around. warn: seconds you get to press E.
export const TYPES={civilian:{slots:1,hold:3.0,risk:.36,speed:40,wait:[2.4,4.6],warn:.75},wealthy:{slots:2,hold:3.9,risk:.48,speed:33,wait:[1.9,3.9],warn:.6},police:{slots:3,hold:6.0,risk:.62,speed:48,behind:.155,wait:[1.7,3.3],warn:.48}};
// First-day practice, one step at a time. During it nobody notices you and the victim only turns once, waiting for your E.
export const TUTORIAL={move:0,find:1,approach:2,pull:3,dodge:4,resume:5,done:6};
// Every shop front on the street has its own room, laid out far beyond the street so distances never cross.
export const SHOPS=[[596,330,0],[938,400,1],[1622,380,2],[2014,340,3],[2370,262,0],[2820,370,1],[3202,370,2],[3920,460,3]].map(([x,w,kind],id)=>({id,x,w,kind,door:x+68,x0:6000+id*2400,x1:6000+id*2400+WIDTH}));
export const INSIDE_DOOR=150;
export const areaAt=x=>SHOPS.find(s=>x>=s.x0-300&&x<=s.x1+300)||null;
const bounds=x=>{const s=areaAt(x);return s?[s.x0+90,s.x1-90]:[90,WORLD-90];};
// Nothing to hide in or scavenge right outside home. Each shop has one storage crate.
export const BOXES=[{id:1,x:1240},{id:2,x:1930},{id:3,x:2850},{id:4,x:3690},...SHOPS.map(s=>({id:10+s.id,x:s.x0+1240,inside:true}))];
export const BINS=[{id:1,x:1710},{id:2,x:2580},{id:3,x:4140}];
// Who is inside each kind of shop: bakery, corner store, café, rooms.
const ROOM_PEOPLE=[[['civilian',560],['wealthy',860]],[['civilian',480],['civilian',780],['police',1040]],[['wealthy',520],['civilian',900]],[['wealthy',600],['police',940]]];
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const valid=(v,fallback=0)=>Number.isFinite(v)?v:fallback;
const distance=(a,b)=>Math.abs(a.x-b.x);
export class Game{
 constructor(save=null){this.day=clamp(Math.floor(valid(save?.day,1)),1,999999);this.hungerStreak=clamp(valid(save?.hungerStreak),0,2);this.rottenStreak=clamp(valid(save?.rottenStreak),0,2);this.lastMeal=['fresh','rotten','hungry','both'].includes(save?.lastMeal)?save.lastMeal:'fresh';this.stats={meals:Math.max(0,valid(save?.stats?.meals)),total:Math.max(0,valid(save?.stats?.total)),best:Math.max(0,valid(save?.stats?.best))};this.tutorialDone=!!save?.tutorialDone;this.time=0;this.events=[];this.resetDay();this.resumeMode='morning';if(save?.version===3)this.restore(save);this.mode='intro';}
 get filled(){return this.inventory.length;}get rottenCount(){return this.inventory.filter(x=>x==='rotten').length;}get quotaMet(){return this.filled===RULES.capacity;}
 get caughtCount(){return this.attempts.filter(x=>x==='caught').length;}get banned(){return this.caughtCount>=RULES.maxCaught;}get shop(){return areaAt(this.player.x);}
 emit(type,data={}){this.events.push({type,...data});}drainEvents(){return this.events.splice(0);}
 resetDay(){this.player={x:330,y:GROUND,face:1,walk:0,stamina:RULES.stamina,exhausted:false,hidden:false,boxId:null};this.mode='morning';this.inventory=[];this.attempts=[];this.earned=0;this.timeLeft=RULES.daySeconds;this.target=null;this.activeTarget=null;this.turn={phase:'wait',t:0,face:1};this.progress=0;this.suspicion=0;this.chasers=[];this.chaseTime=0;this.escape=0;this.cooldown=0;this.nightTime=0;this.returnReason='home';this.fed=false;this.ateRotten=false;this.eaten=0;this.ending=null;this.endingTime=0;this.morningIndex=0;this.discardProgress=0;this.discardLatch=false;this.previousInput={};this.tutorial=this.tutorialDone?TUTORIAL.done:TUTORIAL.move;this.travel=0;this.bins=BINS.map(b=>({...b,searched:false}));
 const specs=[['civilian',790,-1],['civilian',1110,1],['wealthy',1410,-1],['civilian',1770,1],['police',2100,-1],['wealthy',2470,1],['civilian',2910,-1],['police',3210,1],['wealthy',3570,-1],['civilian',4030,1]];
 const person=(id,type,x,face,min,max)=>({id,type,x,y:GROUND+(id%2?4:-4),face,walk:id,stolen:false,alert:false,knows:false,calm:0,recognizing:false,witness:0,lookBack:0,faceBack:face,lastSeen:x,pause:(id*.7)%3,seed:(id*2.3+this.day)%9,min,max});
 this.npcs=specs.map(([type,x,face],id)=>person(id,type,x,face,Math.max(665,x-230),Math.min(WORLD-100,x+330)));
 for(const s of SHOPS)ROOM_PEOPLE[s.kind].forEach(([type,dx],i)=>this.npcs.push(person(this.npcs.length,type,s.x0+dx,i%2?-1:1,s.x0+330,s.x1-140)));}
 restore(s){this.resumeMode=['morning','day','night','ending'].includes(s.mode)?s.mode:'morning';this.inventory=Array.isArray(s.inventory)?s.inventory.filter(x=>x==='fresh'||x==='rotten').slice(0,3):[];this.timeLeft=clamp(valid(s.timeLeft,RULES.daySeconds),0,RULES.daySeconds);this.attempts=Array.isArray(s.attempts)?s.attempts.filter(x=>x==='success'||x==='caught').slice(0,200):[];this.earned=Math.max(0,valid(s.earned));this.morningIndex=clamp(valid(s.morningIndex),0,2);this.fed=!!s.fed;this.ateRotten=!!s.ateRotten;this.eaten=clamp(valid(s.eaten,this.fed?3:0),0,3);this.returnReason=s.returnReason==='timeout'?'timeout':'home';this.ending=['arrest','collapse'].includes(s.ending)?s.ending:null;this.endingTime=0;
 if(s.player){const p=s.player,[lo,hi]=bounds(valid(p.x,330));this.player.x=clamp(valid(p.x,330),lo,hi);this.player.face=p.face===-1?-1:1;this.player.stamina=clamp(valid(p.stamina,RULES.stamina),0,RULES.stamina);this.player.exhausted=!!p.exhausted;const box=BOXES.find(b=>b.id===p.boxId);if(p.hidden&&box){this.player.hidden=true;this.player.boxId=box.id;this.player.x=box.x;}}
 if(Array.isArray(s.npcs))for(const n of this.npcs){const v=s.npcs.find(v=>v.id===n.id);if(!v)continue;const [lo,hi]=bounds(n.x);n.x=clamp(valid(v.x,n.x),lo-60,hi+60);n.face=v.face===-1?-1:1;n.pause=clamp(valid(v.pause),0,5);n.stolen=!!v.stolen;n.knows=!!v.knows;n.calm=clamp(valid(v.calm),0,RULES.recognizeCalm);n.witness=clamp(valid(v.witness),0,1);n.lastSeen=clamp(valid(v.lastSeen,n.x),lo-60,hi+60);}
 this.bins.forEach(b=>b.searched=Array.isArray(s.searchedBins)&&s.searchedBins.includes(b.id));this.chasers=Array.isArray(s.chasers)?[...new Set(s.chasers.filter(id=>this.npcs.some(n=>n.id===id)))]:[];this.chasers.forEach(id=>this.npcs.find(n=>n.id===id).alert=true);this.chaseTime=clamp(valid(s.chaseTime),0,1000);this.escape=clamp(valid(s.escape),0,3);}
 start(){if(this.mode==='intro')this.mode=this.resumeMode;}
 advanceMorning(){if(this.mode!=='morning')return false;this.morningIndex++;if(this.morningIndex>=3){this.mode='day';this.morningIndex=0;this.emit('dayStart');return true;}return false;}
 facingPlayer(n){return(this.player.x-n.x)*n.face>0;}
 isBehind(n){return!this.facingPlayer(n)&&distance(n,this.player)>=18;}
 isWatching(n){return(this.time+n.seed)%9<3.4;}
 nearest(){if(this.banned||this.chasers.length||this.player.x<630||this.player.hidden||this.quotaMet)return null;return this.npcs.filter(n=>!n.stolen&&distance(n,this.player)<67).sort((a,b)=>distance(a,this.player)-distance(b,this.player))[0]||null;}
 nearbyBox(){return BOXES.find(b=>distance(b,this.player)<53)||null;}
 nearbyBin(){if(this.player.hidden||this.chasers.length)return null;return this.bins.filter(b=>!b.searched&&distance(b,this.player)<60).sort((a,b)=>distance(a,this.player)-distance(b,this.player))[0]||null;}
 // The shop door the player is standing at: a street entrance, or the exit inside a shop.
 nearbyDoor(){if(this.player.hidden)return null;const inside=this.shop;if(inside)return Math.abs(this.player.x-(inside.x0+INSIDE_DOOR))<60?{shop:inside,exit:true}:null;const s=SHOPS.find(s=>Math.abs(s.door-this.player.x)<45);return s?{shop:s,exit:false}:null;}
 useDoor(){const d=this.nearbyDoor();if(!d)return false;if(this.chasers.length){this.emit('doorBlocked');return false;}this.clearHold();this.player.x=d.exit?d.shop.door:d.shop.x0+INSIDE_DOOR;this.player.face=1;this.emit(d.exit?'exitShop':'enterShop',{kind:d.shop.kind});return true;}
 clearHold(){this.activeTarget=null;this.progress=0;this.suspicion=0;this.turn={phase:'wait',t:0,face:1};}
 addFood(kind,count){const added=Math.min(count,RULES.capacity-this.filled);for(let i=0;i<added;i++)this.inventory.push(kind);return added;}
 takeBin(b){if(this.quotaMet){this.emit('bagFull');return false;}b.searched=true;this.addFood('rotten',1);this.emit('scavenged');if(this.quotaMet)this.emit('goal');return true;}
 discardRotten(){const i=this.inventory.lastIndexOf('rotten');if(i<0)return false;this.inventory.splice(i,1);this.emit('discarded');return true;}
 // A box always hides you: pursuers lose sight the moment you are inside.
 toggleHide(){if(this.player.hidden){this.player.hidden=false;this.player.boxId=null;this.emit('unhidden');return true;}const b=this.nearbyBox();if(!b)return false;this.clearHold();this.player.hidden=true;this.player.boxId=b.id;this.player.x=b.x;this.escape=0;this.emit('hidden');return true;}
 update(dt,input={}){dt=clamp(dt,0,.05);this.time+=dt;if(this.mode==='night'){this.nightTime+=dt;return;}if(this.mode==='ending'){this.endingTime+=dt;return;}if(this.mode!=='day')return;
 const priorTime=this.timeLeft;this.timeLeft=Math.max(0,this.timeLeft-dt);if(priorTime>30&&this.timeLeft<=30)this.emit('duskWarning');if(this.timeLeft===0){this.endChase();this.goHome('timeout');this.emit('timeout');return;}
 this.cooldown=Math.max(0,this.cooldown-dt);const edge=key=>input[key]&&!this.previousInput[key];const dir=(input.right?1:0)-(input.left?1:0),p=this.player;
 if(edge('hide'))this.toggleHide();if(p.hidden&&dir)this.toggleHide();if(edge('enter'))this.useDoor();
 if(p.exhausted&&p.stamina>=RULES.stamina*.45)p.exhausted=false;const running=dir&&input.run&&!p.exhausted&&p.stamina>0&&!p.hidden;
 if(dir&&!p.hidden){const dx=dir*(running?RULES.run:RULES.walk)*dt,[lo,hi]=bounds(p.x);p.x=clamp(p.x+dx,lo,hi);p.face=dir;p.walk+=dt*(running?15:9);this.travel+=Math.abs(dx);}
 p.stamina=clamp(p.stamina+(running?-RULES.sprintDrain:RULES.regen)*dt,0,RULES.stamina);if(p.stamina<=0)p.exhausted=true;
 if(this.tutorial===TUTORIAL.move&&this.travel>=75)this.tutorial=TUTORIAL.find;
 const bin=this.nearbyBin();this.target=this.nearest();const binPriority=bin&&(!this.target||distance(bin,p)<distance(this.target,p));if(binPriority)this.target=null;
 if(binPriority&&edge('steal'))this.takeBin(bin);else if(binPriority&&edge('leave')){bin.searched=true;this.emit('binLeft');}
 if(input.discard&&this.rottenCount&&!this.discardLatch){this.discardProgress+=dt;if(this.discardProgress>=RULES.discardHold){this.discardRotten();this.discardLatch=true;this.discardProgress=0;}}else if(!input.discard){this.discardProgress=0;this.discardLatch=false;}
 if(this.target&&this.tutorial===TUTORIAL.find)this.tutorial=TUTORIAL.approach;
 const practice=this.tutorial<TUTORIAL.done;
 if(input.pick&&this.target&&!dir&&!p.hidden&&!input.discard&&this.cooldown===0&&(this.activeTarget===this.target.id||this.isBehind(this.target))){const n=this.target,kind=TYPES[n.type],watching=this.isWatching(n),tn=this.turn,slip=valid(input.slip);if(this.activeTarget!==n.id){this.activeTarget=n.id;this.progress=0;this.suspicion=0;tn.phase='wait';tn.t=practice?Infinity:kind.wait[0]+Math.random()*(kind.wait[1]-kind.wait[0]);if(this.tutorial===TUTORIAL.approach||this.tutorial===TUTORIAL.dodge)this.tutorial=TUTORIAL.pull;}this.progress=clamp(valid(input.trace),0,1)*kind.hold;this.suspicion+=slip;
 // A mistake makes the victim start to turn. In practice they turn once, part way through, and wait for your E.
 if(tn.phase==='wait'&&(slip>0||this.tutorial===TUTORIAL.pull&&this.progress>=kind.hold*.4))tn.t=0;
 // Leave the pocket (E) during the warning or be seen with your hand in their coat.
 tn.t-=dt;if(tn.phase==='wait'&&tn.t<=0){tn.phase='warn';tn.t=practice?Infinity:kind.warn;if(practice)this.tutorial=TUTORIAL.dodge;this.emit('turnWarn');}else if(tn.phase==='warn'&&tn.t<=0){tn.phase='look';tn.t=RULES.lookTime;tn.face=n.face;n.face=Math.sign(p.x-n.x)||-n.face;this.emit('turnLook');}else if(tn.phase==='look'&&tn.t<=0){tn.phase='wait';tn.t=kind.wait[0]+Math.random()*(kind.wait[1]-kind.wait[0]);n.face=tn.face;this.emit('turnAway');}
 if(tn.phase==='look'){this.detect(n,n,false);this.previousInput={...input};return;}
 if(input.grab)this.suspicion+=dt*(kind.behind??kind.risk*.48*(watching?1.45:.9));
 if(practice)this.suspicion=Math.min(this.suspicion,.9);
 let detector=null;for(const w of this.npcs){if(practice||w.id===n.id)continue;const d=distance(w,p),range=w.type==='police'?420:310;if(d<range&&(this.facingPlayer(w)||d<100)){const close=d<150?1.8:1;w.witness=clamp(w.witness+dt*(w.type==='police'?.62:.42)*close*(this.isWatching(w)?1.4:.85),0,1);if(w.witness>=1)detector=w;}}
 if(this.suspicion>=1||detector){this.detect(detector||n,n,!!detector);}else if(this.progress>=kind.hold){const amount=this.addFood('fresh',kind.slots);this.earned+=amount;this.stats.total+=amount;n.stolen=true;this.attempts.push('success');this.cooldown=.8;this.clearHold();this.finishTutorial();this.emit('stolen',{amount});if(this.quotaMet)this.emit('goal');}
 }else this.clearHold();
 this.recognize(dt);
 for(const n of this.npcs){if(this.activeTarget===null&&!n.recognizing)n.witness=Math.max(0,n.witness-dt*.12);if(n.lookBack>0){n.lookBack-=dt;if(n.lookBack<=0)n.face=n.faceBack;continue;}if(this.activeTarget===n.id||this.chasers.includes(n.id))continue;if(n.pause>0){n.pause-=dt;continue;}if(n.x<n.min)n.face=1;else if(n.x>n.max)n.face=-1;n.x+=n.face*TYPES[n.type].speed*dt;n.walk+=dt*5;if(Math.abs(n.x-n.min)<2||Math.abs(n.x-n.max)<2)n.pause=.8;}
 if(this.chasers.length)this.updateChase(dt);this.previousInput={...input};}
 // People who know what you did fill a red gauge when they see you again, then give chase.
 recognize(dt){const p=this.player,quiet=this.chasers.length||p.hidden;for(const n of this.npcs){n.recognizing=false;if(!n.knows||quiet)continue;if(n.calm>0){n.calm-=dt;continue;}const d=distance(n,p);if(d<280&&(this.facingPlayer(n)||d<90)){n.recognizing=true;n.witness=clamp(n.witness+dt*(d<140?.6:.38),0,1);if(n.witness>=1){this.clearHold();this.beginChase(n);this.emit('recognized');return;}}}}
 // Leaving the pocket. Done during the warning, the victim turns, finds nobody at their coat, and turns back.
 dodge(){const n=this.npcs.find(n=>n.id===this.activeTarget);if(n&&this.turn.phase==='warn'){n.faceBack=n.face;n.face=Math.sign(this.player.x-n.x)||-n.face;n.lookBack=RULES.lookTime;this.emit('turnLook');this.emit('dodged');if(this.tutorial===TUTORIAL.dodge)this.tutorial=TUTORIAL.resume;}this.clearHold();this.cooldown=Math.max(this.cooldown,.3);}
 skipEnding(){if(this.mode==='ending')this.endingTime=Math.max(this.endingTime,8);}
 finishTutorial(){if(this.tutorial<TUTORIAL.done){this.tutorial=TUTORIAL.done;this.tutorialDone=true;this.emit('tutorialComplete');}}
 detect(detector,victim,witnessed=false){this.attempts.push('caught');this.beginChase(detector,victim);this.clearHold();this.finishTutorial();this.emit(witnessed?'witnessed':'detected');}
 beginChase(detector,victim=detector){this.chasers=this.npcs.filter(n=>n.id===detector.id||n.id===victim.id||(distance(n,this.player)<300&&(n.type==='police'||distance(n,this.player)<190))).map(n=>n.id);this.chasers.forEach(id=>{const n=this.npcs.find(n=>n.id===id);n.alert=true;n.knows=true;n.recognizing=false;n.lastSeen=this.player.x;});this.chaseTime=0;this.escape=0;}
 updateChase(dt){this.chaseTime+=dt;const p=this.player;let nearest=Infinity;for(const id of this.chasers){const n=this.npcs.find(n=>n.id===id);if(!p.hidden)n.lastSeen=p.x;const dx=n.lastSeen-n.x;n.face=Math.sign(dx)||n.face;if(Math.abs(dx)>9){n.x+=Math.sign(dx)*(n.type==='police'?196:174)*dt;n.walk+=dt*11;}nearest=Math.min(nearest,distance(n,p));}
 if(p.hidden||nearest>380)this.escape+=dt;else this.escape=0;if(this.escape>(p.hidden?RULES.hiddenEscape:4)){this.endChase();this.emit('escaped');return;}
 if(this.chaseTime>1.25&&!p.hidden&&nearest<21){const lost=this.inventory.length?1:0;if(lost)this.inventory.pop();this.mode='caught';this.player.hidden=false;this.player.boxId=null;this.clearHold();this.emit('caught',{lost});}}
 endChase(){this.chasers.forEach(id=>{const n=this.npcs.find(n=>n.id===id);n.alert=false;n.pause=2;n.witness=0;n.calm=RULES.recognizeCalm;});this.chasers=[];this.chaseTime=0;this.escape=0;}
 recover(){if(this.mode!=='caught')return;this.endChase();this.player.x=330;this.player.stamina=RULES.stamina;this.player.exhausted=false;this.player.hidden=false;this.player.boxId=null;this.mode='day';this.cooldown=1;this.previousInput={};}
 canHome(){return this.mode==='day'&&!this.chasers.length;}
 goHome(reason='home'){if(!this.canHome())return false;this.mode='return';this.returnReason=reason;this.player.hidden=false;this.player.boxId=null;this.clearHold();return true;}
 // After dusk the stalls are shut, so only rotten food can still be eaten. Fewer than three portions is still a hungry night.
 beginNight(){if(this.mode!=='return')return false;this.mode='night';const eaten=this.returnReason==='timeout'?this.inventory.filter(x=>x==='rotten'):[...this.inventory];this.eaten=eaten.length;this.fed=eaten.length===RULES.capacity;this.ateRotten=eaten.includes('rotten');this.lastMeal=this.fed?(this.ateRotten?'rotten':'fresh'):(this.ateRotten?'both':'hungry');this.hungerStreak=this.fed?0:this.hungerStreak+1;this.rottenStreak=this.ateRotten?this.rottenStreak+1:0;this.inventory=[];if(this.fed)this.stats.meals++;this.stats.best=Math.max(this.stats.best,this.day);this.nightTime=0;this.emit('night');return true;}
 nextDay(){if(this.mode!=='night')return false;this.day++;if(this.hungerStreak>=2||this.rottenStreak>=2){this.ending=this.hungerStreak>=2?'arrest':'collapse';this.endingTime=0;this.mode='ending';this.emit('ending',{kind:this.ending});return false;}this.resetDay();this.emit('morning');return true;}
 save(){return{version:3,day:this.day,mode:this.mode==='return'?'day':this.mode,inventory:[...this.inventory],hungerStreak:this.hungerStreak,rottenStreak:this.rottenStreak,lastMeal:this.lastMeal,stats:{...this.stats},tutorialDone:this.tutorialDone,timeLeft:this.timeLeft,attempts:[...this.attempts],earned:this.earned,player:{...this.player},npcs:this.npcs.map(n=>({...n})),chasers:[...this.chasers],chaseTime:this.chaseTime,escape:this.escape,searchedBins:this.bins.filter(b=>b.searched).map(b=>b.id),fed:this.fed,ateRotten:this.ateRotten,eaten:this.eaten,returnReason:this.returnReason,morningIndex:this.morningIndex,ending:this.ending};}
}
