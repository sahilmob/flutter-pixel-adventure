import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventureGame>, CollisionCallbacks {
  final String name;
  bool _collected = false;
  final hitbox = CustomHitBox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  Fruit({this.name = "Apple", super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
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

  void onCollide() {
    if (_collected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Items/Fruits/Collected.png"),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      _collected = true;
      Future.delayed(const Duration(milliseconds: 400), removeFromParent);
    }
  }
}
