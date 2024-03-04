import processing.opengl.*;

Matrix3 transform;
float[] angles = new float[2];
float defaultWeight = 1;

Box[][][] boxes = new Box[5][5][5];
Box highlightedBox = null;

boolean isMouseDragged = false;
boolean minesSet = false;

public void setup() {
  size(1000, 750, OPENGL);
  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        boxes[i][j][k] = new Box((i * 100) - 200, (j * 100) - 200, (k * 100) - 200, 60, i, j, k);
      }
    }
  }
  
  textFont(createFont("Verdana-Bold", 15)); 

  updateTransform();
}

public void draw() {
  background(0);
  translate(width / 2, height / 2);
  
  ArrayList<Box> overlappingBoxes = new ArrayList<Box>();
  
  double closestZ = -999999999; // fuck this shit bro
  
  if (mousePressed == false) {
    isMouseDragged = false;
  }
  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        boxes[i][j][k].isHighlighted = false;
      }
    }
  }
  highlightedBox = null;

  if (!isMouseDragged) {
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 5; k++) {
          Box currentBox = boxes[i][j][k];
          if (currentBox.isClicked) continue;
          
          Vertex screenPos = currentBox.getScreenPosition();
          float distance = dist(mouseX, mouseY, (float)screenPos.x, (float)screenPos.y);
          if (distance < 50) {
            overlappingBoxes.add(currentBox);
          }
        }
      }
    }
    
    for (Box box : overlappingBoxes) {
      Vertex screenPos = box.getScreenPosition();
      if (screenPos.z > closestZ) {
        highlightedBox = box;
        closestZ = screenPos.z;
      }
    }
    
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 5; k++) {
          boxes[i][j][k].isHighlighted = false;
        }
      }
    }
    
    if (highlightedBox != null) {
      if (!highlightedBox.isRightClicked) highlightedBox.isHighlighted = true;
    }
  }
  
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        if (!(isBoxValid(i + 1, j, k) && isBoxValid(i - 1, j, k) &&
              isBoxValid(i, j + 1, k) && isBoxValid(i, j - 1, k) &&
              isBoxValid(i, j, k + 1) && isBoxValid(i, j, k - 1))) {
          if (!boxes[i][j][k].isClicked) {
            boxes[i][j][k].render();
          } else {
            boxes[i][j][k].renderText();
          }
        }
      }
    }
  }
  
  updateTransform();
}

void mouseDragged() {
  isMouseDragged = true;
  
  float sensitivity = 0.1;
  float yIncrement = sensitivity * (pmouseY - mouseY);
  float xIncrement = sensitivity * (mouseX - pmouseX);
  
  angles[0] += xIncrement;
  angles[1] += yIncrement;
  
  redraw();
  updateTransform();
}

void mousePressed() {
  if (highlightedBox != null) {
    if (!minesSet) setMines();
    
    if (mouseButton == RIGHT) {
      if (highlightedBox.isRightClicked) highlightedBox.isRightClicked = false;
      else if (!highlightedBox.isRightClicked) highlightedBox.isRightClicked = true;
    } else {
      if (highlightedBox.isMine) {
        endGame(false);
      } else {
        highlightedBox.isClicked = true;
        
        highlightedBox.minesNearby = highlightedBox.numMinesNearby();
        
        int i = highlightedBox.i;
        int j = highlightedBox.j;
        int k = highlightedBox.k;
        
        // revealSurroundingBoxes(i, j, k);
      }
    }
  }
}

boolean isBoxValid(int i, int j, int k) {
  return i <= 4 && i >= 0 && j <= 4 && j >= 0 && k <= 4 && k >= 0 && !boxes[i][j][k].isClicked;
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

void setMines() {
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        if (!boxes[i][j][k].isHighlighted && (Math.random() > 0.9)) {
          boxes[i][j][k].isMine = true;
        }
      }
    }
  }
  
  minesSet = true;
}

void endGame(boolean hasWon) {
  noLoop();
  delay(500);
  
  if (!hasWon) {
    background(0);
    
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 5; k++) {
          if (boxes[i][j][k].isMine) {
            boxes[i][j][k].fr = 255;
            boxes[i][j][k].fg = 0;
            boxes[i][j][k].fb = 0;
            
            boxes[i][j][k].render();
          }
        }
      }
    }
    
    delay(500);
    fill(255);
    // textSize(64);
    textFont(createFont("Verdana-Bold", 64)); 
    text("GAME LOST", -200, 0);
    
    // if (mousePressed || keyPressed) exit();
  } else if (hasWon) {
    delay(500);
    fill(255);
    // textSize(64);
    textFont(createFont("Verdana-Bold", 64)); 
    text("GAME WON", -175, 0);
  }
}

