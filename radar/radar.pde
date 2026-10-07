import processing.serial.*;

Serial myPort;

// Dữ liệu
String data="";
int iAngle=0, iDistance=0;

// Lưu điểm có thời gian
class Target {
  float d, angle;
  float life; // thời gian tồn tại

  Target(float d, float angle) {
    this.d = d;
    this.angle = angle;
    this.life = 255; // bắt đầu sáng
  }

  void update() {
    life -= 3; // tốc độ mờ
  }

  void display() {
    stroke(255, 0, 0, life);
    strokeWeight(6);

    float x = d * cos(radians(angle));
    float y = -d * sin(radians(angle));

    point(x, y);
  }

  boolean isDead() {
    return life <= 0;
  }
}

ArrayList<Target> targets = new ArrayList<Target>();

PFont font;

void setup() {
  size(1200, 700);
  smooth();

  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.');

  font = createFont("Arial", 18);
}

void draw() {

  // nền mờ (trail đẹp)
  fill(0, 30);
  noStroke();
  rect(0, 0, width, height);

  drawRadar();
  drawSweep();
  drawTargets();
  drawText();
}

// ================= SERIAL =================
void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');

  if (data != null) {
    data = data.substring(0, data.length()-1);

    int index = data.indexOf(",");
    if (index != -1) {
      iAngle = int(data.substring(0, index));
      iDistance = int(data.substring(index+1));
    }
  }
}

// ================= RADAR =================
void drawRadar() {
  pushMatrix();
  translate(width/2, height);

  stroke(0, 255, 0);
  strokeWeight(2);
  noFill();

  // vòng tròn
  for (int i = 1; i <= 4; i++) {
    arc(0, 0, i*200, i*200, PI, TWO_PI);
  }

  // góc
  for (int a = 0; a <= 180; a += 30) {
    line(0, 0, 500*cos(radians(a)), -500*sin(radians(a)));

    fill(0, 255, 0);
    textAlign(CENTER);
    text(a + "°", 520*cos(radians(a)), -520*sin(radians(a)));
    noFill();
  }

  popMatrix();
}

// ================= TIA QUÉT (CONE) =================
void drawSweep() {
  pushMatrix();
  translate(width/2, height);

  noStroke();

  // vẽ vùng quét dạng quạt
  for (int i = 0; i < 20; i++) {
    fill(0, 255, 0, 10);
    float a1 = radians(iAngle - i);
    float a2 = radians(iAngle - i - 1);

    beginShape();
    vertex(0, 0);
    vertex(500*cos(a1), -500*sin(a1));
    vertex(500*cos(a2), -500*sin(a2));
    endShape(CLOSE);
  }

  popMatrix();
}

// ================= VẬT CẢN =================
void drawTargets() {
  pushMatrix();
  translate(width/2, height);

  // thêm mục tiêu mới
  if (iDistance < 40) {
    float d = map(iDistance, 0, 40, 0, 500);
    targets.add(new Target(d, iAngle));
  }

  // cập nhật + vẽ + xóa
  for (int i = targets.size()-1; i >= 0; i--) {
    Target t = targets.get(i);

    t.update();
    t.display();

    if (t.isDead()) {
      targets.remove(i);
    }
  }

  popMatrix();
}

// ================= TEXT =================
void drawText() {
  fill(0);
  noStroke();
  rect(0, height-60, width, 60);

  fill(0, 255, 0);
  textFont(font);

  text("Angle: " + iAngle + "°", 50, height-20);
  text("Distance: " + iDistance + " cm", 250, height-20);

  if (iDistance < 40) {
    text("Object: Trong phạm vi", 500, height-20);
  } else {
    text("Object: Ngoài phạm vi", 500, height-20);
  }
}
