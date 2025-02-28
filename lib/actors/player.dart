import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/game.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventureGame> {
  Player({position, required this.character}) : super(position: position);

  final String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  static double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation("Run", 12);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: Player.stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
