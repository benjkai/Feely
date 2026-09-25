(() => {
  const reducedMotion = () => matchMedia('(prefers-reduced-motion: reduce)').matches;
  const nativeTransitions = 'CSSViewTransitionRule' in window;
  if (!nativeTransitions && !reducedMotion() && location.pathname.endsWith('/moods.html')) {
    document.documentElement.classList.add('screen-enter');
  }
  addEventListener('pageshow', () => document.documentElement.classList.remove('screen-leave'));
  if (nativeTransitions) return;
  addEventListener('DOMContentLoaded', () => {
    const link = document.querySelector('.check-in');
    if (!link) return;
    let navigating = false;
    link.addEventListener('click', event => {
      if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || reducedMotion()) return;
      event.preventDefault();
      if (navigating) return;
      navigating = true;
      document.documentElement.classList.add('screen-leave');
      setTimeout(() => location.assign(link.href), 240);
    });
    addEventListener('pageshow', () => { navigating = false; });
  });
})();