void revealSurroundingBoxes(int x, int y, int z) {
  if (!isBoxValid(x, y, z)) return;

  Box currentBox = boxes[x][y][z];
  
  currentBox.isClicked = true;
  println(x + ", " + y + ", " + z);
  
  int nearbyMines = currentBox.numMinesNearby();
  if (nearbyMines > 0) return;
  
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      for (int k = -1; k <= 1; k++) {
        if (i == 0 && j == 0 && k == 0) continue;
        revealSurroundingBoxes(x + i, y + j, z + k); // recursion :>
      }
    }
  }
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
  Vertex v1, v2, v3, v4;
  
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
  double centerX, centerY, centerZ;
  
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
    
    this.centerX = centerX;
    this.centerY = centerY;
    this.centerZ = centerZ;
  }
}

class Box extends Cube {
  // Not a very good implementation of a minesweeper box but it'll suffice
  ArrayList<Quadrilateral> faces = new ArrayList<Quadrilateral>();
  int r = 255, g = 0, b = 0; // line color
  int fr = 211, fg = 211, fb = 211; // face color
  int ft = 100; // face transparency
  int minesNearby = 0;
  int i, j, k;
  float w = 1; // line width
  
  boolean renderFaces = true;
  boolean renderLines = false;
  boolean isClicked = false;
  boolean isRightClicked = false;
  boolean isHighlighted = false;
  boolean isMine = false;
  
  Box(double centerX, double centerY, double centerZ, double boxWidth, int i, int j, int k) {
    super(centerX, centerY, centerZ, boxWidth);
    
    faces.add(new Quadrilateral(v2, v4, v8, v6));
    faces.add(new Quadrilateral(v1, v3, v7, v5));
    faces.add(new Quadrilateral(v1, v2, v4, v3));
    faces.add(new Quadrilateral(v5, v6, v8, v7));
    faces.add(new Quadrilateral(v3, v4, v8, v7));
    faces.add(new Quadrilateral(v1, v2, v6, v5));
    
    this.i = i;
    this.j = j;
    this.k = k;
  }

  void render() {
    if (isHighlighted) {
      fr = 255; fg = 255; fb = 0; 
    } else if (isRightClicked) {
      fr = 86; fg = 108; fb = 255;
    } else {
      fr = 211; fg = 211; fb = 211;
    }
    
    float[][] depthIndexPairs = new float[faces.size()][2];
  
    for (int i = 0; i < faces.size(); i++) {
      Quadrilateral quad = faces.get(i);
  
      Vertex q1 = transform.transform(quad.v1);
      Vertex q2 = transform.transform(quad.v2);
      Vertex q3 = transform.transform(quad.v3);
      Vertex q4 = transform.transform(quad.v4);
  
      float avgZ = (float)(q1.z + q2.z + q3.z + q4.z) / 4;
      depthIndexPairs[i][0] = avgZ;
      depthIndexPairs[i][1] = i;
    }
  
    for (int i = 0; i < depthIndexPairs.length - 1; i++) {
      for (int j = 0; j < depthIndexPairs.length - i - 1; j++) {
        if (depthIndexPairs[j][0] > depthIndexPairs[j + 1][0]) {
          float[] temp = depthIndexPairs[j];
          depthIndexPairs[j] = depthIndexPairs[j + 1];
          depthIndexPairs[j + 1] = temp;
        }
      }
    }

    for (float[] pair : depthIndexPairs) {
    //for (int i = 0; i < Math.min(3, depthIndexPairs.length); i++) {
      int index = (int) pair[1];
      //int index = (int) depthIndexPairs[i][1];
      
      Quadrilateral quad = faces.get(index);
  
      Vertex q1 = transform.transform(quad.v1);
      Vertex q2 = transform.transform(quad.v2);
      Vertex q3 = transform.transform(quad.v3);
      Vertex q4 = transform.transform(quad.v4);
      
      //fill(255, 0, 0);
      //text(index, (float)((q1.x + q2.x + q3.x + q4.x)/4), (float)((q1.y + q2.y + q3.y + q4.y)/4));
       
      stroke(r, g, b, 20);
      strokeWeight(w);
     
      if (renderLines) {
        line((float) q1.x, (float) q1.y, (float) q2.x, (float) q2.y);
        line((float) q2.x, (float) q2.y, (float) q3.x, (float) q3.y);
        line((float) q3.x, (float) q3.y, (float) q4.x, (float) q4.y);
        line((float) q4.x, (float) q4.y, (float) q1.x, (float) q1.y);
      }
      
      if (renderFaces && quad.renderFace && !isClicked) {
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
  
  Vertex getScreenPosition() {
    Vertex screenPos = transform.transform(new Vertex(this.centerX, this.centerY, this.centerZ));
    return new Vertex(screenPos.x + width / 2, screenPos.y + height / 2, screenPos.z);
  }
  
  
  int numMinesNearby() {
    int sum = 0;
    
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        for (int k = -1; k <= 1; k++) {
          if (i == 0 && j == 0 && k == 0) continue;
          
          if (isBoxValid(this.i + i, this.j + j, this.k + k)) {
            if (boxes[this.i + i][this.j + j][this.k + k].isMine) sum++;
          }
        }
      }
    }
    
    return sum;
  }
  
  void renderText() {
    fill(255);
    Vertex transformedCenter = transform.transform(new Vertex(centerX, centerY, centerZ));
    text(numMinesNearby(), (float) transformedCenter.x, (float) transformedCenter.y);
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
