import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyGame.dart';

void main() {
  // sets to landscape orientation for mobile devices
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    // runApp(new MyApp());
    // runs the game
    final game = MyGame();
    runApp(GameWidget(game: game));
  });


}

