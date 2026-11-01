import test from 'node:test';
import assert from 'node:assert/strict';
import {newWorld,tick,movePlayer,movePlayerTo,playerAction,catchUp,serialize,deserialize,chooseNpcReply,respondToNpc,loadWorld,saveWorld,SAVE_KEY,BACKUP_KEY,dayName,NPC_SEED,PLACE_POSITIONS,eventsKnownToPlayer} from '../src/simulation.js';

test('calendar labels remain unique after the first ten days',()=>{
  assert.equal(dayName(1),'첫째 날');assert.equal(dayName(10),'열째 날');assert.equal(dayName(11),'11일째');
});

test('world advances deterministically and NPCs keep distinct schedules',()=>{
  const a=newWorld(0,91),b=newWorld(0,91);tick(a,24*60);tick(b,24*60);
  assert.equal(a.day,2);assert.deepEqual(a.npcs.map(n=>n.location),b.npcs.map(n=>n.location));
  assert.equal(new Set(a.npcs.map(n=>n.location)).size>1,true);
});
test('expanded neighborhood has ten distinct residents with jobs and valid destinations',()=>{
  const w=newWorld(1000);assert.equal(w.version,4);assert.equal(w.npcs.length,10);assert.equal(new Set(w.npcs.map(n=>n.id)).size,10);
  for(const n of w.npcs){assert.ok(n.role);assert.ok(n.workplace);assert.ok(n.dailyWage>0);assert.equal(PLACE_POSITIONS[n.home]?.length,2);assert.equal(n.location,n.home);}
  assert.equal(NPC_SEED.length,10);
  for(const [place,position] of Object.entries(PLACE_POSITIONS))assert.equal(movePlayerTo(w,...position),place,`${place} should be reachable on the map`);
});
test('player actions create durable memories and visible consequences',()=>{
  const w=newWorld(1000);const before=w.player.money;playerAction(w,'work',2000);
  assert.equal(w.player.money,before+12);assert.ok(w.npcs.find(n=>n.id==='minjae').memory.some(m=>m.text.includes('플레이어')));
  assert.equal(w.player.affinity.minjae,w.npcs.find(n=>n.id==='minjae').affinity.player);
  assert.ok(w.player.energy<82);assert.ok(w.events.some(e=>e.kind==='player'));
});
test('quiet hobby leaves a reciprocal relationship and memory',()=>{
  const w=newWorld(1000);playerAction(w,'hobby',2000);const yerin=w.npcs.find(n=>n.id==='yerin');
  assert.equal(w.player.affinity.yerin,1);assert.equal(yerin.affinity.player,1);
  assert.ok(yerin.memory.some(m=>m.text.includes('책을 읽었다')));
  assert.ok(w.events.some(e=>e.text.includes('예린')));
});
test('player can buy a meal and workday wages circulate in the neighborhood',()=>{
  const w=newWorld(1000);const money=w.player.money;playerAction(w,'eat',2000);
  assert.equal(w.player.money,money-4);assert.ok(w.player.hunger<1);
  const worker=w.npcs.find(n=>n.id==='sua'),before=worker.money;tick(w,10*60);
  assert.equal(worker.money,before+worker.dailyWage);assert.equal(worker.lastPaidDay,1);
});
test('NPCs advance personal goals without the player and player activities can help',()=>{
  const independent=newWorld(1000,14);tick(independent,7*24*60);
  for(const npc of independent.npcs){assert.ok(npc.goalProgress>=30,`${npc.name} should make independent progress`);assert.ok(npc.goalMilestones.includes(30));}
  assert.ok(independent.events.some(e=>e.text.includes('준비를 시작했습니다')));
  const helped=newWorld(1000,14);playerAction(helped,'work',2000);
  assert.equal(helped.npcs.find(n=>n.id==='minjae').goalProgress,15);
  assert.equal(helped.npcs.find(n=>n.id==='yerin').goalProgress,0);
});
test('private NPC milestones stay hidden until observed or heard from a neighbor',()=>{
  const w=newWorld(1000);w.npcs.find(n=>n.id==='yun').goalProgress=25;tick(w,120);
  const privateEvent=w.events.find(e=>e.knownBy?.includes('yun')&&e.text.includes('작은 준비를 시작했습니다'));
  assert.ok(privateEvent);assert.equal(privateEvent.playerKnown,false);assert.ok(!eventsKnownToPlayer(w).includes(privateEvent));
});
test('neighbors pass along rumors that can be asked about while private originals remain hidden',()=>{
  const w=newWorld(1000,1);tick(w,14*24*60);const neighbor=w.npcs.find(n=>n.rumors.length>0);
  assert.ok(neighbor,'NPCs should share some lived information');const rumor=neighbor.rumors[0];
  assert.ok(rumor.confidence>0&&rumor.confidence<=.85);assert.match(chooseNpcReply(neighbor,'news',w),/들었/);
  assert.doesNotMatch(rumor.text,/은\(는\)|이\(가\)|과\(와\)/);
  const original=w.events.find(e=>e.id===rumor.eventId);if(original)assert.equal(original.playerKnown,false);
  const asked=respondToNpc(w,neighbor.id,'news');assert.ok(asked);assert.match(asked.response,/들었/);
});
test('a low-confidence rumor can create a small misunderstanding that neighbors later resolve',()=>{
  const w=newWorld(1000,1);tick(w,90*24*60);
  assert.ok(w.tensions.length>0&&w.tensions.length<=10);
  assert.ok(w.tensions.some(t=>t.status==='resolved'&&t.resolvedDay>t.createdDay));
  assert.ok(w.events.some(e=>e.text.includes('작은 오해가 생겼습니다')&&e.playerKnown===false));
});
test('keyboard and map movement update bounded position and place through the simulation',()=>{
  const w=newWorld(1000);assert.equal(movePlayerTo(w,...PLACE_POSITIONS.도서관),'도서관');assert.equal(w.player.location,'도서관');
  assert.equal(movePlayerTo(w,...PLACE_POSITIONS.공원),'공원');assert.equal(movePlayer(w,5,5),'골목');assert.equal(w.player.x,.94);assert.equal(w.player.y,.91);
  assert.equal(movePlayer(w,-5,-5),'골목');assert.equal(w.player.x,.06);assert.equal(w.player.y,.08);
});
test('catch-up applies bounded elapsed time once and ignores clock rollback',()=>{
  const w=newWorld(1000);catchUp(w,1000+2*24*60*60*1000);assert.ok(w.day>=3);const day=w.day;
  const checkpoint=w.lastRealAt;catchUp(w,100);assert.equal(w.day,day);assert.equal(w.lastRealAt,checkpoint);
});
test('save data round-trips and invalid versions recover to a fresh world',()=>{
  const w=newWorld(1000);w.player.money=33;const restored=deserialize(serialize(w),1000);
  assert.equal(restored.player.money,33);assert.equal(deserialize('{"version":900}',1000).version,4);
});
test('older P0 saves are normalized before loading',()=>{
  const w=newWorld(1000);w.version=1;w.player.location='카페';w.player.money=27;w.player.affinity.yun=4;w.npcs=w.npcs.slice(0,3);delete w.player.x;delete w.player.y;delete w.player.hunger;delete w.player.affinity;w.player.affinity={yun:4};delete w.nextEventId;w.npcs[0].affinity=0;w.npcs[0].money=111;delete w.npcs[0].location;delete w.npcs[0].memory;delete w.npcs[0].preferences;delete w.npcs[0].goalProgress;delete w.npcs[0].goalMilestones;delete w.npcs[0].workplace;delete w.npcs[0].dailyWage;
  const restored=deserialize(serialize(w),1000);
  assert.equal(restored.version,4);assert.equal(restored.npcs.length,10);assert.deepEqual([restored.player.x,restored.player.y],PLACE_POSITIONS.카페);assert.equal(restored.player.money,27);assert.equal(restored.player.hunger,28);assert.equal(restored.player.affinity.yun,4);assert.deepEqual(restored.npcs[0].affinity,{});assert.equal(restored.npcs[0].money,111);assert.ok(restored.npcs[0].secret);assert.deepEqual(restored.npcs[0].rumors,[]);assert.deepEqual(restored.tensions,[]);
  assert.equal(restored.npcs[0].location,'서점');assert.deepEqual(restored.npcs[0].memory,[]);assert.ok(Number.isSafeInteger(restored.nextEventId));
  assert.deepEqual(restored.npcs[0].preferences,['조용한 아침 산책','오래된 소설']);
  assert.equal(restored.npcs[0].goalProgress,0);assert.deepEqual(restored.npcs[0].goalMilestones,[]);
  assert.ok(restored.events.some(e=>e.text.includes('새 이웃들이 찾아왔습니다')));
});
test('P1 saves upgrade their event knowledge metadata without losing player-visible history',()=>{
  const w=newWorld(1000);w.version=2;delete w.events[0].playerKnown;delete w.events[0].knownBy;delete w.npcs[0].secret;delete w.npcs[0].rumors;w.player.money=42;
  const restored=deserialize(serialize(w),1000);
  assert.equal(restored.version,4);assert.equal(restored.player.money,42);assert.ok(restored.npcs[0].secret);assert.deepEqual(restored.npcs[0].rumors,[]);assert.deepEqual(restored.tensions,[]);
  assert.deepEqual(eventsKnownToPlayer(restored).map(e=>e.id),['welcome']);assert.deepEqual(restored.events[0].knownBy,[]);
});
test('P2 save migration adds conflict state while preserving private event visibility',()=>{
  const w=newWorld(1000);w.version=3;delete w.tensions;w.events.unshift({id:'private-test',day:1,hour:9,text:'비공개 사건',kind:'minor',playerKnown:false,knownBy:['yun']});
  const restored=deserialize(serialize(w),1000);assert.equal(restored.version,4);assert.deepEqual(restored.tensions,[]);
  assert.equal(restored.events[0].playerKnown,false);assert.deepEqual(eventsKnownToPlayer(restored).map(e=>e.id),['welcome']);
});
test('active relationship tension survives a world save and load',()=>{
  const w=newWorld(1000);w.tensions=[{id:'tension-1',pair:'dohyeon|sua',participants:['sua','dohyeon'],status:'active',createdDay:3,sourceEventId:'event-3-4'}];
  const restored=deserialize(serialize(w),1000);assert.deepEqual(restored.tensions,w.tensions);
});
test('corrupt primary save restores the previous valid backup',()=>{
  const values=new Map();const storage={getItem:key=>values.get(key)??null,setItem:(key,value)=>values.set(key,String(value))};
  const first=newWorld(1000);first.player.money=35;saveWorld(storage,first);
  const second=structuredClone(first);second.player.money=88;second.lastRealAt=2000;saveWorld(storage,second);
  assert.equal(JSON.parse(storage.getItem(BACKUP_KEY)).player.money,35);
  storage.setItem(SAVE_KEY,'not valid JSON');const restored=loadWorld(storage,2000);
  assert.equal(restored.player.money,35);assert.equal(JSON.parse(storage.getItem(SAVE_KEY)).player.money,35);
});
test('NPCs can answer help with a self-directed alternative',()=>{
  const w=newWorld(1000),n=w.npcs[0];assert.match(chooseNpcReply(n,'help',w),/제가 먼저 방법을 찾아볼게요/);
  assert.match(chooseNpcReply(n,'hobby',w),/오래된 소설/);
  assert.match(chooseNpcReply(n,'ignore',w),/다음에 또 봐요/);
});
test('an NPC explains long-goal progress in a status conversation',()=>{
  const n=newWorld(1000).npcs[0];
  assert.match(chooseNpcReply(n,'ask',{}),/천천히 해보려고요/);
  n.goalProgress=30;assert.match(chooseNpcReply(n,'ask',{}),/조금씩 준비하고 있어요/);
  n.goalProgress=65;assert.match(chooseNpcReply(n,'ask',{}),/한 걸음 더 가까워졌어요/);
  n.goalCompleted=true;assert.match(chooseNpcReply(n,'ask',{}),/바람을 이뤘어요/);
});
test('private worries are shared only after a close relationship and are not exposed in event logs',()=>{
  const w=newWorld(1000);assert.equal(respondToNpc(w,'yun','confide'),null);w.player.affinity.yun=6;
  const result=respondToNpc(w,'yun','confide');assert.match(result.response,/월세/);assert.equal(result.event.kind,'secret');
  assert.deepEqual(result.event.knownBy,['yun','player']);assert.ok(eventsKnownToPlayer(w).includes(result.event));assert.equal(respondToNpc(w,'yun','confide'),null);
  tick(w,30*24*60);assert.ok(w.npcs.every(n=>!n.rumors.some(r=>r.eventId===result.event.id)),'a confidence shared with the player must not become a rumor');
});
test('NPC dialogue effects belong to simulation and allow a consequence-free goodbye',()=>{
  const w=newWorld(1000);const energy=w.player.energy;
  const asked=respondToNpc(w,'yun','ask');
  assert.ok(asked);assert.equal(w.player.affinity.yun,1);assert.equal(w.npcs[0].affinity.player,1);
  assert.ok(Math.abs(w.player.energy-(energy-2.08))<1e-9);assert.ok(w.npcs[0].memory[0].text.includes('안부'));
  const relation=w.player.affinity.minjae||0;const ignored=respondToNpc(w,'minjae','ignore');
  assert.ok(ignored);assert.equal(w.player.affinity.minjae||0,relation);assert.ok(Math.abs(w.player.energy-(energy-2.16))<1e-9);
  assert.notEqual(asked.event.id,ignored.event.id);assert.equal(respondToNpc(w,'missing','ask'),null);
});
test('repeated conversations deepen a relationship gradually and reset the next day',()=>{
  const w=newWorld(1000);for(let i=0;i<4;i++)respondToNpc(w,'yun','ask');
  assert.equal(w.player.affinity.yun,2);assert.equal(w.npcs[0].affinity.player,2);
  tick(w,16*60);assert.equal(w.day,2);respondToNpc(w,'yun','ask');
  assert.equal(w.player.affinity.yun,3);assert.equal(w.npcs[0].affinity.player,3);
});
test('seven simulated days preserve bounded needs and include NPC-to-NPC life',()=>{
  const w=newWorld(1000,1);tick(w,7*24*60);
  assert.ok(w.day>=7);for(const n of w.npcs){assert.ok(n.energy>=0&&n.energy<=100);assert.ok(n.hunger>=0&&n.hunger<=100);assert.ok(n.memory.length<100);}
  assert.ok(w.events.some(e=>e.kind==='minor'),'scheduled NPC overlap should produce an observable interaction');
});
test('ninety simulated days avoid need saturation and cap retained history',()=>{
  const w=newWorld(1000,1);tick(w,90*24*60);
  assert.ok(w.events.length<=40);
  const rumors=w.npcs.flatMap(n=>n.rumors);assert.ok(rumors.some(r=>r.confidence<.7),'repeated retellings should lower confidence');
  assert.ok(rumors.every(r=>r.confidence>=.35&&r.confidence<=.85));
  for(const n of w.npcs){
    assert.ok(n.energy>=0&&n.energy<=100);
    assert.ok(n.energy>=50,`${n.name} should recover energy through sleep`);
    assert.ok(n.hunger<80,`${n.name} hunger should recover through meals`);
    assert.ok(n.social<100,`${n.name} social need should ease through contact`);
    assert.ok(n.memory.length<=40);
  }
});
