Matrix3 transform;
float[] angles = new float[2];

public void setup() {
  size(800, 600);
}

public void draw() {
  background(0);
  translate(width / 2, height / 2);
  
  
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
  double x;
  double y;
  double z;
  
  Vertex(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
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
            this.values[row * 3 + i] * other.values[row * 3 + i];
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
