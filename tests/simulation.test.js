import test from 'node:test';
import assert from 'node:assert/strict';
import {newWorld,tick,playerAction,catchUp,serialize,deserialize,chooseNpcReply} from '../src/simulation.js';

test('world advances deterministically and NPCs keep distinct schedules',()=>{
  const a=newWorld(0,91),b=newWorld(0,91);tick(a,24*60);tick(b,24*60);
  assert.equal(a.day,2);assert.deepEqual(a.npcs.map(n=>n.location),b.npcs.map(n=>n.location));
  assert.equal(new Set(a.npcs.map(n=>n.location)).size>1,true);
});
test('player actions create durable memories and visible consequences',()=>{
  const w=newWorld(1000);const before=w.player.money;playerAction(w,'work',2000);
  assert.equal(w.player.money,before+12);assert.ok(w.npcs.find(n=>n.id==='minjae').memory.some(m=>m.text.includes('플레이어')));
  assert.ok(w.player.energy<82);assert.ok(w.events.some(e=>e.kind==='player'));
});
test('catch-up applies bounded elapsed time once and ignores clock rollback',()=>{
  const w=newWorld(1000);catchUp(w,1000+2*24*60*60*1000);assert.ok(w.day>=3);const day=w.day;
  catchUp(w,100);assert.equal(w.day,day);assert.equal(w.lastRealAt,100);
});
test('save data round-trips and invalid versions recover to a fresh world',()=>{
  const w=newWorld(1000);w.player.money=33;const restored=deserialize(serialize(w),1000);
  assert.equal(restored.player.money,33);assert.equal(deserialize('{"version":900}',1000).version,1);
});
test('NPCs can answer help with a self-directed alternative',()=>{
  const w=newWorld(1000),n=w.npcs[0];assert.match(chooseNpcReply(n,'help',w),/제가 먼저 방법을 찾아볼게요/);
});
test('seven simulated days preserve bounded needs and include NPC-to-NPC life',()=>{
  const w=newWorld(1000,1);tick(w,7*24*60);
  assert.ok(w.day>=7);for(const n of w.npcs){assert.ok(n.energy>=0&&n.energy<=100);assert.ok(n.hunger>=0&&n.hunger<=100);assert.ok(n.memory.length<100);}
  assert.ok(w.events.some(e=>e.kind==='minor'),'scheduled NPC overlap should produce an observable interaction');
});
