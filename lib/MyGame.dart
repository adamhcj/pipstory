
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pipstory/Platform.dart';

import 'Background.dart';
import 'Bubble.dart';
import 'Buttons.dart';
import 'Player.dart';
import 'RareCandy.dart';

// Game
class MyGame extends FlameGame with KeyboardEvents, HasTappables , HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0x59A3F4FF);

  int candyCounter = 0;
  final TextBoxComponent candyCounterText = TextBoxComponent(
    position: Vector2(10, 10),
  );


  final player = Player();
  final playerHitboxComponent = PlayerHitboxComponent();
  final cameraObject = CameraObject();
  final leftButton = LeftButton();
  final rightButton = RightButton();
  final spaceBar = SpaceBar();
  final cButton = CButton();
  final background = Background();
  final gravity = 10;

  // bubble list
  List<Bubble> bubbles = [];

  // keypresses
  static late bool isSpace = false;
  static late bool isLeft = false;
  static late bool isRight = false;
  static late bool isC = false;

  // for screen markers, setting the text format
  final textPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF0000),
      fontSize: 30,
    ),
  );

  // function to add markers in the world
  void addMarker(double x, double y) {
    String text = '$x, $y';
    add(TextBoxComponent(text: text, textRenderer: textPaint, position: Vector2(x, y)));
  }

  void addTextAt(String text, double x, double y) {
    add(TextBoxComponent(text: text, textRenderer: textPaint, position: Vector2(x, y)));
  }

  void addPlatform(double x, double y, double width, double height) {
    Platform platform = Platform();
    platform.position = Vector2(x, y);
    platform.size = Vector2(width, height);
    addRareCandy(x, y-60);
    add(platform);
  }

  void addRareCandy(double x, double y) {
    RareCandy rareCandy = RareCandy();
    rareCandy.position = Vector2(x, y);
    rareCandy.priority = 1;
    add(rareCandy);
  }

  @override
  Future<void> onLoad() async {
    // initial world population
    player.priority = 1;
    add(player);
    add(playerHitboxComponent);

    add(cameraObject);
    camera.followComponent(cameraObject);
    camera.zoom = 0.42;

    leftButton.priority = 1;
    leftButton.positionType = PositionType.viewport;
    add(leftButton);

    rightButton.priority = 1;
    rightButton.positionType = PositionType.viewport;
    add(rightButton);

    spaceBar.priority = 1;
    spaceBar.positionType = PositionType.viewport;
    add(spaceBar);

    cButton.priority = 1;
    cButton.positionType = PositionType.viewport;
    add(cButton);

    background.priority = -100;
    background.positionType = PositionType.viewport;
    add(background);

    // candy counter component
    candyCounterText.text = 'Candy: $candyCounter';
    candyCounterText.textRenderer = textPaint;
    candyCounterText.priority = 1;
    candyCounterText.positionType = PositionType.viewport;
    add(candyCounterText);

    FlameAudio.bgm.play('maple.wav', volume: 0.5);

    addRareCandy(0, 0);
    // adds screen markers for reference
    for (double i = 0; i <= 8000; i+=800) {
      for (double j = 0; j <= 1000; j+=200) {
        // addMarker(i, j);
        addPlatform(i, j, 400, 50);
      }
    }

    for (double i = 1; i <= 20; i++) {
      addPlatform(300*i, 250*-i, 80, 50);
      addPlatform(300*i, 500*-i, 80, 50);
    }
    for (double i = 1; i <= 20; i++) {
      addMarker(300*-i, 250*-i);
      addPlatform(300*-i, 250*-i, 80, 50);
    }

    addTextAt("Jump quest here! >>>", 70, -270);
    addTextAt("^ Jump quest on top! ^", 70, 900);

    
    addPlatform(100, 1200, 1000, 50);

    print(canvasSize);
  }

  // on resize
  @override
  Future<void> onGameResize(Vector2 vector2) async {
    super.onGameResize(vector2);
    leftButton.onClientResize();
    rightButton.onClientResize();
    spaceBar.onClientResize();
    cButton.onClientResize();
    background.onClientResize();
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

    // calls all the tick methods in all the objects
    player.tick(dt);
    cameraObject.tick(dt);
    // leftButton.tick(dt);
    // rightButton.tick(dt);
    // spaceBar.tick(dt);
    // cButton.tick(dt);

    // iterate through bubble list
    for (var bubble in bubbles) {
      bubble.tick(dt);
    }

    if (isLeft) {
      leftButton.current = LeftButtonState.pressed;
    } else {
      leftButton.current = LeftButtonState.unpressed;
    }
    if (isRight) {
      rightButton.current = RightButtonState.pressed;
    } else {
      rightButton.current = RightButtonState.unpressed;
    }
    if (isSpace) {
      spaceBar.current = SpaceBarState.pressed;
    } else {
      spaceBar.current = SpaceBarState.unpressed;
    }
    if (isC) {
      cButton.current = CButtonState.pressed;
    } else {
      cButton.current = CButtonState.unpressed;
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
