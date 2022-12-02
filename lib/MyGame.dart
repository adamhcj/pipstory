import 'dart:html';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

class MyGame extends FlameGame with KeyboardEvents {
  @override
  Color backgroundColor() => const Color(0x59A3F4FF);

  final player = Player();
  final gravity = 10;

  // keypresses
  static late bool isSpace = false;
  static late bool isLeft = false;
  static late bool isRight = false;
  static late bool isC = false;

  @override
  Future<void> onLoad() async {
    add(player);
    FlameAudio.bgm.play('ludipq.mp3', volume: 0.5);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.tick(dt);
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

    if (isSpace) {
      player.jump();
    }
    if (isLeft) {
      player.moveLeft();
    }
    if (isRight) {
      player.moveRight();
    }

    if (isC) {
      player.attack();
    }


    return KeyEventResult.handled;
  }


}

class Player extends SpriteComponent with HasGameRef<MyGame> {
  bool attacking = false;
  bool facingLeft = true;
  bool onGround = false;
  Vector2 velocity = Vector2.zero();

  Player() : super(
    size: Vector2.all(128),
    position: Vector2.all(100),
    anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pipbw.gif');
    size = Vector2.all(128.0);
  }

  void attack() {
    if (attacking) {
      return;
    }
    attacking = true;
    FlameAudio.play('pip.wav', volume: 0.25);

    if (!facingLeft) {
      position += Vector2(50, 0);
      angle += 5;

      Future.delayed(const Duration(milliseconds: 100), () {
        position -= Vector2(50, 0);
        angle -= 5;
      });
    } else {
      position -= Vector2(50, 0);
      angle -= 5;

      Future.delayed(const Duration(milliseconds: 100), () {
        position += Vector2(50, 0);
        angle += 5;
      });
    }




    Future.delayed(const Duration(milliseconds: 600), () {
      attacking = false;
    });

  }

  void jump() {
    if (!onGround) {
      return;
    }
    FlameAudio.play('jump.wav', volume: 1);

    onGround = false;
    velocity.y = -5;
    position.y -= 1;

  }

  void moveLeft() {
    if (!facingLeft) {
      facingLeft = true;
      flipHorizontally();
    }

    if (onGround) {
      // if is changing direction
      if (velocity.x == 2) {
        velocity.x = -2;
      }
      // if havent reach max speed,
      if (velocity.x > -2) {
        velocity.x -= 0.4;
      }

    } else {
      if (velocity.x > -2) {
        velocity.x -= 0.01;
      }

    }

  }

  void moveRight() {
    if (facingLeft) {
      facingLeft = false;
      flipHorizontally();
    }
    if (onGround) {
      // if is changing direction
      if (velocity.x == -2) {
        velocity.x = 2;
      }
      // if havent reach max speed,
      if (velocity.x < 2) {
        velocity.x += 0.4;
      }

    } else {
      if (velocity.x < 2) {
        velocity.x += 0.01;
      }
    }
  }

  void tick(dt) {

    if (position.y > 500 && velocity.y > 0) {
      position.y = 500;
      velocity.y = 0;
      onGround = true;
    }

    if (!onGround) {
      velocity += Vector2(0, dt*gameRef.gravity);
    } else {

      velocity.y = 0;

    }

    // this is for when moving, no need to have friction to slow player to a stop
    if (MyGame.isLeft || MyGame.isRight) {

      if (MyGame.isLeft) {
        moveLeft();
      }

      if (MyGame.isRight) {
        moveRight();
      }

    } else {
      // if moving right
      if (velocity.x >= 0.1) {

        if (onGround) {
          velocity.x -= 0.1;
        } else {
          velocity.x -= 0.01;
        }

        // if moving left
      } else if (velocity.x <= -0.1) {
        if (onGround) {
          velocity.x += 0.1;
        } else {
          velocity.x += 0.01;
        }
      } else { // if velocity is too low, set it to 0.
        velocity.x = 0;
      }
    }



    position += velocity;
  }


}