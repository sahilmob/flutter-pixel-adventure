import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';

import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collision_block.dart';

class Level extends World with HasGameRef<PixelAdventureGame> {
  final Player player;
  final String levelName;
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
    final backgroundLayer = level.tileMap.getLayer("Background");

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        "BackgroundColor",
      );
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? "Gray",
        position: Vector2(0, 0),
      );

      add(backgroundTile);
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
          case "Fruit":
            final fruit = Fruit(
              name: sp.name,
              position: Vector2(sp.x, sp.y),
              size: Vector2(sp.width, sp.height),
            );
            add(fruit);
            break;
          case "Saw":
            final saw = Saw(
              position: Vector2(sp.x, sp.y),
              size: Vector2(sp.width, sp.height),
              isVertical: sp.properties.getValue("isVertical"),
              offNeg: sp.properties.getValue("offNeg"),
              offPos: sp.properties.getValue("offPos"),
            );
            add(saw);
            break;
          case "Checkpoint":
            final checkpoint = Checkpoint(
              position: Vector2(sp.x, sp.y),
              size: Vector2(sp.width, sp.height),
            );
            add(checkpoint);
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
