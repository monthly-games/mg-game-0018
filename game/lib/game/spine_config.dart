// import 'package:mg_common_game/core/assets/asset_types.dart'; // Temporarily disabled - module doesn't exist yet

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Racer Red ────────────────────────────────────────────────

// const kRacerRedMeta = SpineAssetMeta(
//   key: 'racer_red',
//   path: 'spine/characters/racer_red',
//   atlasPath: 'assets/spine/characters/racer_red/racer_red.atlas',
//   skeletonPath: 'assets/spine/characters/racer_red/racer_red.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Racer Blue ───────────────────────────────────────────────

// const kRacerBlueMeta = SpineAssetMeta(
//   key: 'racer_blue',
//   path: 'spine/characters/racer_blue',
//   atlasPath: 'assets/spine/characters/racer_blue/racer_blue.atlas',
//   skeletonPath:
//       'assets/spine/characters/racer_blue/racer_blue.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Racer Green ──────────────────────────────────────────────

// const kRacerGreenMeta = SpineAssetMeta(
//   key: 'racer_green',
//   path: 'spine/characters/racer_green',
//   atlasPath:
//       'assets/spine/characters/racer_green/racer_green.atlas',
//   skeletonPath:
//       'assets/spine/characters/racer_green/racer_green.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );
