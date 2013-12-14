import codeanticode.prodmx.*;
import processing.serial.*;

DMX dmx;

int N = 28;
int dimmers[];
int ganancia = 255;
int M = 255;
boolean connected = false;
import ddf.minim.*;
boolean idle = false;
float valor;
Minim minim;
AudioInput in;
int lastActivity = 0;
float yoff = 0;

void setup() {
  size(100, N * 10);
  background(0);
  dimmers = new int[N]; 
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  frameRate(30);

  connected = connectDMX();
}
boolean connectDMX() {
  for (int i = 0; i < Serial.list().length; i++) {
    println(Serial.list());

    if (Serial.list()[i].contains("EN0")) {
      String portName = Serial.list()[i];
      dmx = new DMX(this, portName, 115200, 28);
      println("Openning... " + portName);
      return true;
    }
  }
  return false;
}
void draw() {
  if (connected) {
    background(0);
    noStroke();
    float maximo =  -10000000;
    for (int i = 0; i < in.left.size()-1; i++) {
      if (in.left.get(i) > maximo)
        maximo = in.left.get(i);
    }

    valor = constrain(maximo * ganancia, 0, M) ;
    if (valor > 30) {
      lastActivity = frameCount;
      if (idle) {
        idle = false;
        for (int i = 0; i < N; i ++)
          dimmers[i] = 0;
      }
    }
    if (frameCount - lastActivity > 100) {
      idle = true;
    }
    idle = true;
    if (frameCount % 2== 0) {
      if (!idle) {
        playWish();
      }
      else {
        playRandom3();
      }
    }


    for (int i = 0; i < N; i ++) {
      fill(dimmers[i]);
      rect(0, i * 10, width, 10);
      try {
        dmx.setDMXChannel(i, dimmers[i]);
      }
      catch(Exception e) {
        println(e);
      }
    }
  }
}

void playWish() {
  for (int i = N - 1; i > 0; i --) {
    dimmers[i] = dimmers[i - 1];
    dimmers[0] = int(valor);
  }
}

void playRandom() {

  yoff = yoff + 0.02;
  int n = int(noise(yoff) * N);
  dimmers[n] += 20;

  for (int i = 0; i < N; i ++){
    dimmers[i] -= 1;
    dimmers[i] = constrain(dimmers[i], 0, 255);
  }
}
void playRandom2() {
  for (int i = 0; i < N; i ++){
    dimmers[i] = int(map(noise(i, yoff), 0, 1, 0, 255));
  }
  yoff = yoff + 0.01;
}

void playRandom3() {
  for (int i = 0; i < N; i ++){
    dimmers[i] = int(abs(sin(yoff * i ) * 255));
  }
  yoff = yoff + 0.005;
}
