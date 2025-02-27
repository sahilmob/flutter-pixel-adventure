import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pixel_adventure/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  PixelAdventureGame game = PixelAdventureGame();
  runApp(GameWidget(game: kDebugMode ? PixelAdventureGame() : game));
}
