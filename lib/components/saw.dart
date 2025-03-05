import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:pixel_adventure/game.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventureGame> {
  final double offNeg;
  final double offPos;
  final bool isVertical;

  double rangeNeg = 0;
  double rangePos = 0;
  int moveDirection = 1;

  static const int tileSize = 16;
  static const int moveSpeed = 50;
  static const double stepTime = 0.03;

  Saw({
    super.size,
    super.position,
    this.offNeg = 0,
    this.offPos = 0,
    this.isVertical = false,
  });

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    add(CircleHitbox(collisionType: CollisionType.passive));

    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offNeg * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offNeg * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Saw/On (38x38).png"),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }

    position.x += moveDirection * moveSpeed * dt;
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }

    position.y += moveDirection * moveSpeed * dt;
  }
}
