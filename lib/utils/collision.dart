import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/collision_block.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedPlayerX =
      player.scale.x < 0
          ? playerX - (hitbox.offsetX * 2) - playerWidth
          : playerX;
  final fixedPlayerY = block.isPlatform ? playerY + playerHeight : playerY;

  return fixedPlayerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedPlayerX < blockX + blockWidth &&
      fixedPlayerX + playerWidth > blockX;
}
