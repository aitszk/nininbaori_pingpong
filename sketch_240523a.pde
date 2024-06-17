// Processingのインポート
// Ai Tsuzuki
import processing.video.*;

Capture cam; // カメラキャプチャオブジェクト
PImage bg; // 背景画像

float thresh_ = 20.0; // 変化検出のしきい値
int counter = 0; // 動作検出のカウンター
int x_size = 640, y_size = 480; // 画像の幅と高さ
boolean startDetection = false;  // 動作検知の開始フラグ

void setup() {
  size(640, 480); // ウィンドウサイズの設定
  colorMode(RGB); // カラーモードの設定
  String[] cameras = Capture.list(); // 利用可能なカメラのリストを取得
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, x_size, y_size); // カメラが取得できなかった場合、デフォルトのカメラを使用
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit(); // カメラがない場合、プログラムを終了
  } else {
    println("Available cameras:");
    printArray(cameras); // 利用可能なカメラのリストを表示

    cam = new Capture(this, cameras[0]); // 最初のカメラを使用
    cam.start(); // カメラキャプチャの開始
    bg = createImage(width, height, RGB); // 背景画像の作成
  }
}

int x = 0, y = 0; // 動作検出の初期位置
int x_move = 1, y_move = 1; // 動作検出の移動量
int barX = 305, barY = 450;  // バーの初期位置
int barMove = 2;  // バーの移動速度

void draw() {
  if (cam.available()) {
    cam.read(); // カメラのフレームを読み込む
  }

  if (startDetection) {
    counter = 0; // カウンターをリセット
    // 動作検出エリアの明るさの差を計算
    for (int j = y; j < y + 10; j++) {
      for (int i = x; i < x + 10; i++) {
        if (abs(brightness(cam.get(i, j)) - brightness(bg.get(i, j))) > thresh_) {
          counter++;
        }
      }
    }

    int barCounter = 0; // バーの検出カウンターをリセット
    // バーの検出エリアの明るさの差を計算
    for (int j = barY; j < barY + 10; j++) {
      for (int i = barX; i < barX + 30; i++) {
        if (abs(brightness(cam.get(i, j)) - brightness(bg.get(i, j))) > thresh_) {
          barCounter++;
        }
      }
    }

    image(cam, 0, 0); // カメラの画像を描画
    fill(255, 0, 0); // 赤色で塗りつぶし
    ellipse(x, y, 10, 10); // 動作検出エリアを描画

    fill(0, 0, 255); // 青色で塗りつぶし
    rect(barX, barY, 30, 10); // バーを描画

    // 動作検出があった場合、位置を更新
    if (counter > 50) {
      x += x_move;
      y += y_move;
    }

    // バーの検出があった場合、位置を更新
    if (barCounter > 50) {
      barX += barMove;
      // バーの位置を画面内に制限
      if (barX < 0) {
        barX = 0;
      } else if (barX > width - 30) {
        barX = width - 30;
      }
    }
    
    // 点の移動方向を反転
    if (y <= 0) {
      y_move = -y_move;
    }

    // 点がバーに当たった場合の処理
    if (y >= barY - 10 && y <= barY + 10 && x >= barX && x <= barX + 30) {
      y_move = -y_move;
    }
    
    // 点が画面の左右端に達した場合の処理
    if (x <= 0 || x >= width - 10) {
      x_move = -x_move;
    }

    // 点が画面最下部に達した場合の処理
    if (y >= height - 10) {
      if (!(y >= barY - 10 && y <= barY + 10 && x >= barX && x <= barX + 30)) {
        // バーに当たらなかった場合、ゲームをリセット
        startDetection = false;
        return;
      }
    }

    // バーが画面の左右端に達した場合の処理
    if (barX >= width - 30 || barX <= 0) {
      barMove = -barMove;
    }

  } else {
    drawPlayButton(); // プレイボタンを描画
  }
}

// プレイボタンの描画
void drawPlayButton() {
  background(0); // 背景をクリア
  fill(255);
  rect(width / 2 - 50, height / 2 - 25, 100, 50, 10);
  fill(0, 0, 255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Play", width / 2, height / 2);
}

// マウスクリック時の処理
void mousePressed() {
  if (!startDetection) {
    if (mouseX > width / 2 - 50 && mouseX < width / 2 + 50 && mouseY > height / 2 - 25 && mouseY < height / 2 + 25) {
      startDetection = true;  // ボタンがクリックされたら動作検知を開始
      bg.copy(cam, 0, 0, width, height, 0, 0, width, height);  // 背景画像を初期化
      x = 0;  // 動作検出エリアの位置をリセット
      y = 0;  // 動作検出エリアの位置をリセット
      barX = 305;  // バーの位置を初期化
    }
  }
}

// キー押下時の処理
void keyPressed() {
  if (key == '1') {
    thresh_ += 1.0; // しきい値を増加
    println(thresh_);
  } else if (key == '2') {
    thresh_ -= 1.0; // しきい値を減少
    println(thresh_);
  }
}
