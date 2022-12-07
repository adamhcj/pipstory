

// Player
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pipstory/Platform.dart';

import 'Bubble.dart';
import 'MyGame.dart';
import 'RareCandy.dart';

enum PlayerState {
  idle,
  run,
  jump,
  attack
}

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<MyGame>, CollisionCallbacks {
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
      loop: true,
    );


    return animation;

  }



  Player() : super(
      size: Vector2.all(128),
      position: Vector2.all(100),
      anchor: Anchor.center
  );



  @override
  Future<void> onLoad() async {

    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox.relative(Vector2(0.5, 0.05), position: Vector2(60, 125), parentSize: size, anchor: Anchor.center);
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x0);

    hitbox.renderShape = true;
    add(hitbox);


    // populate all animation states
    animations = {
      PlayerState.idle: await loadSpriteAnimation('pipidle', 40),
      PlayerState.run: await loadSpriteAnimation('runningpip', 5),
      PlayerState.jump: await loadSpriteAnimation('pipskip', 4),
      PlayerState.attack: await loadSpriteAnimation('pipattack', 2),
    };
    size = Vector2.all(128.0);
  }

  void attack() {
    if (attacking) {
      return;
    }
    attacking = true;
    FlameAudio.play('pipattack.wav', volume: 0.25);
    // shoot bubble towards direction facing
    int noOfAttacks = 10;

    if (facingLeft) {

      for (int i = 0; i < noOfAttacks; i++) {
        Future.delayed(Duration(milliseconds: i*(50-noOfAttacks)), () {
          gameRef.addBubble(Vector2(position.x-25, position.y-10), Vector2(-1000, -10 * noOfAttacks + i*30));
        });
      }

    } else {
      for (int i = 0; i < noOfAttacks; i++) {
        Future.delayed(Duration(milliseconds: i*50), () {
          gameRef.addBubble(Vector2(position.x+25, position.y-10), Vector2(1000, -10 * noOfAttacks + i*30));
        });
      }

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

  }

  void moveLeft(dt) {
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
        velocity.x -= 0.2 * dt;

        if (velocity.x < -2) {
          velocity.x = -2;
        }
      }

    } else {
      if (velocity.x > -2) {
        velocity.x -= 0.01 * dt;

        if (velocity.x < -2) {
          velocity.x = -2;
        }

      }

    }

  }

  void moveRight(dt) {
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
        velocity.x += 0.2 * dt;

        if (velocity.x > 2) {
          velocity.x = 2;
        }

      }

    } else {
      if (velocity.x < 2) {
        velocity.x += 0.01 * dt;

        if (velocity.x > 2) {
          velocity.x = 2;
        }
      }
    }
  }

  // on collision
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (velocity.y < 0) {
      return;
    }
    if (other is Platform) {
      onGround = true;
      velocity.y = 0;
      position.y = other.position.y - 80;
    }

    if (other is RectangleHitbox) {
      // print("test");
    }
  }

  void tick(dt) {
    bool touchingPlatform = false;
    late Vector2 platformPosition;
    for (final collision in activeCollisions) {
      if (collision is Platform) {
        touchingPlatform = true;
        platformPosition = collision.position;
      }
    }

    if (!touchingPlatform && onGround) {
      onGround = false;
    }
    // check if collide with platform, then set on ground to be true
    if (touchingPlatform && !onGround && velocity.y >= 0) {
      onGround = true;

      velocity.y = 0;
      // check intersection of collision
      position.y = platformPosition.y - 80;

    }

    // if too low on the screen, set on ground to true
    if (position.y > 1500 && velocity.y > 0) {
      position.y = -300;
      position.x = 200;
      velocity.y = 0;
      onGround = true;
    }

    if (!onGround) {
      velocity += Vector2(0, dt*gameRef.gravity);
      if (velocity.y > 5) {
        velocity.y = 5;
      }
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
        moveLeft(dt * 300);
      }

      if (MyGame.isRight) {
        moveRight(dt * 300);
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

    if (attacking) {
      current = PlayerState.attack;
    }


    position += velocity * dt * 200;
  }


}


class CameraObject extends PositionComponent with HasGameRef<MyGame> {
  @override
  void render(Canvas c) {

  }

  tick(dt) {
    // cameraobject follows player but not too closely
    if (gameRef.player.position.x > position.x + gameRef.canvasSize.x / 2 - 100) {
      position.x = gameRef.player.position.x - gameRef.canvasSize.x / 2 + 100;

    }
    if (gameRef.player.position.x < position.x - gameRef.canvasSize.x / 2 + 100) {
      position.x = gameRef.player.position.x + gameRef.canvasSize.x / 2 - 100;
    }
    if (gameRef.player.position.y > position.y + gameRef.canvasSize.y / 2 - 200) {
      position.y = gameRef.player.position.y - gameRef.canvasSize.y / 2 + 200;
    }
    if (gameRef.player.position.y < position.y - gameRef.canvasSize.y / 2 + 200) {
      position.y = gameRef.player.position.y + gameRef.canvasSize.y / 2 - 200;
    }
  }
}

class PlayerHitboxComponent extends PositionComponent with HasGameRef<MyGame>, CollisionCallbacks{
  @override
  void render(Canvas c) {

  }

  //on load
  @override
  Future<void> onLoad() async {
    size = gameRef.player.size * 0.8;
    anchor = gameRef.player.anchor;
    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox();
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x0);

    hitbox.renderShape = true;
    add(hitbox);
  }


  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.player.position;
  }
}