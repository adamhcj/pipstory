import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'MyGame.dart';

class Platform extends SpriteComponent with HasGameRef<MyGame>, CollisionCallbacks{
  Platform() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('platform.png');

    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox.relative(Vector2(1, 0.2), position: Vector2(0, 5), parentSize: size, anchor: Anchor.topLeft);
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x99FF0000);

    hitbox.renderShape = true;
    add(hitbox);

  }
}