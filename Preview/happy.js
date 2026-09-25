/** Original Happy artwork, unchanged pose. Only eye lids animate. */
(() => {
  const canvas = document.querySelector('#happy-character');
  const context = canvas.getContext('2d');
  const artwork = new Image();
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  let clock = 0, lastTime = 0, frame = 0, ready = false, paused = false, tapped = -100;
  const eyes = [
    {x:570,y:284,rx:82,ry:55,angle:9,top:'#343331',bottom:'#242423'},
    {x:799,y:335,rx:86,ry:58,angle:16,top:'#292929',bottom:'#1e1f1f'}
  ];
  const pulse = (phase, center, duration) => Math.max(0, 1 - Math.abs(phase - center) / duration);
  function draw() {
    if (!ready) return;
    const width = Math.min(canvas.parentElement.clientWidth,1024);
    const height = Math.min(canvas.parentElement.clientHeight,1024);
    if (!width || !height) return;
    const ratio = Math.min(devicePixelRatio || 1,2);
    if (canvas.width !== Math.round(width*ratio) || canvas.height !== Math.round(height*ratio)) {
      canvas.width = Math.round(width*ratio); canvas.height = Math.round(height*ratio);
    }
    context.setTransform(ratio,0,0,ratio,0,0);
    context.clearRect(0,0,width,height);
    const side = Math.min(width,height), scale = side / 1254;
    context.translate((width-side)/2,(height-side)/2);
    context.scale(scale,scale);
    context.drawImage(artwork,0,0,1254,1254);
    const closed = reduced.matches ? 0 : Math.max(pulse(clock%5.3,4.6,.14),pulse(clock-tapped,.14,.14));
    if (closed <= 0) return;
    for (const eye of eyes) {
      context.save();
      context.translate(eye.x,eye.y); context.rotate(eye.angle*Math.PI/180);
      context.beginPath(); context.ellipse(0,0,eye.rx,eye.ry,0,0,Math.PI*2); context.clip();
      const lid=context.createLinearGradient(0,-eye.ry,0,eye.ry);
      lid.addColorStop(0,eye.top); lid.addColorStop(1,eye.bottom);
      context.fillStyle=lid;
      context.fillRect(-eye.rx,-eye.ry,eye.rx*2,eye.ry*2*closed);
      context.restore();
    }
  }
  function tick(timestamp) {
    if(lastTime) clock+=Math.min((timestamp-lastTime)/1000,.05);
    lastTime=timestamp; draw(); frame=requestAnimationFrame(tick);
  }
  function sync() {
    cancelAnimationFrame(frame); lastTime=0; draw();
    if(ready&&!reduced.matches&&!paused&&!document.hidden) frame=requestAnimationFrame(tick);
  }
  artwork.onload=()=>{ready=true;sync();};
  artwork.onerror=()=>{canvas.hidden=true;};
  artwork.src='../MoodDay/Assets.xcassets/HappyAvatar.imageset/happy-avatar.png?v=white-mouth';
  document.addEventListener('happy:celebrate',()=>{if(!paused&&!reduced.matches)tapped=clock;});
  document.addEventListener('happy:reset',()=>{tapped=-100;draw();});
  document.addEventListener('happy:motion',event=>{paused=event.detail.paused;sync();});
  document.addEventListener('visibilitychange',sync);
  reduced.addEventListener('change',sync);
  new ResizeObserver(draw).observe(canvas);
})();
