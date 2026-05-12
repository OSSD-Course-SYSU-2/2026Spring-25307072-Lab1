import { KeyCode } from '@ohos.multimodalInput.keyCode';

@Entry
@Component
struct SnakeGame {
  @State snake: number[][] = [];
  @State blackBlocks: number[][] = [];
  @State apple: number[] = [];
  @State appleType: number = 0; // 0红 1紫
  @State curDir: number[] = [0, 1];
  @State nextDir: number[] = [0, 1];
  @State gameRunning: boolean = false;
  @State gameOver: boolean = false;
  @State score: number = 0;
  @State length: number = 3;
  @State speed: number = 120; // 默认中等
  @State appleCount: number = 0;

  private timer: number = -1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private readonly cellSize: number = 25;
  private readonly mapSize: number = 15;
  private readonly mapPixel: number = this.mapSize * this.cellSize;

  aboutToAppear() {
    this.initGame();
  }

  initGame() {
    this.snake = [[7, 7], [7, 6], [7, 5]];
    this.blackBlocks = [];
    this.curDir = [0, 1];
    this.nextDir = [0, 1];
    this.appleCount = 0;
    this.score = 0;
    this.length = 3;
    this.gameOver = false;
    this.gameRunning = false;
    this.generateApple();
    this.drawGame();
  }

  startGame() {
    if (this.gameRunning) return;
    this.gameRunning = true;
    this.gameOver = false;
    if (this.timer !== -1) clearInterval(this.timer);
    this.timer = setInterval(() => {
      this.moveSnake();
      this.drawGame();
    }, this.speed);
    this.drawGame();
  }

