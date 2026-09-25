const video = document.querySelector('.welcome-video');
const control = document.querySelector('.motion-control');
const motionPreference = window.matchMedia('(prefers-reduced-motion: reduce)');
let manuallyPaused = false;
function updateControl() {
  const paused = video.paused;
  control.setAttribute('aria-label', paused ? 'Play background video' : 'Pause background video');
  control.setAttribute('aria-pressed', String(paused));
  control.innerHTML = paused
    ? '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m9 6 9 6-9 6V6Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>'
    : '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M9 7v10M15 7v10" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';
}
function syncPlayback() {
  if (document.hidden || manuallyPaused || motionPreference.matches) video.pause();
  else video.play().catch(updateControl);
}
control.addEventListener('click', () => {
  if (video.paused) { manuallyPaused = false; video.play().catch(updateControl); }
  else { manuallyPaused = true; video.pause(); }
});
video.addEventListener('play', updateControl);
video.addEventListener('pause', updateControl);
document.addEventListener('visibilitychange', syncPlayback);
motionPreference.addEventListener('change', syncPlayback);
window.addEventListener('pageshow', syncPlayback);
video.muted = true;
syncPlayback();
