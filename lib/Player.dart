

// Player
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

import 'MyGame.dart';

enum PlayerState {
  idle,
  run,
  jump,
  attack
}

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<MyGame> {
  bool attacking = false;
  bool facingLeft = true;
  bool onGround = false;
  Vector2 velocity = Vector2.zero();
  late final running;

  // final running = [1, 2, 3, 4, 5]
  //     .map((i) => Sprite.load('runningpip$i.png'));

  Future<SpriteAnimation> loadSpriteAnimation(String name, int length) async {
    // create list from 1 to length
    final frames = List.generate(length, (i) => i + 1);
    final sprites = frames.map((i) => Sprite.load('$name$i.png'));

    late final animation;
    if (name == 'pipidle') {
      animation = SpriteAnimation.spriteList(
        await Future.wait(sprites),
        stepTime: 2/length,
        loop: true,
      );
    } else {
      animation = SpriteAnimation.spriteList(
        await Future.wait(sprites),
        stepTime: 0.5/length,
        loop: true,
      );
    }


    return animation;

  }



  Player() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );



  @override
  Future<void> onLoad() async {
    animations = {
      PlayerState.idle: await loadSpriteAnimation('pipidle', 39),
      PlayerState.run: await loadSpriteAnimation('runningpip', 5),
      PlayerState.jump: await loadSpriteAnimation('pipskip', 4),
    };
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

      Future.delayed(const Duration(milliseconds: 300), () {
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
    if (attacking) {
      return;
    }

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
    if (attacking) {
      return;
    }

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
      current = PlayerState.jump;
    } else {
      current = PlayerState.idle;
      velocity.y = 0;

    }

    if (MyGame.isC) {
      attack();
    }

    if (MyGame.isSpace) {
      jump();
    }


    // this is for when moving, no need to have friction to slow player to a stop
    if (!attacking && !(MyGame.isLeft && MyGame.isRight) && (MyGame.isLeft || MyGame.isRight)) {

      if (current != PlayerState.jump) {
        current = PlayerState.run;
      }


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