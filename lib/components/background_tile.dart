import 'dart:async';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  final double scrollSpeed = 40;
  BackgroundTile({super.position, this.color = "Gray"});

  @override
  FutureOr<void> onLoad() async {
    priority = -1;
    size = Vector2.all(64);
    parallax = await game.loadParallax(
      [ParallaxImageData("Background/$color.png")],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    return super.onLoad();
  }
}
