import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/game.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventureGame>, TapCallbacks {
  JumpButton();
  static const buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    priority = 10;
    sprite = Sprite(game.images.fromCache("HUD/JumpButton.png"));

    position = Vector2(
      game.camera.viewport.size.x - 32 - buttonSize,
      game.camera.viewport.size.y - 16 - buttonSize,
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
