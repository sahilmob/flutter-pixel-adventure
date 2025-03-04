import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';

import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/utils/collision.dart';
import 'package:pixel_adventure/components/collision.block.dart';

enum PlayerState { idle, running, jumping, falling }

base class BasePlayer extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventureGame>, KeyboardHandler {
  BasePlayer({super.position, this.character = "Ninja Frog"}) : super();
  static double stepTime = 0.05;
  List<CollisionBlock> collisionBlocks = [];

  final double _gravity = 9.8;
  final double _jumpForce = 280;
  final double _terminalVelocity = 300;

  final String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  double moveSpeed = 100;
  bool hasJumped = false;
  bool isOnGround = false;
  double horizontalMovement = 0.0;
  Vector2 velocity = Vector2.zero();
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
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
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
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

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

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
    // debugMode = true;
    _loadAllAnimations();
    // add(
    //   RectangleHitbox(
    //     position: Vector2(hitbox.offsetX, hitbox.offsetY),
    //     size: Vector2(hitbox.width, hitbox.height),
    //   ),
    // );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
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

    if (velocity.y > _gravity) {
      playerState = PlayerState.falling;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final b in collisionBlocks) {
      if (!b.isPlatform) {
        if (checkCollision(this, b)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = b.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = b.x + b.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final b in collisionBlocks) {
      if (b.isPlatform) {
        if (checkCollision(this, b)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = b.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, b)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = b.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = b.y + b.height - hitbox.offsetY;
          }
        }
      }
    }
  }
}
