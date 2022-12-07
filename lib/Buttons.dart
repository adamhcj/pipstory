import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';

import 'MyGame.dart';

enum LeftButtonState {
  unpressed,
  pressed
}

enum RightButtonState {
  unpressed,
  pressed
}

enum SpaceBarState {
  unpressed,
  pressed
}

enum CButtonState {
  unpressed,
  pressed
}

class LeftButton extends SpriteAnimationGroupComponent<LeftButtonState> with HasGameRef<MyGame>, Tappable{
  LeftButton() : super(
      size: Vector2.all(88),
      position: Vector2(900, 650),
      anchor: Anchor.center
  );

  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    double stepConst = 0.5;

    final animation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: stepConst / length,
      loop: true,
    );


    return animation;
  }

  @override
  Future<void> onLoad() async {
    animations = {
      LeftButtonState.unpressed: await loadSpriteAnimation('left', 1),
      LeftButtonState.pressed: await loadSpriteAnimation('leftpressed', 1),
    };
    current = LeftButtonState.unpressed;
    onClientResize();
  }

  void onClientResize() {
    Vector2 newSize = gameRef.canvasSize;
    position = newSize - Vector2(140, 50);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    // change sprite image to leftpressed.png
    MyGame.isLeft = true;
    current = LeftButtonState.pressed;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    // change sprite image to left.png
    MyGame.isLeft = false;
    current = LeftButtonState.unpressed;
    return true;
  }

  @override
  bool onTapCancel() {
    MyGame.isLeft = false;
    current = LeftButtonState.unpressed;
    return true;
  }

  void tick(dt) {
    // position = gameRef.cameraObject.position + gameRef.canvasSize/2*2.78 - Vector2(400, 120);
  }

}

class RightButton extends SpriteAnimationGroupComponent<RightButtonState> with HasGameRef<MyGame>, Tappable {
  RightButton() : super(
      size: Vector2.all(88),
      position: Vector2(990, 650),
      anchor: Anchor.center
  );

  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    double stepConst = 0.5;

    final animation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: stepConst / length,
      loop: true,
    );


    return animation;
  }

  @override
  Future<void> onLoad() async {
    animations = {
      RightButtonState.unpressed: await loadSpriteAnimation('right', 1),
      RightButtonState.pressed: await loadSpriteAnimation('rightpressed', 1),
    };
    current = RightButtonState.unpressed;
    onClientResize();
  }

  void onClientResize() {
    Vector2 newSize = gameRef.canvasSize;
    position = newSize - Vector2(50, 50);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    MyGame.isRight = true;
    current = RightButtonState.pressed;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    MyGame.isRight = false;
    current = RightButtonState.unpressed;
    return true;
  }

  @override
  bool onTapCancel() {
    MyGame.isRight = false;
    current = RightButtonState.unpressed;
    return true;
  }

  void tick(dt) {
    // position = gameRef.cameraObject.position + gameRef.canvasSize/2*2.78 - Vector2(110, 120);
  }

}

class SpaceBar extends SpriteAnimationGroupComponent<SpaceBarState> with HasGameRef<MyGame>, Tappable {
  SpaceBar() : super(
      size: Vector2(400, 68),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    double stepConst = 0.5;

    final animation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: stepConst / length,
      loop: true,
    );


    return animation;
  }

  @override
  Future<void> onLoad() async {
    animations = {
      SpaceBarState.unpressed: await loadSpriteAnimation('spacebar', 1),
      SpaceBarState.pressed: await loadSpriteAnimation('spacebarpressed', 1),
    };
    current = SpaceBarState.unpressed;
    onClientResize();
  }

  void onClientResize() {
    Vector2 newSize = gameRef.canvasSize;
    position = newSize - Vector2(420, 45);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    MyGame.isSpace = true;
    current = SpaceBarState.pressed;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    MyGame.isSpace = false;
    current = SpaceBarState.unpressed;
    return true;
  }

  @override
  bool onTapCancel() {
    MyGame.isSpace = false;
    current = SpaceBarState.unpressed;
    return true;
  }

  void tick(dt) {
    // position = gameRef.cameraObject.position + gameRef.canvasSize/2*2.78 - Vector2(1100, 100);
  }

}

class CButton extends SpriteAnimationGroupComponent<CButtonState> with HasGameRef<MyGame>, Tappable {
  CButton() : super(
      size: Vector2.all(88),
      anchor: Anchor.center
  );

  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    double stepConst = 0.5;

    final animation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: stepConst / length,
      loop: true,
    );


    return animation;
  }

  @override
  Future<void> onLoad() async {
    animations = {
      CButtonState.unpressed: await loadSpriteAnimation('C', 1),
      CButtonState.pressed: await loadSpriteAnimation('Cpressed', 1),
    };
    current = CButtonState.unpressed;
    onClientResize();
  }

  void onClientResize() {
    Vector2 newSize = gameRef.canvasSize;
    position = newSize - Vector2(680, 50);
    if (position.x < 0) {
      position.x = 30;
      position.y -= 70;
    }
  }

  @override
  bool onTapDown(TapDownInfo info) {
    MyGame.isC= true;
    current = CButtonState.pressed;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    MyGame.isC = false;
    current = CButtonState.unpressed;
    return true;
  }

  @override
  bool onTapCancel() {
    MyGame.isC = false;
    current = CButtonState.unpressed;
    return true;
  }

  void tick(dt) {
    // position = gameRef.cameraObject.position + gameRef.canvasSize/2*2.78 - Vector2(1760, 150);
    // if (gameRef.canvasSize.x < 630) {
    //   position.x += 300;
    //   position.y -= 170;
    // }
    // if (gameRef.canvasSize.x < 520) {
    //   position.x += 150;
    // }
  }

}