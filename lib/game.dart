import 'dart:ui';
import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventureGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  @override
  final world = Level(levelName: "level-01");
  late final CameraComponent cam;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      world: world,
    );

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}