  stopGame() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.gameRunning = false;
    this.drawGame();
  }

  gameEnd() {
    this.stopGame();
    this.gameOver = true;
    this.drawGame();
  }

  generateApple() {
    const all: number[][] = [];
    for (let i = 0; i < this.mapSize; i++)
      for (let j = 0; j < this.mapSize; j++)
        all.push([i, j]);
    const valid = all.filter(pos =>
    !this.snake.some(s => s[0] === pos[0] && s[1] === pos[1]) &&
      !this.blackBlocks.some(b => b[0] === pos[0] && b[1] === pos[1])
    );
    if (valid.length === 0) return;
    const randIndex = Math.floor(Math.random() * valid.length);
    this.apple = valid[randIndex];

    if (this.appleCount < 3) this.appleType = 0;
    else if (this.appleCount === 3) this.appleType = 1;
    else this.appleType = Math.random() < 0.8 ? 0 : 1;
  }

  moveSnake() {
    if (!this.gameRunning) return;
    this.curDir = this.nextDir;
    const head = this.snake[0];
    const newHead = [head[0] + this.curDir[0], head[1] + this.curDir[1]];

    if (newHead[0] < 0 || newHead[0] >= this.mapSize ||
      newHead[1] < 0 || newHead[1] >= this.mapSize) {
      this.gameEnd();
      return;
    }

    const ateApple = (this.apple.length > 0 && newHead[0] === this.apple[0] && newHead[1] === this.apple[1]);
    if (ateApple) {
      this.score += this.appleType === 0 ? 10 : 50;
      this.appleCount++;
      this.snake.unshift([newHead[0], newHead[1]]);
      if (this.appleType === 1) {
        const splitIdx = Math.floor(this.snake.length / 2);
        const keep = this.snake.slice(0, splitIdx);
        const toBlock = this.snake.slice(splitIdx);
        this.blackBlocks.push(...toBlock);
        this.snake = keep;
      }
      this.length = this.snake.length;
      this.generateApple();
    } else {
      this.snake.unshift([newHead[0], newHead[1]]);
      this.snake.pop();
      this.length = this.snake.length;
    }

    const headPos = this.snake[0];
    if (this.snake.slice(1).some(s => s[0] === headPos[0] && s[1] === headPos[1])) {
      this.gameEnd();
      return;
    }
    if (this.blackBlocks.some(b => b[0] === headPos[0] && b[1] === headPos[1])) {
      this.gameEnd();
    }
  }

  drawGame() {
    const ctx = this.ctx;
    const cell = this.cellSize;
    const mapPx = this.mapPixel;

    ctx.clearRect(0, 0, mapPx, mapPx);
    ctx.fillStyle = '#2d2d2d';
    ctx.fillRect(0, 0, mapPx, mapPx);
    ctx.strokeStyle = '#555';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= this.mapSize; i++) {
      ctx.beginPath();
      ctx.moveTo(i * cell, 0);
      ctx.lineTo(i * cell, mapPx);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(0, i * cell);
      ctx.lineTo(mapPx, i * cell);
      ctx.stroke();
    }

    this.snake.forEach((seg, idx) => {
      const x = seg[1] * cell, y = seg[0] * cell;
      ctx.fillStyle = idx === 0 ? '#4caf50' : '#2e7d32';
      ctx.fillRect(x, y, cell, cell);
      ctx.strokeStyle = '#000';
      ctx.lineWidth = 1;
      ctx.strokeRect(x, y, cell, cell);
    });

    this.blackBlocks.forEach(b => {
      const x = b[1] * cell, y = b[0] * cell;
      ctx.fillStyle = '#000';
      ctx.fillRect(x, y, cell, cell);
      ctx.strokeStyle = '#444';
      ctx.strokeRect(x, y, cell, cell);
    });

    if (this.apple.length > 0) {
      const ax = this.apple[1] * cell + cell / 2;
      const ay = this.apple[0] * cell + cell / 2;
      ctx.fillStyle = this.appleType === 0 ? '#f44336' : '#9c27b0';
      ctx.beginPath();
      ctx.arc(ax, ay, cell / 2 - 2, 0, 2 * Math.PI);
      ctx.fill();
      ctx.strokeStyle = '#fff';
      ctx.lineWidth = 1.5;
      ctx.stroke();
    }

    if (this.gameOver) {
      ctx.fillStyle = 'rgba(0,0,0,0.8)';
      ctx.fillRect(0, mapPx / 2 - 30, mapPx, 60);
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 24px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('游戏结束', mapPx / 2, mapPx / 2 + 8);
    } else if (!this.gameRunning) {
      ctx.fillStyle = 'rgba(0,0,0,0.7)';
      ctx.fillRect(0, mapPx / 2 - 30, mapPx, 60);
      ctx.fillStyle = '#fff';
      ctx.font = '20px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('选择难度并开始', mapPx / 2, mapPx / 2 + 8);
    }
  }

  changeDirection(dRow: number, dCol: number) {
    if (!this.gameRunning) return;
    if (dRow === -this.curDir[0] && dCol === -this.curDir[1]) return;
    this.nextDir = [dRow, dCol];
  }

  build() {
    Column() {
      Text('贪吃蛇')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 5 })

      Row() {
        Text(`分数：${this.score}`).fontSize(18).margin({ right: 24 })
        Text(`长度：${this.length}`).fontSize(18)
      }
      .margin({ bottom: 10 })

      Canvas(this.ctx)
        .width(this.mapPixel)
        .height(this.mapPixel)
        .backgroundColor('#2d2d2d')
        .focusable(true)
        .tabIndex(0)
        .onReady(() => {
          this.drawGame(); // 首次绘制
        })
        .onKeyEvent((event: KeyEvent) => {
          switch (event.keyCode) {
            case KeyCode.KEYCODE_DPAD_UP: this.changeDirection(-1, 0); break;
            case KeyCode.KEYCODE_DPAD_DOWN: this.changeDirection(1, 0); break;
            case KeyCode.KEYCODE_DPAD_LEFT: this.changeDirection(0, -1); break;
            case KeyCode.KEYCODE_DPAD_RIGHT: this.changeDirection(0, 1); break;
          }
          return true;
        })

      Row() { Button('↑').width(50).height(50).fontSize(22).onClick(() => this.changeDirection(-1, 0)) }
      .margin({ top: 12 })

      Row() {
        Button('←').width(50).height(50).fontSize(22).margin({ right: 20 }).onClick(() => this.changeDirection(0, -1))
        Button('↓').width(50).height(50).fontSize(22).margin({ right: 20 }).onClick(() => this.changeDirection(1, 0))
        Button('→').width(50).height(50).fontSize(22).onClick(() => this.changeDirection(0, 1))
      }
      .margin({ top: 6, bottom: 10 })

      Row() {
        Button('简单 (200ms)').fontSize(15).onClick(() => { this.speed = 200; this.initGame(); })
        Button('中等 (120ms)').fontSize(15).margin({ left: 10, right: 10 }).onClick(() => { this.speed = 120; this.initGame(); })
        Button('困难 (80ms)').fontSize(15).onClick(() => { this.speed = 80; this.initGame(); })
      }
      .margin({ bottom: 12 })

      Button(this.gameRunning ? '暂停' : (this.gameOver ? '重新开始' : '开始游戏'))
        .fontSize(18)
        .width(140)
        .onClick(() => {
          if (this.gameRunning) this.stopGame();
          else {
            if (this.gameOver) this.initGame();
            this.startGame();
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#eeeeee')
  }
}