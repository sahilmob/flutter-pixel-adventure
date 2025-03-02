import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World {
  final String levelName;
  final Player player;
  late TiledComponent level;

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    for (final sp in spawnPointsLayer!.objects) {
      switch (sp.class_) {
        case "Player":
          player.position = Vector2(sp.x, sp.y);
          add(player);
          break;
      }
    }

    return super.onLoad();
  }
}
