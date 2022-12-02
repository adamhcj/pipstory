import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

import 'MyGame.dart';

class LeftButton extends SpriteComponent with HasGameRef<MyGame>, Tappable{
  LeftButton() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('left.png');
    size = Vector2.all(128.0);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    // change sprite image to leftpressed.png

    MyGame.isLeft = true;
    return true;
  }

}

class RightButton extends SpriteComponent with HasGameRef<MyGame>, Tappable {
  RightButton() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('right.png');
    size = Vector2.all(128.0);
    position.x += 200;
  }

}