import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'Monster.dart';
import 'MyGame.dart';

enum BubbleState {
  idle,
  splash
}

class Bubble extends SpriteAnimationGroupComponent<BubbleState> with HasGameRef<MyGame>, CollisionCallbacks{
  Vector2 velocity = Vector2.zero();
  late int number;
  Bubble(this.number);


  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    double stepConst = 0.5;
    // controls the speed of the animation
    if (name == 'pipidle') {
      stepConst = 2;
    }
    if (name == 'pipattack') {
      stepConst = 0.1;
    }

    final animation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: stepConst/length,
      loop: false, // set to false for bubble!
    );


    return animation;

  }

  @override
  Future<void> onLoad() async {
    // populate all animation states
    animations = {
      BubbleState.idle: await loadSpriteAnimation('bubble', 1),
      BubbleState.splash: await loadSpriteAnimation('splash', 8),
    };

    current = BubbleState.idle;

    anchor = Anchor.center;

    size = Vector2.all(50.0);
    // add hitboxes
    ShapeHitbox hitbox = CircleHitbox();
    // paints the hitbox so we can see
    add(hitbox);

  }

  void tick(dt) {
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }

  void removeItself(Monster enemy) {
    current = BubbleState.splash;
    size = Vector2.all(300.0);

    velocity = Vector2.zero();

    int candies = gameRef.candyCounter;
    int damage = Random().nextInt(candies.clamp(1, 9999)) + candies.clamp(1, 9999);
    TextComponent damageText = gameRef.addTextAt(damage.toString(), x, y);

    TextPaint textPaint = TextPaint(
      style: TextStyle(
        color: Color(0xFFFF0000),
        fontSize: 50,
      )
    );
    damageText.textRenderer = textPaint;
    damageText.position = enemy.position;
    damageText.position.y -= 200;
    damageText.position.y -= 50*number;
    if (number > 45) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-45);
      damageText.position.x += 60*9;
    } else if (number > 40) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-40);
      damageText.position.x += 60*8;
    } else if (number > 35) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-35);
      damageText.position.x += 60*7;
    } else if (number > 30) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-30);
      damageText.position.x += 60*6;
    } else if (number > 25) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-25);
      damageText.position.x += 60*5;
    } else if (number > 20) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-20);
      damageText.position.x += 60*4;
    } else if (number > 15) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-15);
      damageText.position.x += 60*3;
    } else if (number > 10) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-10);
      damageText.position.x += 60*2;
    } else if (number > 5) {
      damageText.position.y += 50*number;
      damageText.position.y -= 50*(number-5);
      damageText.position.x += 60*1;
    }

    if (gameRef.candyCounter < 30) {
      if (number % 5 == 0) {
        FlameAudio.play('bubble.wav');
      }
    } else {
      if (number % 10 == 0) {
        FlameAudio.play('bubble.wav');
      }
      if (number % 2 == 0) {
        Future.delayed(Duration(milliseconds: 600), () {
          gameRef.remove(damageText);
        });
        gameRef.remove(this);
        return;
      }
    }



    // remove after animation is done
    Future.delayed(Duration(milliseconds: 600), () {
      gameRef.remove(this);
      gameRef.remove(damageText);
    });
  }


}