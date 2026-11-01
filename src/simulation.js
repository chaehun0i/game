export const DAY_MS = 24 * 60 * 60 * 1000;
export const SAVE_KEY='haeondong-world-v1';
export const BACKUP_KEY='haeondong-world-backup-v1';
export const NPC_SEED = [
  { id:'yun', name:'윤', role:'동네 책방 주인', home:'서점', workplace:'서점', dailyWage:8, color:'#d6e3d1', ink:'#4e6d50', traits:['차분함','관찰력이 좋아요'], background:'이 동네에서 책방을 오래 지켜 온 사람입니다.', values:['책을 나누는 일','약속 지키기'], preferences:['조용한 아침 산책','오래된 소설'], energy:82, hunger:26, social:44, money:86, affinity:{}, schedule:['서점','서점','골목','도서관','서점','공원','서점'], goal:'책방에 작은 책 교환 서가를 만들고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'minjae', name:'민재', role:'카페 바리스타', home:'카페', workplace:'카페', dailyWage:9, color:'#edddc9', ink:'#9b704e', traits:['사교적','새로운 것을 좋아해요'], background:'여러 곳을 다니다가 해온동 카페에 자리 잡았습니다.', values:['새로운 경험','먼저 인사하기'], preferences:['인디 음악','새로운 원두'], energy:73, hunger:36, social:31, money:52, affinity:{}, schedule:['카페','카페','공원','카페','도서관','카페','골목'], goal:'작은 음악 모임을 열고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'yerin', name:'예린', role:'도서관 사서', home:'도서관', workplace:'도서관', dailyWage:8, color:'#e5dced', ink:'#806894', traits:['신중함','남을 잘 챙겨요'], background:'어릴 때부터 도서관에서 보내는 시간을 좋아했습니다.', values:['차분한 배려','꾸준히 배우기'], preferences:['독립서점 구경','식물 기르기'], energy:88, hunger:22, social:53, money:71, affinity:{}, schedule:['도서관','도서관','카페','공원','도서관','골목','도서관'], goal:'읽고 싶은 책 목록을 완성하고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'sua', name:'수아', role:'꽃집 주인', home:'꽃집', workplace:'꽃집', dailyWage:9, color:'#f0d9d8', ink:'#a85d69', traits:['다정함','세심해요'], background:'계절마다 달라지는 동네 풍경을 꽃으로 기록합니다.', values:['작은 아름다움','정직한 거래'], preferences:['들꽃 산책','꽃꽂이'], energy:80, hunger:31, social:47, money:64, affinity:{}, schedule:['꽃집','꽃집','공원','꽃집','시장','꽃집','골목'], goal:'동네 꽃으로 작은 전시를 열고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'dohyeon', name:'도현', role:'우편 배달원', home:'우체국', workplace:'우체국', dailyWage:8, color:'#d6e4ec', ink:'#4e7185', traits:['성실함','길을 잘 기억해요'], background:'해온동 골목마다 누가 사는지 잘 알고 있습니다.', values:['전할 말을 빠뜨리지 않기','꾸준함'], preferences:['자전거 정비','따뜻한 차'], energy:84, hunger:34, social:39, money:58, affinity:{}, schedule:['우체국','골목','우체국','시장','우체국','골목','공원'], goal:'오래된 편지를 주인에게 전하고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'gaeun', name:'가은', role:'공방 목공예가', home:'공방', workplace:'공방', dailyWage:10, color:'#e9dfc9', ink:'#887149', traits:['집중력이 좋아요','솔직해요'], background:'낡은 가구를 고치며 물건에 남은 이야기를 상상합니다.', values:['오래 쓰는 물건','손으로 익히기'], preferences:['나무 냄새','고장 난 물건 수리'], energy:77, hunger:29, social:58, money:92, affinity:{}, schedule:['공방','공방','골목','공원','공방','시장','공방'], goal:'이웃이 함께 쓰는 수리 작업대를 만들고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'junho', name:'준호', role:'시장 채소 가게 직원', home:'시장', workplace:'시장', dailyWage:8, color:'#dfe8cf', ink:'#5d7747', traits:['활달함','손이 빨라요'], background:'새벽 시장에서 배운 요령으로 가게를 돕습니다.', values:['제철 재료','서로 돕기'], preferences:['새벽 공기','간단한 요리'], energy:75, hunger:40, social:35, money:46, affinity:{}, schedule:['시장','시장','시장','골목','시장','공원','시장'], goal:'남는 채소를 이웃과 나누고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'daeun', name:'다은', role:'카페 음악 강사', home:'카페', workplace:'카페', dailyWage:9, color:'#e7d8ec', ink:'#795b8b', traits:['호기심이 많아요','격려를 잘해요'], background:'작은 모임에서 함께 연주하는 즐거움을 나누고 싶어 합니다.', values:['함께 만드는 소리','배움의 기회'], preferences:['통기타','낯선 노래 듣기'], energy:79, hunger:27, social:42, money:73, affinity:{}, schedule:['카페','학교','카페','공원','학교','카페','골목'], goal:'초보자도 참여할 수 있는 연주 모임을 만들고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'taeo', name:'태오', role:'학교 교사', home:'학교', workplace:'학교', dailyWage:10, color:'#d9e2ee', ink:'#526b89', traits:['차분함','설명을 좋아해요'], background:'동네 아이들이 무엇에 관심 있는지 자주 살핍니다.', values:['궁금해할 시간','공정한 기회'], preferences:['별자리 관찰','어려운 질문'], energy:86, hunger:24, social:51, money:81, affinity:{}, schedule:['학교','학교','도서관','학교','공원','학교','골목'], goal:'동네에 열린 저녁 수업을 마련하고 싶다', goalProgress:0, goalMilestones:[], memory:[] },
  { id:'somin', name:'소민', role:'재택 번역가', home:'집', workplace:'집', dailyWage:7, color:'#eadfd3', ink:'#8b6c52', traits:['신중함','말을 아껴요'], background:'다른 사람의 문장을 옮기며 자기만의 리듬을 찾습니다.', values:['정확한 표현','혼자 쉬는 시간'], preferences:['창가의 화분','비 오는 날'], energy:82, hunger:32, social:66, money:55, affinity:{}, schedule:['집','집','도서관','집','카페','집','공원'], goal:'오래 미뤄 둔 번역 원고를 끝내고 싶다', goalProgress:0, goalMilestones:[], memory:[] }
];
export const PLACE_POSITIONS={골목:[.50,.50],집:[.14,.24],서점:[.38,.24],우체국:[.63,.24],학교:[.87,.24],시장:[.14,.73],카페:[.38,.73],꽃집:[.63,.73],도서관:[.87,.73],공방:[.5,.42],공원:[.5,.58]};
const DAY_NAMES=['첫째 날','둘째 날','셋째 날','넷째 날','다섯째 날','여섯째 날','일곱째 날','여덟째 날','아홉째 날','열째 날'];
export const dayName=n=>n<=DAY_NAMES.length?DAY_NAMES[Math.max(0,n-1)]:`${n}일째`;
export function newWorld(now=Date.now(),seed=1){const npcs=structuredClone(NPC_SEED);for(const npc of npcs)npc.location=npc.home;return {version:2,day:1,hour:8,minute:0,lastRealAt:now,seed,nextEventId:1,paused:false,player:{energy:82,hunger:28,money:18,location:'골목',x:.49,y:.50,affinity:{}},npcs,events:[{id:'welcome',day:1,hour:8,text:'당신이 해온동에 이사 왔습니다. 동네는 오늘도 천천히 깨어납니다.',kind:'ordinary'}],seenEvents:[],daysAway:0};}
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
function socialize(world,a,b,kind='minor'){
 a.lastSocialDay=b.lastSocialDay=world.day;a.social=Math.max(0,a.social-8);b.social=Math.max(0,b.social-8);
 a.affinity[b.id]=(a.affinity[b.id]||0)+1;b.affinity[a.id]=(b.affinity[a.id]||0)+1;
 const text=kind==='evening'?`${a.name}은(는) 저녁에 ${b.name}에게 안부를 물었습니다.`:`${a.name}와 ${b.name}이(가) ${a.location}에서 잠깐 이야기를 나눴습니다.`;
 remember(a,{day:world.day,text,importance:2});remember(b,{day:world.day,text,importance:2});event(world,text,kind==='minor'?'minor':'ordinary');
}
function npcStep(world){const h=world.hour;for(const n of world.npcs){n.hunger=Math.min(100,n.hunger+1.2);n.energy=Math.max(4,Math.min(100,n.energy+(h>=22||h<7?1.4:-1.1)));n.social=Math.min(100,n.social+.14);
 let place=h<7?'집':(h>=22?'집':n.schedule[(world.day-1)%n.schedule.length]);
 if(h===8&&n.id==='minjae')place='카페'; if(h===9&&n.id==='yun')place='서점';if(h===10&&n.id==='yerin')place='도서관';
 n.location=place;
 const goalHour={yun:10,minjae:18,yerin:15}[n.id]??10;
 if(h===goalHour&&place===n.workplace)advanceGoal(world,n,10);
 if((h===8||h===12||h===19)&&n.hunger>48){const boughtMeal=n.money>=2;if(boughtMeal)n.money-=2;n.hunger=Math.max(8,n.hunger-(boughtMeal?32:16));if(h===12&&randomFor(world)<.18)event(world,`${n.name}은(는) 골목에서 간단히 점심을 먹었습니다.`);}
 if(h===18&&n.energy<65)n.energy=Math.min(100,n.energy+6);
 if(h===18&&place===n.workplace&&n.lastPaidDay!==world.day){n.money+=n.dailyWage;n.lastPaidDay=world.day;}
 }
 if(world.hour===11||world.hour===16){const groups=new Map();for(const n of world.npcs){if(n.location==='집'||n.lastSocialDay===world.day)continue;const group=groups.get(n.location)||[];group.push(n);groups.set(n.location,group);}for(const [place,group] of groups){if(group.length<2||randomFor(world)>.52)continue;group.sort((a,b)=>b.social-a.social);const [a,b]=group;a.location=b.location=place;socialize(world,a,b);}}
 if(world.hour===20){const available=world.npcs.filter(n=>n.lastSocialDay!==world.day).sort((a,b)=>b.social-a.social);const n=available[0];if(n&&randomFor(world)<(n.social>70?.75:.18)){if(n.social>60&&available.length>1){const other=available.find(person=>person.id!==n.id);socialize(world,n,other,'evening');}else{event(world,`${n.name}은(는) 오늘 있었던 일을 조용히 돌아봅니다.`);remember(n,{day:world.day,text:'오늘을 돌아보며 마음에 남는 일이 있었다.',importance:1});}}}
}
export function tick(world,minutes=10){for(let i=0;i<minutes;i+=10){world.minute+=10;if(world.minute>=60){world.minute=0;world.hour++;npcStep(world);}if(world.hour>=24){world.hour=0;world.day++;event(world,`${dayName(world.day)}이 시작됐습니다. 해온동에 새로운 아침이 옵니다.`);}world.player.hunger=Math.min(100,(world.player.hunger??28)+.12);world.player.energy=Math.max(0,Math.min(100,world.player.energy-(world.player.hunger>78?.08:.04)));}return world;}
function placeFor(x,y){const closest=Object.entries(PLACE_POSITIONS).map(([name,position])=>({name,distance:(position[0]-x)**2+(position[1]-y)**2})).sort((a,b)=>a.distance-b.distance)[0];return closest.distance<.105**2+.12**2?closest.name:'골목';}
export function movePlayer(world,dx,dy){const p=world.player;p.x=Math.max(.06,Math.min(.94,(p.x??.49)+dx));p.y=Math.max(.08,Math.min(.91,(p.y??.5)+dy));p.location=placeFor(p.x,p.y);return p.location;}
export function movePlayerTo(world,x,y){const p=world.player;p.x=Math.max(.06,Math.min(.94,x));p.y=Math.max(.08,Math.min(.91,y));p.location=placeFor(p.x,p.y);return p.location;}
export function catchUp(world,now=Date.now()){const previous=Number.isFinite(world.lastRealAt)?world.lastRealAt:now;const checkpoint=Math.max(now,previous);const elapsed=Math.max(0,Math.min(checkpoint-previous,30*DAY_MS));world.daysAway=elapsed>=DAY_MS?Math.floor(elapsed/DAY_MS):0;const minutes=Math.floor(elapsed/60000);const step=Math.min(Math.floor(minutes/10)*10,30*24*60);if(step)tick(world,step);world.lastRealAt=checkpoint;return world;}
export function playerAction(world,action,now=Date.now()){const p=world.player;world.daysAway=0;let outcome='',elapsed=20;if(action==='work'){elapsed=120;p.money+=12;p.energy=Math.max(0,p.energy-18);p.location='카페';[p.x,p.y]=PLACE_POSITIONS.카페;const n=world.npcs.find(x=>x.id==='minjae');deepenPlayerRelationship(world,n,1);advanceGoal(world,n,15);remember(n,{day:world.day,text:'플레이어가 카페에서 함께 일해 주었다.',importance:3});n.social=Math.max(0,n.social-9);event(world,'카페에서 두 시간 일해 12원을 받았습니다. 민재가 고맙게 웃었습니다.','player');outcome='함께 일한 시간이 민재의 기억에 남았습니다. 12원을 벌었지만 기운은 줄었습니다.';}
 else if(action==='talk'){const n=world.npcs.filter(x=>x.location!=='집').sort((a,b)=>Math.abs(a.social-45)-Math.abs(b.social-45))[0]||world.npcs[0];p.location=n.location;[p.x,p.y]=PLACE_POSITIONS[n.location]||PLACE_POSITIONS.골목;p.energy=Math.max(0,p.energy-3);deepenPlayerRelationship(world,n,2);n.social=Math.max(0,n.social-14);remember(n,{day:world.day,text:`플레이어가 먼저 말을 걸어 안부를 물었다.`,importance:3});event(world,`${n.name}과(와) 잠시 이야기를 나눴습니다. 다음에 만나면 오늘을 기억할 거예요.`,'player');outcome=`${n.name}은(는) 오늘의 대화를 기억합니다. 가까워지는 데는 시간이 더 필요해요.`;}
 else if(action==='rest'){elapsed=180;p.energy=Math.min(100,p.energy+38);p.location='집';[p.x,p.y]=PLACE_POSITIONS.집;event(world,'집에서 여유롭게 쉬었습니다. 동네의 시간은 계속 흘렀습니다.','player');outcome='기운을 회복했습니다. 쉬는 동안 이웃들의 하루도 이어졌습니다.';}
 else if(action==='hobby'){elapsed=60;p.energy=Math.max(0,p.energy-7);p.location='도서관';[p.x,p.y]=PLACE_POSITIONS.도서관;const n=world.npcs.find(x=>x.id==='yerin');deepenPlayerRelationship(world,n,1);advanceGoal(world,n,15);remember(n,{day:world.day,text:'플레이어가 도서관에서 조용히 책을 읽었다.',importance:2});event(world,'도서관에서 책을 읽었습니다. 예린은 당신이 책을 읽은 모습을 기억해 두었습니다.','player');outcome='조용한 시간이 마음을 가볍게 했습니다. 예린에게도 작은 기억이 생겼어요.';}
 else if(action==='eat'){if(p.money<4){elapsed=0;outcome='간단한 식사를 살 돈이 부족합니다. 카페에서 일하면 다시 마련할 수 있어요.';}else{elapsed=15;p.money-=4;p.hunger=Math.max(0,(p.hunger??28)-48);p.energy=Math.min(100,p.energy+8);p.location='카페';[p.x,p.y]=PLACE_POSITIONS.카페;event(world,'카페에서 간단히 식사했습니다. 허기가 가시고 기운이 조금 돌아왔습니다.','player');outcome='식사로 허기를 달랬습니다. 가진 돈은 4원 줄었습니다.';}}
 p.energy=Math.max(0,p.energy);p.hunger=Math.max(0,Math.min(100,p.hunger??28));p.money=Math.max(0,p.money);world.lastRealAt=now;tick(world,elapsed);return outcome;}
export function chooseNpcReply(npc,kind,world){const known=npc.memory.some(m=>m.text.includes('플레이어'));if(kind==='greet')return known?`“또 만나네요. 지난번에 ${npc.location}에서 나눈 얘기가 생각났어요.”`:`“안녕하세요. 이 동네에서 본 적 있던가요?”`;if(kind==='ask'){if(npc.goalCompleted)return '“말해두었던 바람을 이뤘어요. 요즘은 다음에 해보고 싶은 일을 천천히 생각해요.”';if(npc.goalProgress>=65)return '“바라던 일에 한 걸음 더 가까워졌어요. 이제 마무리할 방법을 생각하고 있어요.”';if(npc.goalProgress>=30)return '“바라던 일을 위해 조금씩 준비하고 있어요. 서두르지 않아도 괜찮아요.”';return `“요즘은 ${npc.goal} 생각을 자주 해요. 천천히 해보려고요.”`;}if(kind==='hobby')return `“좋아하는 건 ${npc.preferences.join(', ')}이에요. 요즘은 ${npc.goal}도 생각하고 있어요.”`;if(kind==='help')return `“마음 써줘서 고마워요. 오늘은 제가 먼저 방법을 찾아볼게요.”`;if(kind==='ignore')return `“네, 다음에 또 봐요. 와줘서 고마워요.”`;return `“오늘은 ${npc.location}에 있었어요. 평범하지만 나쁘지 않은 하루네요.”`;}
export function respondToNpc(world,npcId,kind){const npc=world.npcs.find(n=>n.id===npcId);if(!npc||!['ask','hobby','help','ignore'].includes(kind))return null;world.daysAway=0;const response=chooseNpcReply(npc,kind,world);if(kind!=='ignore'){const memories={ask:'안부를 물었다',hobby:'좋아하는 것을 물었다',help:'도움을 제안했다'};remember(npc,{day:world.day,text:`플레이어가 ${memories[kind]}.`,importance:kind==='hobby'?2:3});deepenPlayerRelationship(world,npc,1);world.player.energy=Math.max(0,world.player.energy-2);}const message=kind==='ignore'?`당신은 ${npc.name}에게 인사하고 오늘은 먼저 자리를 떴습니다.`:`당신과 ${npc.name}은(는) 잠시 이야기를 나눴습니다.`;const record=event(world,message,'player');tick(world,20);return {response,event:record};}
export function serialize(world){return JSON.stringify(world);}
function isRecord(value){return value!==null&&typeof value==='object'&&!Array.isArray(value);}
function restore(value,now){
 try{
  const w=JSON.parse(value);
  if(!isRecord(w)||![1,2].includes(w.version)||!Array.isArray(w.npcs)||w.npcs.length<1||w.npcs.length>NPC_SEED.length||!Array.isArray(w.events)||!w.events.every(e=>isRecord(e)&&typeof e.text==='string')||!isRecord(w.player))return null;
  if(!Number.isInteger(w.day)||w.day<1||!Number.isInteger(w.hour)||w.hour<0||w.hour>23||!Number.isInteger(w.minute)||w.minute<0||w.minute>59)return null;
  const savedNpcs=new Map();
  for(const saved of w.npcs){
   if(!isRecord(saved)||!NPC_SEED.some(seed=>seed.id===saved.id)||savedNpcs.has(saved.id)||!Number.isFinite(saved.energy)||saved.energy<0||saved.energy>100||!Number.isFinite(saved.hunger)||saved.hunger<0||saved.hunger>100||!Number.isFinite(saved.social)||saved.social<0||saved.social>100)return null;
   savedNpcs.set(saved.id,saved);
  }
  const p=w.player;if(!Number.isFinite(p.energy)||p.energy<0||p.energy>100||!Number.isFinite(p.money)||p.money<0)return null;
  p.x=Number.isFinite(p.x)?Math.max(.06,Math.min(.94,p.x)):.49;p.y=Number.isFinite(p.y)?Math.max(.08,Math.min(.91,p.y)):.5;p.hunger=Number.isFinite(p.hunger)?Math.max(0,Math.min(100,p.hunger)):28;p.affinity=isRecord(p.affinity)?p.affinity:{};p.location=typeof p.location==='string'?p.location:'골목';if(w.version===1&&PLACE_POSITIONS[p.location])[p.x,p.y]=PLACE_POSITIONS[p.location];
  w.npcs=NPC_SEED.map(seed=>{
   const n={...structuredClone(seed),...(savedNpcs.get(seed.id)||{})};
   n.affinity=isRecord(n.affinity)?n.affinity:{};n.memory=Array.isArray(n.memory)?n.memory.filter(m=>isRecord(m)&&typeof m.text==='string'):[];
   n.location=typeof n.location==='string'?n.location:seed.home;n.home=typeof n.home==='string'?n.home:seed.home;n.workplace=typeof n.workplace==='string'?n.workplace:seed.workplace;
   n.dailyWage=Number.isFinite(n.dailyWage)&&n.dailyWage>=0?Math.min(1000,n.dailyWage):seed.dailyWage;n.money=Number.isFinite(n.money)&&n.money>=0?n.money:seed.money;
   n.schedule=Array.isArray(n.schedule)&&n.schedule.length?n.schedule:seed.schedule;n.traits=Array.isArray(n.traits)?n.traits:seed.traits;n.background=typeof n.background==='string'?n.background:seed.background;n.values=Array.isArray(n.values)?n.values:seed.values;n.preferences=Array.isArray(n.preferences)?n.preferences:seed.preferences;n.goal=typeof n.goal==='string'?n.goal:seed.goal;
   n.goalProgress=Number.isFinite(n.goalProgress)?Math.max(0,Math.min(100,n.goalProgress)):0;n.goalMilestones=Array.isArray(n.goalMilestones)?n.goalMilestones.filter(x=>[30,65,100].includes(x)):[];n.goalCompleted=typeof n.goalCompleted==='boolean'?n.goalCompleted:n.goalProgress>=100;
   n.playerAffinityDay=Number.isInteger(n.playerAffinityDay)&&n.playerAffinityDay>0?n.playerAffinityDay:0;n.playerAffinityToday=Number.isFinite(n.playerAffinityToday)?Math.max(0,Math.min(2,n.playerAffinityToday)):0;n.lastPaidDay=Number.isInteger(n.lastPaidDay)&&n.lastPaidDay>0?n.lastPaidDay:0;n.lastSocialDay=Number.isInteger(n.lastSocialDay)&&n.lastSocialDay>0?n.lastSocialDay:0;
   return n;
  });
  const expandedFromP0=w.version===1&&savedNpcs.size<NPC_SEED.length;w.version=2;if(!Number.isFinite(w.lastRealAt))w.lastRealAt=now;if(!Number.isSafeInteger(w.nextEventId))w.nextEventId=w.events.length+1;if(!Number.isInteger(w.seed)||w.seed<0)w.seed=1;if(!Number.isFinite(w.daysAway))w.daysAway=0;if(typeof w.paused!=='boolean')w.paused=false;if(expandedFromP0)event(w,'해온동에 새 이웃들이 찾아왔습니다. 오늘의 얼굴에서 각자의 생활을 만나보세요.');return catchUp(w,now);
 }catch{return null;}
}export function deserialize(value,now=Date.now()){return restore(value,now)||newWorld(now);}
export function loadWorld(storage,now=Date.now(),seed=1){try{const primary=storage.getItem(SAVE_KEY);const current=restore(primary,now);if(current)return current;const backup=restore(storage.getItem(BACKUP_KEY),now);if(backup){storage.setItem(SAVE_KEY,serialize(backup));return backup;}}catch{}return newWorld(now,seed);}
export function saveWorld(storage,world){const previous=storage.getItem(SAVE_KEY);if(previous&&restore(previous,world.lastRealAt))storage.setItem(BACKUP_KEY,previous);storage.setItem(SAVE_KEY,serialize(world));}
