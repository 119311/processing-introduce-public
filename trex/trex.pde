import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

PImage rexJmpImg, rexRunImg1, rexRunImg2, rexHitImg, cactusImg, backImg;
float gravity = 1.1; 
float add = 0; 
Player rex;
Hurdle cactus;
Observer observer;
boolean hit;
boolean debug = true;
State state;
Minim minim;
AudioPlayer player;

void setup()
{
  size(800, 400);
  frameRate(60);
  imageMode(CENTER);
  rectMode(CENTER);
  rexJmpImg = loadImage("trex.png");
  rexRunImg1 = loadImage("trex_run1.png");
  rexRunImg2 = loadImage("trex_run2.png");
  rexHitImg = loadImage("trex_hit.png");
  cactusImg = loadImage("cactus.png");
  backImg = loadImage("back.re-min.jpg");
  state = new TitleState();
  minim = new Minim(this);  //初期化
  player = minim.loadFile("hogehoge.mp3");  
  player.play();
}
void draw()
{
  state = state.doState();
}

void keyPressed()
{
  if (key==' ')	rex.jump();
  //  if (key=='r')  setup(); 
  if (key=='q')  exit();
}
void stop() 
{
  player.close();  
  minim.stop();
  super.stop();
}
void mouseClicked()
{
  rex.jump();
}

class TitleState extends State 
{
  void drawState() 
  {
  rex = new Player();
  cactus = new Hurdle();
  observer = new Observer(rex, cactus);

    background(0);
    textSize(32);
    text("trex", width * 0.45, height * 0.4);
    if (t_start_state>3000)
      text("Press Space key to start", width * 0.24, height * 0.6);
  }
  State nextState() 
  {
    if (debug)
      if ((keyPressed && key == ' ')) 
        return new GameState();
    if (t_start_state>3000)
      if ((keyPressed && key == ' ')) 
        return new GameState();
    return this;
  }
}

class GameState extends State 
{
  void drawState() 
  {
    image(backImg, 400, 200);
    //			background(255);
    cactus.update();
    rex.update();
    observer.update();
    int s = t_start_state / 100;
    String a = "score:";
    String b = nf(s, 10);
    String t = a+b;
    fill(0); 
    textSize(32);
    text (t, width * 0.6, height * 0.1);
  }
  State nextState() 
  {
    if (hit) 
      return new EndState(); 
    return this;
  }
}

class EndState extends State 
{
  void drawState() 
  {
    background(0);
    textSize(32);
    fill(255);
    text("Game Over", width * 0.34, height * 0.4);
    if (t_start_state>2000)
      text("Press r key to restart", width * 0.3, height * 0.6);
  }
  State nextState() 
  {
    if (t_start_state>2000)
      if ((keyPressed && key == 'r')) 
      {        
        player.close();  
        minim.stop();
        return new TitleState();
      }  
    return this;
  }
}

class Player 
{
  PImage rexImg;
  float px, py; 
  float vy; 
  float stdHeight = 0.7*height; 
  boolean isGrounded; 

  Player()
  {
    px = 50;
    py = stdHeight;
    vy = 0;
    isGrounded = true;
  }
  void update()
  {
    if (hit)	image(rexHitImg, px, py, 55, 55);
    else
    {
      vy += gravity;
      py += vy;
      if (py>=stdHeight)
      {
        isGrounded = true; 
        py = stdHeight;
      }
      if (isGrounded)
      {
        if (frameCount%10>0 && frameCount%10<6) rexImg = rexRunImg1;
        else rexImg = rexRunImg2;
      } else rexImg = rexJmpImg;
      image(rexImg, px, py, 60, 60);
    }
  }
  void jump()
  {
    if (isGrounded)
    {
      isGrounded = false;
      vy = -16;
    }
  }
}

class Hurdle {
  float px, py; 
  float vx; 

  Hurdle()
  {
    px = width;
    py = 0.7*height;
    vx = -10+random(-5, 5);
  }

  void update()
  {
    if (!hit)
    {
      px+= vx;
      if (px<0) 
      {
        px = width;
        add += 0.1;
        vx = -(16+add)*random(1.0, 1.5);
      }
    }
    image(cactusImg, px, py, 40, 70);
  }
}

class Observer
{
  Player rex;
  Hurdle cactus;

  Observer(Player _rex, Hurdle _cactus)
  {
    rex = _rex;
    cactus = _cactus;
  }

  void update()
  {
    if (dist(rex.px, rex.py, cactus.px, cactus.py)<40) hit = true;
    else hit = false;
  }
}


abstract class State 
{
  int t_start;
  int t_start_state;

  State() 
  {
    t_start = millis();
  }

  State doState() 
  {
    t_start_state = millis() - t_start ;
    drawState();
    return nextState();
  }
  abstract void drawState();		
  abstract State nextState();
}
