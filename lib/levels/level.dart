import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

class Level extends World {
  final String levelName;
  late TiledComponent level;

  Level({required this.levelName});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    for (final sp in spawnPointsLayer!.objects) {
      switch (sp.class_) {
        case "Player":
          final player = Player(
            character: "Mask Dude",
            position: Vector2(sp.x, sp.y),
          );
          add(player);
          break;
      }
    }

    return super.onLoad();
  }
}
