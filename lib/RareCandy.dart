import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

import 'MyGame.dart';
import 'Player.dart';

class RareCandy extends SpriteComponent with HasGameRef<MyGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  bool picked = false;
  RareCandy() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('rarecandy.png');
    size = Vector2.all(60.0);
    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox();
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x0);

    hitbox.renderShape = true;
    add(hitbox);
  }

  void tick(dt) {
    // position.x += velocity.x * dt;
    // position.y += velocity.y * dt;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (picked) {
      velocity = (gameRef.player.position - position).normalized() * 300;
      // fade away
      if (opacity > 0) {
        double newOpacity = opacity - 4*dt;
        opacity = newOpacity.clamp(0, 1);
      }
      position += velocity * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerHitboxComponent && !picked) {
      onPickUp();
    }
  }

  void onPickUp() {
    picked = true;
    // accelerate towards player

    FlameAudio.play('loot.wav', volume: 0.5);

    Future.delayed(Duration(milliseconds: 220), () {
      gameRef.candyCounter++;
      gameRef.candyCounterText.text = 'Candy: ${gameRef.candyCounter}';
      FlameAudio.play('pip.wav', volume: 0.35);
      gameRef.remove(this);
    });

  }


}