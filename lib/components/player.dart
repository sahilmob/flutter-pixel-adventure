import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flame/components.dart';
import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/components/collision.block.dart';

enum PlayerState { idle, running }

base class BasePlayer extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventureGame>, KeyboardHandler {
  BasePlayer({super.position, this.character = "Ninja Frog"}) : super();
  static double stepTime = 0.05;
  List<CollisionBlock> collisionBlocks = [];

  final String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;

  double moveSpeed = 100;
  double horizontalMovement = 0.0;
  Vector2 velocity = Vector2.zero();
}

base mixin PlayerHasGameRef on BasePlayer, HasGameRef<PixelAdventureGame> {
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: BasePlayer.stepTime,
        textureSize: Vector2.all(32),
      ),
    );
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
}

base mixin PlayerKeyboardHandler on BasePlayer, KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0.0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }
}

base class Player extends BasePlayer
    with PlayerHasGameRef, PlayerKeyboardHandler {
  Player({super.position, super.character});

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    // check if flipped or not using scale;
    // see scale docs
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    current = playerState;
  }
}
