import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collision_block.dart';

class Level extends World with HasGameRef<PixelAdventureGame> {
  final String levelName;
  final Player player;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    const tileSize = 64;
    final backgroundLayer = level.tileMap.getLayer("Background");

    final numTilesX = (game.size.x / tileSize).floor();
    final numTilesY = (game.size.y / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        "BackgroundColor",
      );

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? "Gray",
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );

          add(backgroundTile);
        }
      }
    }
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    if (spawnPointsLayer != null) {
      for (final sp in spawnPointsLayer.objects) {
        switch (sp.class_) {
          case "Player":
            player.position = Vector2(sp.x, sp.y);
            add(player);
            break;
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");

    if (collisionsLayer != null) {
      for (final c in collisionsLayer.objects) {
        final block = switch (c.class_) {
          "Platform" => CollisionBlock(
            position: Vector2(c.x, c.y),
            size: Vector2(c.width, c.height),
            isPlatform: true,
          ),
          _ => CollisionBlock(
            position: Vector2(c.x, c.y),
            size: Vector2(c.width, c.height),
          ),
        };
        collisionBlocks.add(block);
        add(block);
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
