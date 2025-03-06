import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/constants.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventureGame> {
  bool reachedCheckpoint = false;
  Checkpoint({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(18, 16),
        size: Vector2(12, 50),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        "Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png",
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );

    return super.onLoad();
  }

  void onCollide() {
    if (!reachedCheckpoint) {
      reachedCheckpoint = true;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
          "Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png",
        ),
        SpriteAnimationData.sequenced(
          amount: 26,
          stepTime: stepTime,
          textureSize: Vector2.all(64),
          loop: false,
        ),
      );

      animationTicker?.onComplete = () {
        reachedCheckpoint = false;
        animation = SpriteAnimation.fromFrameData(
          game.images.fromCache(
            "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png",
          ),
          SpriteAnimationData.sequenced(
            amount: 10,
            stepTime: stepTime,
            textureSize: Vector2.all(64),
          ),
        );
      };
    }
  }
}
