const phone = document.querySelector('.phone');
const avatar = document.querySelector('#happy-avatar');
const label = document.querySelector('#happy-label');
const hint = document.querySelector('.selection-hint');
const next = document.querySelector('#next');
const dialog = document.querySelector('#confirmation');
const motionToggle = document.querySelector('#motion-toggle');
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
let celebrationTimer;
let mood = 0, chosen = null, suppressClick = false;
const names = ['Good', 'Meh', 'Down'];
const descriptions = ['Feeling good inside and out!', 'Taking the day as it comes.', 'A little rain. It’s okay to feel this way.'];
const scene = document.querySelector('.mood-scene');
for (let i=0;i<45;i++) {
 const drop=document.createElement('i');
 drop.style.cssText=`left:${(i*37)%100}%;--delay:${-i*.17}s;--duration:${.8+(i%5)*.13}s`;
 document.querySelector('.rain').append(drop);
}
function renderMood() {
 const selected = chosen === mood;
 phone.classList.toggle('sad',mood===2);
 phone.classList.toggle('neutral',mood===1);
 document.querySelector('.neutral-character').setAttribute('aria-hidden',String(mood!==1));
 document.querySelector('#happy-character').setAttribute('aria-hidden',String(mood!==0));
 document.querySelector('.sad-character').setAttribute('aria-hidden',String(mood!==2));
 phone.classList.toggle('selected',selected);
 label.textContent=mood === 0 ? 'Good' : names[mood];
 document.querySelector('.mood-description').textContent=descriptions[mood];
 for(const button of [avatar,label]) {button.setAttribute('aria-label',`Choose ${names[mood].toLowerCase()} mood`);button.setAttribute('aria-pressed',String(selected));}
 next.hidden=!selected;
 hint.textContent=`${names[mood]}, ${selected?'selected':'not selected'}. Swipe left or right to explore moods.`;
 scene.setAttribute('aria-label',['Good mood in a sunny meadow','Meh mood under a cloudy blue sky','Down mood in a rainy meadow'][mood]);
 document.querySelector('.preview-label').innerHTML=`<i></i> ${names[mood].toUpperCase()} · INTERACTIVE PREVIEW`;
}
let drag = null;
scene.style.touchAction='pan-y';
scene.addEventListener('pointerdown',e=>{if(e.button!==0)return;drag={x:e.clientX,y:e.clientY,dx:0};});
scene.addEventListener('pointermove',e=>{
 if(!drag)return;
 const dx=e.clientX-drag.x,dy=e.clientY-drag.y;
 if(Math.abs(dx)<8||Math.abs(dx)<Math.abs(dy))return;
 drag.dx=dx; suppressClick=true;
 scene.setPointerCapture(e.pointerId);
 scene.style.setProperty('--drag',`${Math.max(-110,Math.min(110,dx*.35))}px`);
 scene.classList.add('dragging');
});
function finishSwipe(e,cancelled=false){
 if(!drag)return;
 const dx=drag.dx;drag=null;
 scene.classList.remove('dragging');scene.style.setProperty('--drag','0px');
 if(!cancelled&&Math.abs(dx)>45)changeMood(mood+(dx<0?1:-1));
 setTimeout(()=>suppressClick=false,0);
}
scene.addEventListener('pointerup',e=>finishSwipe(e));
scene.addEventListener('pointercancel',e=>finishSwipe(e,true));
function changeMood(value){
 value=Math.max(0,Math.min(names.length-1,value));
 if(value===mood)return;
 mood=value;
 if(!reduceMotion.matches) document.querySelector('.mood-caption').animate([{opacity:.3,transform:'translateY(4px)'},{opacity:1,transform:'translateY(0)'}],{duration:450,easing:'ease-out'});
 avatar.classList.remove('bounce');document.querySelector('.celebration').replaceChildren();
 document.dispatchEvent(new Event('happy:reset'));renderMood();
}
phone.addEventListener('keydown',e=>{if(e.key==='ArrowRight'||e.key==='ArrowLeft'){e.preventDefault();changeMood(mood+(e.key==='ArrowRight'?1:-1));}});


