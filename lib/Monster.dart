

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

enum EnemyState {
  idle,
  run,
  jump,
  attack
}

class Monster extends SpriteAnimationGroupComponent<EnemyState> with HasGameRef<MyGame>, CollisionCallbacks {
  bool attacking = false;
  bool facingLeft = true;
  bool onGround = false;
  Vector2 velocity = Vector2.zero();
  late final running;
  bool isLeft = false;
  bool isRight = false;

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



  Monster() : super(
      size: Vector2.all(128),
      position: Vector2(0, -500),
      anchor: Anchor.center
  );



  @override
  Future<void> onLoad() async {

    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox.relative(Vector2(0.5, 0.3), position: Vector2(60, 125), parentSize: size, anchor: Anchor.center);
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x0);

    hitbox.renderShape = true;
    add(hitbox);

    EnemyHitboxComponent enemyHitbox = EnemyHitboxComponent(this);
    add(enemyHitbox);


    // populate all animation states
    animations = {
      EnemyState.idle: await loadSpriteAnimation('pipidle', 40),
      EnemyState.run: await loadSpriteAnimation('runningpip', 5),
      EnemyState.jump: await loadSpriteAnimation('pipskip', 4),
      EnemyState.attack: await loadSpriteAnimation('pipattack', 2),
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
    noOfAttacks = gameRef.candyCounter.clamp(1, 50);

    if (facingLeft) {

      for (int i = 0; i < noOfAttacks; i++) {
        Future.delayed(Duration(milliseconds: i*(50-noOfAttacks)), () {
          gameRef.addBubble(Vector2(position.x-25, position.y-10), Vector2(-1000, -10 * noOfAttacks + i*30), i);
        });
      }

    } else {
      for (int i = 0; i < noOfAttacks; i++) {
        Future.delayed(Duration(milliseconds: i*(50-noOfAttacks)), () {
          gameRef.addBubble(Vector2(position.x+25, position.y-10), Vector2(1000, -10 * noOfAttacks + i*30), i);
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
      current = EnemyState.jump;
    } else {
      current = EnemyState.idle;
      velocity.y = 0;

    }

    // if (MyGame.isC) {
    //   attack();
    // }
    //
    // if (MyGame.isSpace) {
    //   jump();
    // }


    // this is for when moving, no need to have friction to slow player to a stop
    if (!attacking && !(isLeft && isRight) && (isLeft || isRight)) {

      if (current != EnemyState.jump) {
        current = EnemyState.run;
      }


      // if (MyGame.isLeft) {
      //   moveLeft(dt * 300);
      // }
      //
      // if (MyGame.isRight) {
      //   moveRight(dt * 300);
      // }

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
      current = EnemyState.attack;
    }


    position += velocity * dt * 200;
  }


}


class EnemyHitboxComponent extends PositionComponent with HasGameRef<MyGame>, CollisionCallbacks{
  late Monster enemy;

  EnemyHitboxComponent(this.enemy);
  @override
  void render(Canvas c) {

  }

  //on load
  @override
  Future<void> onLoad() async {
    size = enemy.size * 1;
    // anchor = Anchor.center;
    // add hitboxes
    ShapeHitbox hitbox = RectangleHitbox();
    // paints the hitbox so we can see
    hitbox.paint = Paint()..color = Color(0x6BFF0000);

    hitbox.renderShape = true;
    add(hitbox);
  }


  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bubble && other.current != BubbleState.splash) {
      other.removeItself(enemy);


    }
  }

}