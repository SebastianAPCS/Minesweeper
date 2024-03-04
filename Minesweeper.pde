Matrix3 transform;
float[] angles = new float[2];
float defaultWeight = 1;

Box[][][] boxes = new Box[5][5][5];

public void setup() {
  size(800, 600);
  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        boxes[i][j][k] = new Box((i * 100) - 200, (j * 100) - 200, (k * 100) - 200, 80);
        
        /*for (Quadrilateral face : boxes[i][j][k].faces) {
          face.setRender(false);
        }*/
      }
    }
  }
  
  updateTransform();
}

public void draw() {
  background(0);
  translate(width / 2, height / 2);
  
  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        boxes[i][j][k].render();
      }
    }
  }
  
  updateTransform();
}

void mouseDragged() {
  float sensitivity = 0.33;
  float yIncrement = sensitivity * (pmouseY - mouseY);
  float xIncrement = sensitivity * (mouseX - pmouseX);
  
  angles[0] += xIncrement;
  angles[1] += yIncrement;
  
  redraw();
  updateTransform();
}

void updateTransform() {
  float heading = radians(angles[0]);
  float pitch = radians(angles[1]);
  
  Matrix3 headingTransform = new Matrix3(new double[]{
    cos(heading), 0, -sin(heading),
    0, 1, 0,
    sin(heading), 0, cos(heading)
  });
  
  Matrix3 pitchTransform = new Matrix3(new double[]{
    1, 0, 0,
    0, cos(pitch), sin(pitch),
    0, -sin(pitch), cos(pitch)
  });
  
  transform = headingTransform.multiply(pitchTransform);
}

class Vertex {
  double x, y, z;
  
  Vertex(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Hue {
  int r, g, b;
  
  Hue(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

class Quadrilateral {
  Vertex v1;
  Vertex v2;
  Vertex v3;
  Vertex v4;
  
  boolean renderFace = true;
  void setRender(boolean b) {
    renderFace = b;
  }
  
  Quadrilateral(Vertex v1, Vertex v2, Vertex v3, Vertex v4) {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.v4 = v4;
  }
}

class Cube {
  Vertex v1, v2, v3, v4, v5, v6, v7, v8;
  
  Cube(Vertex v1, Vertex v2, Vertex v3, Vertex v4, Vertex v5, Vertex v6, Vertex v7, Vertex v8) {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.v4 = v4;
    this.v5 = v5;
    this.v6 = v6;
    this.v7 = v7;
    this.v8 = v8;
  }
  
  Cube(double centerX, double centerY, double centerZ, double cubeWidth) {
    double halfWidth = cubeWidth / 2;
    
    this.v1 = new Vertex(centerX - halfWidth, centerY - halfWidth, centerZ - halfWidth);
    this.v2 = new Vertex(centerX - halfWidth, centerY - halfWidth, centerZ + halfWidth);
    this.v3 = new Vertex(centerX - halfWidth, centerY + halfWidth, centerZ - halfWidth);
    this.v4 = new Vertex(centerX - halfWidth, centerY + halfWidth, centerZ + halfWidth);
    this.v5 = new Vertex(centerX + halfWidth, centerY - halfWidth, centerZ - halfWidth);
    this.v6 = new Vertex(centerX + halfWidth, centerY - halfWidth, centerZ + halfWidth);
    this.v7 = new Vertex(centerX + halfWidth, centerY + halfWidth, centerZ - halfWidth);
    this.v8 = new Vertex(centerX + halfWidth, centerY + halfWidth, centerZ + halfWidth);
  }
}

class Box extends Cube {
  ArrayList <Quadrilateral> faces = new ArrayList<>();
  int r = 255, g = 255, b = 255; // line color
  int fr = 211, fg = 211, fb = 211; // face color
  int ft = 100; // face transparency
  float w = 1; // line width
  boolean renderFaces = false;
  
  Box(double centerX, double centerY, double centerZ, double boxWidth) {
    super(centerX, centerY, centerZ, boxWidth);
    
    faces.add(new Quadrilateral(v2, v4, v8, v6));
    faces.add(new Quadrilateral(v1, v3, v7, v5));
    faces.add(new Quadrilateral(v1, v2, v4, v3));
    faces.add(new Quadrilateral(v5, v6, v8, v7));
    faces.add(new Quadrilateral(v3, v4, v8, v7));
    faces.add(new Quadrilateral(v1, v2, v6, v5));
  }

  void render() {
    for (Quadrilateral quad : faces) {
      stroke(r, g, b);
      strokeWeight(w);
      
      Vertex q1 = transform.transform(quad.v1);
      Vertex q2 = transform.transform(quad.v2);
      Vertex q3 = transform.transform(quad.v3);
      Vertex q4 = transform.transform(quad.v4);
      
      line((float) q1.x, (float) q1.y, (float) q2.x, (float) q2.y);
      line((float) q2.x, (float) q2.y, (float) q3.x, (float) q3.y);
      line((float) q3.x, (float) q3.y, (float) q4.x, (float) q4.y);
      line((float) q4.x, (float) q4.y, (float) q1.x, (float) q1.y);
      
      if (renderFaces && quad.renderFace) {
        beginShape();
        fill(fr, fg, fb, ft);
        vertex((float) q1.x, (float) q1.y);
        vertex((float) q2.x, (float) q2.y);
        vertex((float) q3.x, (float) q3.y);
        vertex((float) q4.x, (float) q4.y);
        endShape(CLOSE);
      }
      
      strokeWeight(defaultWeight);
    }
  }
}

class Matrix3 {
  double[] values;
  
  Matrix3(double[] values) {
    this.values = values;
  }
  
  Matrix3 multiply(Matrix3 other) {
    double[] result = new double[9];
    
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        for (int i = 0; i < 3; i++) {
          result[row * 3 + col] +=
            this.values[row * 3 + i] * other.values[i * 3 + col];
        }
      }
    }
    
    return new Matrix3(result);
  }
  
  Vertex transform(Vertex vinput) {
    return new Vertex(
      vinput.x * values[0] + vinput.y * values[3] + vinput.z * values[6],
      vinput.x * values[1] + vinput.y * values[4] + vinput.z * values[7],
      vinput.x * values[2] + vinput.y * values[5] + vinput.z * values[8]
    );
  }
}