for (let i = 0; i < 15; i++) {
  const mote = document.createElement('i');
  mote.className = 'mote';
  mote.style.cssText = `left:${7 + ((i * 37) % 87)}%;top:${26 + ((i * 19) % 63)}%;--duration:${5 + (i % 5)}s;--delay:${-i * 1.7}s`;
  document.querySelector('.motes').append(mote);
}

function selectHappy() {
  if(suppressClick)return;
  chosen = chosen === mood ? null : mood;
  if (phone.classList.contains('selected')) {
    phone.classList.remove('selected');
    avatar.setAttribute('aria-pressed', 'false');
    label.setAttribute('aria-pressed', 'false');
    next.hidden = true;
    hint.textContent = `${names[mood]} unselected`;
    clearTimeout(celebrationTimer);
    avatar.classList.remove('bounce');
    document.querySelector('.celebration').replaceChildren();
    document.dispatchEvent(new Event('happy:reset'));
    return;
  }
  phone.classList.add('selected');
  avatar.setAttribute('aria-pressed', 'true');
  label.setAttribute('aria-pressed', 'true');
  hint.textContent = `${names[mood]} feels right today`;
  next.hidden = false;
  document.dispatchEvent(new Event('happy:celebrate'));
  if (reduceMotion.matches || document.body.classList.contains('paused')) return;
  clearTimeout(celebrationTimer);
  avatar.classList.remove('bounce');
  void avatar.offsetWidth;
  avatar.classList.add('bounce');
  const celebration = document.querySelector('.celebration');
  celebration.replaceChildren();
  for (let i = 0; i < 8; i++) {
    const spark = document.createElement('span');
    spark.className = 'spark';
    spark.textContent = i % 2 ? '✧' : '✦';
    const angle = (i / 8) * Math.PI * 2;
    spark.style.cssText = `--x:${Math.cos(angle) * 130}px;--y:${Math.sin(angle) * 130 - 30}px`;
    celebration.append(spark);
  }
  celebrationTimer = setTimeout(() => { avatar.classList.remove('bounce'); celebration.replaceChildren(); }, 950);
}
avatar.addEventListener('click', selectHappy);
label.addEventListener('click', selectHappy);
function positionSheet() {
  const box = phone.getBoundingClientRect();
  const border = phone.clientLeft;
  dialog.style.setProperty('--sheet-left', `${box.left + border}px`);
  dialog.style.setProperty('--sheet-bottom', `${Math.max(0, window.innerHeight - box.bottom + border)}px`);
  dialog.style.setProperty('--sheet-width', `${phone.clientWidth}px`);
}
next.addEventListener('click', () => {
 document.querySelector('#confirmation-title').textContent=`You’re feeling ${names[mood].toLowerCase()}.`;
 dialog.querySelector('.sheet-sun').textContent=['☀','☁','☂'][mood];
 dialog.querySelector('h2 + p').textContent=['A little joy, noticed. Take that sunshine with you.','A quiet moment, noticed. Take the day as it comes.','Every feeling deserves a little kindness. Take your time.'][mood];
 positionSheet(); dialog.showModal();
});
window.addEventListener('resize', () => { if (dialog.open) positionSheet(); });
document.querySelector('#close-confirmation').addEventListener('click', () => dialog.close());
dialog.addEventListener('click', event => { if (event.target === dialog) { const box = dialog.getBoundingClientRect(); if (event.clientY < box.top || event.clientX < box.left || event.clientX > box.right || event.clientY > box.bottom) dialog.close(); } });
motionToggle.addEventListener('click', () => {
  if (reduceMotion.matches) return;
  const paused = document.body.classList.toggle('paused');
  motionToggle.setAttribute('aria-pressed', String(paused));
  document.dispatchEvent(new CustomEvent('happy:motion', {detail:{paused}}));
  motionToggle.innerHTML = paused ? '<span aria-hidden="true">▷</span> Resume motion' : '<span aria-hidden="true">Ⅱ</span> Pause motion';
});
function syncMotionPreference() {
  motionToggle.disabled = reduceMotion.matches;
  if (reduceMotion.matches) motionToggle.textContent = 'Reduced motion is on';
  else motionToggle.innerHTML = document.body.classList.contains('paused') ? '<span aria-hidden="true">▷</span> Resume motion' : '<span aria-hidden="true">Ⅱ</span> Pause motion';
}
reduceMotion.addEventListener('change', syncMotionPreference);
syncMotionPreference();
renderMood();
