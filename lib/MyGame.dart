import 'dart:html';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

import 'Bubble.dart';
import 'Buttons.dart';
import 'Player.dart';

// Game
class MyGame extends FlameGame with KeyboardEvents, HasTappables {
  @override
  Color backgroundColor() => const Color(0x59A3F4FF);

  final player = Player();
  final leftButton = LeftButton();
  final rightButton = RightButton();
  final gravity = 10;

  // bubble list
  List<Bubble> bubbles = [];

  // keypresses
  static late bool isSpace = false;
  static late bool isLeft = false;
  static late bool isRight = false;
  static late bool isC = false;

  @override
  Future<void> onLoad() async {
    add(player);
    add(leftButton);
    add(rightButton);
    FlameAudio.bgm.play('ludipq.mp3', volume: 0.5);
  }

  void addBubble(Vector2 location, Vector2 velocity) {
    final bubble = Bubble();
    bubble.position = location;
    bubble.velocity = velocity;
    bubbles.add(bubble);
    add(bubble);

    // destroy bubble after 3 seconds
    Future.delayed(Duration(milliseconds: 500), () {
      remove(bubble);
      bubbles.remove(bubble);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.tick(dt);
    // iterate through bubble list
    for (var bubble in bubbles) {
      bubble.tick(dt);
    }
  }

  // on key event
  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    final isKeyDown = event is RawKeyDownEvent;

    isSpace = keysPressed.contains(LogicalKeyboardKey.space);
    isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    isC = keysPressed.contains(LogicalKeyboardKey.keyC);

    // if (isSpace) {
    //   player.jump();
    // }
    // if (isLeft) {
    //   player.moveLeft();
    // }
    // if (isRight) {
    //   player.moveRight();
    // }
    //
    // if (isC) {
    //   player.attack();
    // }


    return KeyEventResult.handled;
  }


}
