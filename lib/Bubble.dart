import 'package:flame/components.dart';

import 'MyGame.dart';

class Bubble extends SpriteComponent with HasGameRef<MyGame> {
  Vector2 velocity = Vector2.zero();
  Bubble() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bubble.png');
    size = Vector2.all(20.0);
  }

  void tick(dt) {
    position.x += velocity.x * dt;
  }


}