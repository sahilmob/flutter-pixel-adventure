import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flame/components.dart';
import 'package:pixel_adventure/game.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/utils/collision.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/collision_block.dart';

enum PlayerState {
  hit,
  idle,
  running,
  jumping,
  falling,
  appearing,
  disappearing,
}

base class BasePlayer extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventureGame>, KeyboardHandler {
  BasePlayer({super.position, this.character = "Ninja Frog"}) : super();
  List<CollisionBlock> collisionBlocks = [];

  final double _gravity = 9.8;
  final double _jumpForce = 280;
  final double _terminalVelocity = 300;

  final String character;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  double moveSpeed = 100;
  bool gotHit = false;
  bool hasJumped = false;
  bool isOnGround = false;
  bool reachedCheckpoint = false;
  double horizontalMovement = 0.0;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  CustomHitBox hitbox = CustomHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double accTime = 0;
  double fixedDt = 1 / 60;

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
}

base mixin PlayerHasGameRef on BasePlayer, HasGameRef<PixelAdventureGame> {
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _visibilityAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation("Run", 12);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);
    hitAnimation = _spriteAnimation("Hit", 7)..loop = false;
    appearingAnimation = _visibilityAnimation("Appearing", 7)..loop = false;
    disappearingAnimation = _visibilityAnimation("Disappearing", 7)
      ..loop = false;

    animations = {
      PlayerState.hit: hitAnimation,
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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

base mixin PlayerReSpawn on BasePlayer {
  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play("hit.wav", volume: game.soundVolume);
    }
    var appearingOffset = Vector2.all(96 - 64);
    gotHit = true;
    current = PlayerState.hit;
    animationTicker?.onComplete = () {
      scale.x = 1;
      // Appearing animation is 96 * 96
      // while player is 64 * 64
      position = startingPosition - appearingOffset;
      current = PlayerState.appearing;
      animationTicker?.onComplete = () async {
        velocity = Vector2.all(0);
        position = startingPosition;
        _updatePlayerState();
        gotHit = false;
      };
    };
  }
}

base mixin ReachCheckPointHandler on BasePlayer {
  void _onReachCheckpoint() {
    if (game.playSounds) {
      FlameAudio.play("disappear.wav", volume: game.soundVolume);
    }

    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      scale.x = 1;
      position = position - Vector2(32, -32);
    }

    current = PlayerState.disappearing;
    animationTicker?.onComplete = () async {
      removeFromParent();
      game.loadNextLevel();
    };
  }
}

base class Player extends BasePlayer
    with
        PlayerReSpawn,
        PlayerHasGameRef,
        CollisionCallbacks,
        PlayerKeyboardHandler,
        ReachCheckPointHandler {
  Player({super.position, super.character});

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    _loadAllAnimations();
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accTime += dt;
    while (accTime >= fixedDt) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDt);
        _checkHorizontalCollisions();
        _applyGravity(fixedDt);
        _checkVerticalCollisions();
      }
      accTime -= dt;
    }

    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (reachedCheckpoint) return;

    if (other is Fruit) {
      other.onCollide();
    } else if (other is Saw) {
      if (!gotHit) {
        _respawn();
      }
    } else if (other is Checkpoint) {
      _onReachCheckpoint();
      other.onCollide();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play("jump.wav", volume: game.soundVolume);
    }

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
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
