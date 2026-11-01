export const DAY_MS = 24 * 60 * 60 * 1000;
export const SAVE_KEY='haeondong-world-v1';
export const BACKUP_KEY='haeondong-world-backup-v1';
export const NPC_SEED = [
  { id:'yun', name:'윤', role:'동네 책방 주인', home:'서점', color:'#d6e3d1', ink:'#4e6d50', traits:['차분함','관찰력이 좋아요'], background:'이 동네에서 책방을 오래 지켜 온 사람입니다.', values:['책을 나누는 일','약속 지키기'], preferences:['조용한 아침 산책','오래된 소설'], energy:82, hunger:26, social:44, money:86, affinity:{}, schedule:['서점','서점','골목','도서관','서점','공원','서점'], goal:'책방에 작은 책 교환 서가를 만들고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'minjae', name:'민재', role:'카페 바리스타', home:'카페', color:'#edddc9', ink:'#9b704e', traits:['사교적','새로운 것을 좋아해요'], background:'여러 곳을 다니다가 해온동 카페에 자리 잡았습니다.', values:['새로운 경험','먼저 인사하기'], preferences:['인디 음악','새로운 원두'], energy:73, hunger:36, social:31, money:52, affinity:{}, schedule:['카페','카페','공원','카페','도서관','카페','골목'], goal:'작은 음악 모임을 열고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'yerin', name:'예린', role:'도서관 사서', home:'도서관', color:'#e5dced', ink:'#806894', traits:['신중함','남을 잘 챙겨요'], background:'어릴 때부터 도서관에서 보내는 시간을 좋아했습니다.', values:['차분한 배려','꾸준히 배우기'], preferences:['독립서점 구경','식물 기르기'], energy:88, hunger:22, social:53, money:71, affinity:{}, schedule:['도서관','도서관','카페','공원','도서관','골목','도서관'], goal:'읽고 싶은 책 목록을 완성하고 싶다', goalProgress:0, goalMilestones:[], memory:[] }
];
const DAY_NAMES=['첫째 날','둘째 날','셋째 날','넷째 날','다섯째 날','여섯째 날','일곱째 날','여덟째 날','아홉째 날','열째 날'];
export const dayName=n=>n<=DAY_NAMES.length?DAY_NAMES[Math.max(0,n-1)]:`${n}일째`;
export function newWorld(now=Date.now(),seed=1){const npcs=structuredClone(NPC_SEED);for(const npc of npcs)npc.location=npc.home;return {version:1,day:1,hour:8,minute:0,lastRealAt:now,seed,nextEventId:1,paused:false,player:{energy:82,money:18,location:'골목',x:.49,y:.50,affinity:{}},npcs,events:[{id:'welcome',day:1,hour:8,text:'당신이 해온동에 이사 왔습니다. 동네는 오늘도 천천히 깨어납니다.',kind:'ordinary'}],seenEvents:[],daysAway:0};}
export function randomFor(world){world.seed=(world.seed*1664525+1013904223)>>>0;return world.seed/4294967296;}
function event(world,text,kind='ordinary'){const sequence=Number.isSafeInteger(world.nextEventId)?world.nextEventId:world.events.length+1;world.nextEventId=sequence+1;const entry={id:`event-${world.day}-${sequence}`,day:world.day,hour:world.hour,minute:world.minute,text,kind};world.events.unshift(entry);if(world.events.length>40)world.events.length=40;return entry;}
function remember(npc,memory){npc.memory.unshift(memory);if(npc.memory.length>40)npc.memory.length=40;}
function deepenPlayerRelationship(world,npc,amount){
 if(npc.playerAffinityDay!==world.day){npc.playerAffinityDay=world.day;npc.playerAffinityToday=0;}
 const gain=Math.min(amount,Math.max(0,2-npc.playerAffinityToday));
 if(gain<=0)return 0;
 npc.playerAffinityToday+=gain;
 npc.affinity.player=(npc.affinity.player||0)+gain;
 world.player.affinity[npc.id]=(world.player.affinity[npc.id]||0)+gain;
 return gain;
}
function advanceGoal(world,npc,amount){
 if(npc.goalCompleted)return;
 const previous=npc.goalProgress||0;npc.goalProgress=Math.min(100,previous+amount);
 for(const threshold of [30,65,100]){
  if(previous<threshold&&npc.goalProgress>=threshold&&!npc.goalMilestones.includes(threshold)){
   npc.goalMilestones.push(threshold);
   const complete=threshold===100;
   const text=complete?`${npc.name}은(는) 오래 품어 온 바람을 이루었습니다. ${npc.goal}`:`${npc.name}은(는) ${npc.goalProgress>=65?'바라는 일을 실현할 준비를 하고 있습니다.':'바라는 일을 위해 작은 준비를 시작했습니다.'}`;
   remember(npc,{day:world.day,text,importance:complete?5:3});event(world,text,complete?'major':'minor');
   if(complete)npc.goalCompleted=true;
  }
 }
}
function npcStep(world){const h=world.hour;for(const n of world.npcs){n.hunger=Math.min(100,n.hunger+1.2);n.energy=Math.max(4,n.energy-(h>=22||h<7?-.7:1.1));n.social=Math.min(100,n.social+.14);
 let place=h<7?'집':(h>=22?'집':n.schedule[(world.day-1)%n.schedule.length]);
 if(h===8&&n.id==='minjae')place='카페'; if(h===9&&n.id==='yun')place='서점';if(h===10&&n.id==='yerin')place='도서관';
 n.location=place;
 if((n.id==='yun'&&h===10&&place==='서점')||(n.id==='minjae'&&h===18&&place==='카페')||(n.id==='yerin'&&h===15&&place==='도서관'))advanceGoal(world,n,10);
 if((h===8||h===12||h===19)&&n.hunger>48){n.hunger=Math.max(8,n.hunger-32);if(h===12&&randomFor(world)<.18)event(world,`${n.name}은(는) 골목에서 간단히 점심을 먹었습니다.`);}
 if(h===18&&n.energy<45){n.energy=Math.min(100,n.energy+10);}
 }
 if((world.hour===11||world.hour===16)&&world.lastMeetingDay!==world.day){const groups=new Map();for(const n of world.npcs){if(n.location==='집')continue;const group=groups.get(n.location)||[];group.push(n);groups.set(n.location,group);}const pair=[...groups.values()].find(group=>group.length>1);if(pair&&randomFor(world)<.65){const [a,b]=pair;a.social=Math.max(0,a.social-8);b.social=Math.max(0,b.social-8);a.affinity[b.id]=(a.affinity[b.id]||0)+1;b.affinity[a.id]=(b.affinity[a.id]||0)+1;const text=`${a.name}와 ${b.name}이(가) ${a.location}에서 잠깐 이야기를 나눴습니다.`;remember(a,{day:world.day,text,importance:2});remember(b,{day:world.day,text,importance:2});event(world,text,'minor');world.lastMeetingDay=world.day;}}
 if(world.hour===20){const n=world.npcs[Math.floor(randomFor(world)*world.npcs.length)];if(randomFor(world)<(n.social>70?.75:.18)){if(n.social>60){const other=world.npcs.filter(x=>x.id!==n.id).sort((a,b)=>b.social-a.social)[0];n.social=Math.max(0,n.social-10);other.social=Math.max(0,other.social-7);n.affinity[other.id]=(n.affinity[other.id]||0)+1;other.affinity[n.id]=(other.affinity[n.id]||0)+1;const text=`${n.name}은(는) 저녁에 ${other.name}에게 안부를 물었습니다.`;remember(n,{day:world.day,text,importance:2});remember(other,{day:world.day,text,importance:2});event(world,text,'ordinary');}else{event(world,`${n.name}은(는) 오늘 있었던 일을 조용히 돌아봅니다.`);remember(n,{day:world.day,text:'오늘을 돌아보며 마음에 남는 일이 있었다.',importance:1});}}}
}
export function tick(world,minutes=10){for(let i=0;i<minutes;i+=10){world.minute+=10;if(world.minute>=60){world.minute=0;world.hour++;npcStep(world);}if(world.hour>=24){world.hour=0;world.day++;event(world,`${dayName(world.day)}이 시작됐습니다. 해온동에 새로운 아침이 옵니다.`);}world.player.energy=Math.max(0,Math.min(100,world.player.energy-.04));}return world;}
function placeFor(x,y){return x<.36&&y>.53?'카페':x>.58&&y<.48?'서점':x>.58&&y>.5?'도서관':x<.4&&y<.43?'집':'골목';}
export function movePlayer(world,dx,dy){const p=world.player;p.x=Math.max(.06,Math.min(.94,(p.x??.49)+dx));p.y=Math.max(.08,Math.min(.91,(p.y??.5)+dy));p.location=placeFor(p.x,p.y);return p.location;}
export function movePlayerTo(world,x,y){const p=world.player;p.x=Math.max(.06,Math.min(.94,x));p.y=Math.max(.08,Math.min(.91,y));p.location=placeFor(p.x,p.y);return p.location;}
export function catchUp(world,now=Date.now()){const previous=Number.isFinite(world.lastRealAt)?world.lastRealAt:now;const checkpoint=Math.max(now,previous);const elapsed=Math.max(0,Math.min(checkpoint-previous,30*DAY_MS));world.daysAway=elapsed>=DAY_MS?Math.floor(elapsed/DAY_MS):0;const minutes=Math.floor(elapsed/60000);const step=Math.min(Math.floor(minutes/10)*10,30*24*60);if(step)tick(world,step);world.lastRealAt=checkpoint;return world;}
export function playerAction(world,action,now=Date.now()){const p=world.player;world.daysAway=0;let outcome='',elapsed=20;if(action==='work'){elapsed=120;p.money+=12;p.energy=Math.max(0,p.energy-18);p.location='카페';p.x=.18;p.y=.68;const n=world.npcs.find(x=>x.id==='minjae');deepenPlayerRelationship(world,n,1);advanceGoal(world,n,15);remember(n,{day:world.day,text:'플레이어가 카페에서 함께 일해 주었다.',importance:3});n.social=Math.max(0,n.social-9);event(world,'카페에서 두 시간 일해 12원을 받았습니다. 민재가 고맙게 웃었습니다.','player');outcome='함께 일한 시간이 민재의 기억에 남았습니다. 12원을 벌었지만 기운은 줄었습니다.';}
 else if(action==='talk'){const n=world.npcs.filter(x=>x.location!=='집').sort((a,b)=>Math.abs(a.social-45)-Math.abs(b.social-45))[0]||world.npcs[0];p.location=n.location;const pos={카페:[.18,.68],서점:[.70,.28],도서관:[.73,.70],공원:[.52,.75],골목:[.49,.50]};[p.x,p.y]=pos[n.location]||[.49,.50];p.energy=Math.max(0,p.energy-3);deepenPlayerRelationship(world,n,2);n.social=Math.max(0,n.social-14);remember(n,{day:world.day,text:`플레이어가 먼저 말을 걸어 안부를 물었다.`,importance:3});event(world,`${n.name}과(와) 잠시 이야기를 나눴습니다. 다음에 만나면 오늘을 기억할 거예요.`,'player');outcome=`${n.name}은(는) 오늘의 대화를 기억합니다. 가까워지는 데는 시간이 더 필요해요.`;}
 else if(action==='rest'){elapsed=180;p.energy=Math.min(100,p.energy+38);p.location='집';p.x=.28;p.y=.25;event(world,'집에서 여유롭게 쉬었습니다. 동네의 시간은 계속 흘렀습니다.','player');outcome='기운을 회복했습니다. 쉬는 동안 이웃들의 하루도 이어졌습니다.';}
 else if(action==='hobby'){elapsed=60;p.energy=Math.max(0,p.energy-7);p.location='도서관';p.x=.73;p.y=.70;const n=world.npcs.find(x=>x.id==='yerin');deepenPlayerRelationship(world,n,1);advanceGoal(world,n,15);remember(n,{day:world.day,text:'플레이어가 도서관에서 조용히 책을 읽었다.',importance:2});event(world,'도서관에서 책을 읽었습니다. 예린은 당신이 책을 읽은 모습을 기억해 두었습니다.','player');outcome='조용한 시간이 마음을 가볍게 했습니다. 예린에게도 작은 기억이 생겼어요.';}
 p.energy=Math.max(0,p.energy);p.money=Math.max(0,p.money);world.lastRealAt=now;tick(world,elapsed);return outcome;}
export function chooseNpcReply(npc,kind,world){const known=npc.memory.some(m=>m.text.includes('플레이어'));if(kind==='greet')return known?`“또 만나네요. 지난번에 ${npc.location}에서 나눈 얘기가 생각났어요.”`:`“안녕하세요. 이 동네에서 본 적 있던가요?”`;if(kind==='ask'){if(npc.goalCompleted)return '“말해두었던 바람을 이뤘어요. 요즘은 다음에 해보고 싶은 일을 천천히 생각해요.”';if(npc.goalProgress>=65)return '“바라던 일에 한 걸음 더 가까워졌어요. 이제 마무리할 방법을 생각하고 있어요.”';if(npc.goalProgress>=30)return '“바라던 일을 위해 조금씩 준비하고 있어요. 서두르지 않아도 괜찮아요.”';return `“요즘은 ${npc.goal} 생각을 자주 해요. 천천히 해보려고요.”`;}if(kind==='hobby')return `“좋아하는 건 ${npc.preferences.join(', ')}이에요. 요즘은 ${npc.goal}도 생각하고 있어요.”`;if(kind==='help')return `“마음 써줘서 고마워요. 오늘은 제가 먼저 방법을 찾아볼게요.”`;if(kind==='ignore')return `“네, 다음에 또 봐요. 와줘서 고마워요.”`;return `“오늘은 ${npc.location}에 있었어요. 평범하지만 나쁘지 않은 하루네요.”`;}
export function respondToNpc(world,npcId,kind){const npc=world.npcs.find(n=>n.id===npcId);if(!npc||!['ask','hobby','help','ignore'].includes(kind))return null;world.daysAway=0;const response=chooseNpcReply(npc,kind,world);if(kind!=='ignore'){const memories={ask:'안부를 물었다',hobby:'좋아하는 것을 물었다',help:'도움을 제안했다'};remember(npc,{day:world.day,text:`플레이어가 ${memories[kind]}.`,importance:kind==='hobby'?2:3});deepenPlayerRelationship(world,npc,1);world.player.energy=Math.max(0,world.player.energy-2);}const message=kind==='ignore'?`당신은 ${npc.name}에게 인사하고 오늘은 먼저 자리를 떴습니다.`:`당신과 ${npc.name}은(는) 잠시 이야기를 나눴습니다.`;const record=event(world,message,'player');tick(world,20);return {response,event:record};}
export function serialize(world){return JSON.stringify(world);}
function isRecord(value){return value!==null&&typeof value==='object'&&!Array.isArray(value);}
function restore(value,now){try{const w=JSON.parse(value);if(!isRecord(w)||w.version!==1||!Array.isArray(w.npcs)||w.npcs.length!==NPC_SEED.length||!Array.isArray(w.events)||!w.events.every(e=>isRecord(e)&&typeof e.text==='string')||!isRecord(w.player))return null;
  if(!Number.isInteger(w.day)||w.day<1||!Number.isInteger(w.hour)||w.hour<0||w.hour>23||!Number.isInteger(w.minute)||w.minute<0||w.minute>59)return null;
  const p=w.player;if(!Number.isFinite(p.energy)||p.energy<0||p.energy>100||!Number.isFinite(p.money)||p.money<0)return null;
  p.x=Number.isFinite(p.x)?Math.max(.06,Math.min(.94,p.x)):.49;p.y=Number.isFinite(p.y)?Math.max(.08,Math.min(.91,p.y)):.5;p.affinity=isRecord(p.affinity)?p.affinity:{};p.location=typeof p.location==='string'?p.location:'골목';
  for(let i=0;i<w.npcs.length;i++){const n=w.npcs[i],seed=NPC_SEED.find(person=>person.id===n?.id);if(!isRecord(n)||!seed||!Number.isFinite(n.energy)||n.energy<0||n.energy>100||!Number.isFinite(n.hunger)||n.hunger<0||n.hunger>100||!Number.isFinite(n.social)||n.social<0||n.social>100)return null;n.affinity=isRecord(n.affinity)?n.affinity:{};n.memory=Array.isArray(n.memory)?n.memory.filter(m=>isRecord(m)&&typeof m.text==='string'):[];n.location=typeof n.location==='string'?n.location:seed.home;n.home=typeof n.home==='string'?n.home:seed.home;n.schedule=Array.isArray(n.schedule)?n.schedule:seed.schedule;n.traits=Array.isArray(n.traits)?n.traits:seed.traits;n.background=typeof n.background==='string'?n.background:seed.background;n.values=Array.isArray(n.values)?n.values:seed.values;n.preferences=Array.isArray(n.preferences)?n.preferences:seed.preferences;n.goal=typeof n.goal==='string'?n.goal:seed.goal;n.goalProgress=Number.isFinite(n.goalProgress)?Math.max(0,Math.min(100,n.goalProgress)):0;n.goalMilestones=Array.isArray(n.goalMilestones)?n.goalMilestones.filter(x=>[30,65,100].includes(x)):[];n.goalCompleted=typeof n.goalCompleted==='boolean'?n.goalCompleted:n.goalProgress>=100;n.playerAffinityDay=Number.isInteger(n.playerAffinityDay)&&n.playerAffinityDay>0?n.playerAffinityDay:0;n.playerAffinityToday=Number.isFinite(n.playerAffinityToday)?Math.max(0,Math.min(2,n.playerAffinityToday)):0;}
  if(!Number.isFinite(w.lastRealAt))w.lastRealAt=now;if(!Number.isSafeInteger(w.nextEventId))w.nextEventId=w.events.length+1;if(!Number.isInteger(w.seed)||w.seed<0)w.seed=1;if(!Number.isFinite(w.daysAway))w.daysAway=0;if(typeof w.paused!=='boolean')w.paused=false;return catchUp(w,now);
 }catch{return null;}}
export function deserialize(value,now=Date.now()){return restore(value,now)||newWorld(now);}
export function loadWorld(storage,now=Date.now(),seed=1){try{const primary=storage.getItem(SAVE_KEY);const current=restore(primary,now);if(current)return current;const backup=restore(storage.getItem(BACKUP_KEY),now);if(backup){storage.setItem(SAVE_KEY,serialize(backup));return backup;}}catch{}return newWorld(now,seed);}
export function saveWorld(storage,world){const previous=storage.getItem(SAVE_KEY);if(previous&&restore(previous,world.lastRealAt))storage.setItem(BACKUP_KEY,previous);storage.setItem(SAVE_KEY,serialize(world));}
