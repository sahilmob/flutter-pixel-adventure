import 'dart:async';
import 'package:flame/components.dart';

import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/constants.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventureGame> {
  final String name;
  Fruit({this.name = "Apple", super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$name.png"),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
}
