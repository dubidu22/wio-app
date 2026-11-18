{{flutter_js}}
{{flutter_build_config}}

// wio-app loads nothing from a CDN at run time (D-40). The build uses
// --no-web-resources-cdn for CanvasKit and Skwasm, and the app bundles its
// font. Glyphs that the bundled font lacks would otherwise be fetched from
// fonts.gstatic.com; this points those requests at our own server instead.
// No service worker: Flutter's is deprecated.
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: "assets/fallback-fonts/",
  },
});
