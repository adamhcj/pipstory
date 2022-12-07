import 'package:flame/components.dart';

import 'MyGame.dart';

class Background extends SpriteComponent with HasGameRef<MyGame> {
  Background() : super(
      size: Vector2.all(128),
      position: Vector2.all(0)
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bg.png');
    onClientResize();
  }

  void onClientResize() {
    Vector2 newSize = gameRef.size;
    size = newSize/1.8;
  }
}