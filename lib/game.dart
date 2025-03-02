import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';

class PixelAdventureGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  bool showJoystick = true;
  late final CameraComponent cam;
  late JoystickComponent joystick;
  final Player player = Player(character: "Mask Dude");

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    @override
    final world = Level(levelName: "level-01", player: player);

    cam = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      world: world,
    );

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    if (showJoystick) addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) updateJoystick();

    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Joystick.png")),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 8),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.up:
        break;
      case JoystickDirection.down:
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.idle:
        player.horizontalMovement = 0;
        break;
    }
  }
}
