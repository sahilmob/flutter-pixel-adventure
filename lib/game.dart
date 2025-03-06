import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/jump_button.dart';

class PixelAdventureGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late Player player;
  bool showControls = false;
  late JoystickComponent joystick;
  List<String> levels = ["Level-01", "Level-01"];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    _loadLevel();
    if (showControls) addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) updateJoystick();

    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Joystick.png")),
      ),
      position: Vector2(size.x, camera.viewport.size.y - 48),
    );
    add(joystick);
    add(JumpButton());
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.up:
        break;
      case JoystickDirection.down:
        break;
      case JoystickDirection.right ||
          JoystickDirection.upRight ||
          JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.left ||
          JoystickDirection.upLeft ||
          JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.idle:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    }
  }

  void _loadLevel() async {
    if (currentLevelIndex > 0) {
      await Future.delayed(const Duration(seconds: 1));
    }

    world.removeWhere((_) => true);

    player = Player(character: "Mask Dude");

    world = Level(levelName: levels[currentLevelIndex], player: player);
    camera = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      world: world,
    );
    camera.priority = -1;

    camera.viewfinder.anchor = Anchor.topLeft;
  }
}
