{{flutter_js}}
{{flutter_build_config}}

const loader = document.querySelector('#app-loader');

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      requestAnimationFrame(() => {
        loader?.classList.add('is-ready');
        window.setTimeout(() => loader?.remove(), 280);
      });
    } catch (error) {
      if (loader) {
        loader.querySelector('span').textContent =
          'START FEHLGESCHLAGEN · BITTE NEU LADEN';
      }
      throw error;
    }
  },
});
