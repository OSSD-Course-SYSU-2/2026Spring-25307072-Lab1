class Pos {
  x: number = 0
  y: number = 0
  constructor(x: number, y: number) {
    this.x = x
    this.y = y
  }
}

class Apple {
  x: number
  y: number
  type: 'red' | 'purple'
  constructor(x: number, y: number, type: 'red' | 'purple') {
    this.x = x
    this.y = y
    this.type = type
  }
}

@Entry
@Component
struct SnakeGame {
  @State gridSize: number = 15
  @State cellSize: number = 20
  @State snake: Pos[] = []
  @State moveDir: Pos = new Pos(1, 0)
  @State nextMoveDir: Pos = new Pos(1, 0)
  @State apple: Apple | null = null
  @State score: number = 0
  @State gameSpeed: number = 200
  @State isGameOver: boolean = false
  @State isPaused: boolean = false
  @State appleCount: number = 0
  @State obstacles: Pos[] = []               // 统一使用 obstacles
  private gameTimer: number = -1

  aboutToAppear() {
    this.resetGame()
  }

  aboutToDisappear() {
    this.stopGame()
  }

  resetGame() {
    this.snake = [
      new Pos(5, 7),
      new Pos(4, 7),
      new Pos(3, 7)
    ]
    this.moveDir = new Pos(1, 0)
    this.nextMoveDir = new Pos(1, 0)
    this.score = 0
    this.isGameOver = false
    this.isPaused = false
    this.appleCount = 0
    this.obstacles = []                       // 修正拼写
    this.spawnApple()
    this.startGame()
  }

  startGame() {
    this.stopGame()
    this.gameTimer = setInterval(() => {
      this.gameLoop()
    }, this.gameSpeed)                       // setInterval 返回 number，无需断言
  }

  stopGame() {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
      this.gameTimer = -1
    }
  }

  gameLoop() {
    if (this.isGameOver || this.isPaused) {
      return
    }
    this.moveDir = new Pos(this.nextMoveDir.x, this.nextMoveDir.y)
    this.moveSnake()
  }

  moveSnake() {
    const head = this.snake[0]
    const newHead = new Pos(
      head.x + this.moveDir.x,
      head.y + this.moveDir.y
    )

    // 撞墙
    if (newHead.x < 0 || newHead.x >= this.gridSize || newHead.y < 0 || newHead.y >= this.gridSize) {
      this.gameOver()
      return
    }

    // 撞自己
    let hitSelf = false
    for (let i = 0; i < this.snake.length; i++) {
      if (this.snake[i].x === newHead.x && this.snake[i].y === newHead.y) {
        hitSelf = true
        break
      }
    }
    if (hitSelf) {
      this.gameOver()
      return
    }

    // 撞障碍物
    let hitObs = false
    for (let i = 0; i < this.obstacles.length; i++) {
      if (this.obstacles[i].x === newHead.x && this.obstacles[i].y === newHead.y) {
        hitObs = true
        break
      }
    }
    if (hitObs) {
      this.gameOver()
      return
    }

    // 移动蛇头
    this.snake.unshift(newHead)

    // 吃苹果判定
    if (this.apple && newHead.x === this.apple.x && newHead.y === this.apple.y) {
      this.eatApple()
    } else {
      this.snake.pop()
    }
  }

  eatApple() {
    if (!this.apple) return
    this.appleCount++

    if (this.apple.type === 'red') {
      this.score += 10
    } else if (this.apple.type === 'purple') {
      this.score += 50
      const tail = this.snake[this.snake.length - 1]
      this.snake.push(new Pos(tail.x, tail.y))
      this.splitSnake()
    }
    this.spawnApple()
  }

  splitSnake() {
    if (this.snake.length <= 1) return
    const splitIndex = Math.floor(this.snake.length / 2)
    const brokenParts = this.snake.slice(splitIndex)
    this.snake = this.snake.slice(0, splitIndex)
    for (let i = 0; i < brokenParts.length; i++) {
      this.obstacles.push(new Pos(brokenParts[i].x, brokenParts[i].y))
    }
  }

  spawnApple() {
    const emptyCells: Pos[] = []
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        let isSnake = false
        for (let i = 0; i < this.snake.length; i++) {
          if (this.snake[i].x === x && this.snake[i].y === y) {
            isSnake = true
            break
          }
        }
        let isObs = false
        for (let i = 0; i < this.obstacles.length; i++) {
          if (this.obstacles[i].x === x && this.obstacles[i].y === y) {
            isObs = true
            break
          }
        }
        if (!isSnake && !isObs) {
          emptyCells.push(new Pos(x, y))
        }
      }
    }
    if (emptyCells.length === 0) return

    const idx = Math.floor(Math.random() * emptyCells.length)
    const pos = emptyCells[idx]
    let type: 'red' | 'purple' = 'red'

    if (this.appleCount < 3) {
      type = 'red'
    } else if (this.appleCount === 3) {
      type = 'purple'
    } else {
      type = Math.random() < 0.8 ? 'red' : 'purple'
    }
    this.apple = new Apple(pos.x, pos.y, type)
  }

  gameOver() {
    this.isGameOver = true
    this.stopGame()
  }

  changeDirection(newDir: Pos) {
    if (this.moveDir.x + newDir.x === 0 && this.moveDir.y + newDir.y === 0) {
      return
    }
    this.nextMoveDir = newDir
  }

  setSpeed(speed: number) {
    this.gameSpeed = speed
    if (!this.isGameOver && !this.isPaused) {
      this.startGame()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text('贪吃蛇')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ right: 20 })

          Text(`分数: ${this.score}`)
            .fontSize(18)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 10 })

        Row() {
          Button('简单')
            .onClick(() => { this.setSpeed(200) })
            .margin({ right: 10 })

          Button('中等')
            .onClick(() => { this.setSpeed(120) })
            .margin({ right: 10 })

          Button('困难')
            .onClick(() => { this.setSpeed(70) })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 10 })

        // 游戏网格
        Grid() {
          ForEach(this.snake, (segment: Pos, index: number) => {
            GridItem() {
              Rect()                                    // 使用 Rect 替代 Rectangle
                .fill(index === 0 ? '#4CAF50' : '#8BC34A')
                .borderRadius(2)
                .width('100%')
                .height('100%')
            }
            .columnStart(segment.x)
            .columnEnd(segment.x + 1)
            .rowStart(segment.y)
            .rowEnd(segment.y + 1)
          }, (s: Pos, index: number) => `${s.x}-${s.y}-${index}`)

          if (this.apple) {
            GridItem() {
              Circle({ width: '80%', height: '80%' })   // 使用 Circle 组件，传入尺寸参数
                .fill(this.apple.type === 'red' ? '#F44336' : '#9C27B0')
            }
            .columnStart(this.apple.x)
            .columnEnd(this.apple.x + 1)
            .rowStart(this.apple.y)
            .rowEnd(this.apple.y + 1)
          }

          ForEach(this.obstacles, (obs: Pos) => {
            GridItem() {
              Rect()                                    // 使用 Rect 替代 Rectangle
                .fill('#000000')
                .borderRadius(2)
                .width('100%')
                .height('100%')
            }
            .columnStart(obs.x)
            .columnEnd(obs.x + 1)
            .rowStart(obs.y)
            .rowEnd(obs.y + 1)
          }, (o: Pos) => `${o.x}-${o.y}`)
        }
        .columnsTemplate(Array(this.gridSize).fill('1fr').join(' '))
        .rowsTemplate(Array(this.gridSize).fill('1fr').join(' '))
        .width(this.gridSize * this.cellSize)
        .height(this.gridSize * this.cellSize)
        .backgroundColor('#F5F5DC')
        .margin({ bottom: 10 })

        Row() {
          Button('暂停/继续')
            .onClick(() => { this.isPaused = !this.isPaused })
            .margin({ right: 10 })

          Button('重新开始')
            .onClick(() => { this.resetGame() })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Column({ space: 5 }) {
          Button('↑')
            .onClick(() => { this.changeDirection(new Pos(0, -1)) })

          Row({ space: 10 }) {
            Button('←')
              .onClick(() => { this.changeDirection(new Pos(-1, 0)) })

            Button('↓')
              .onClick(() => { this.changeDirection(new Pos(0, 1)) })

            Button('→')
              .onClick(() => { this.changeDirection(new Pos(1, 0)) })
          }
        }
        .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .padding(20)

      // 游戏结束浮层
      if (this.isGameOver) {
        Column() {
          Text('游戏结束')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ff0000')
          Text(`得分：${this.score}`)
            .fontSize(20)
            .margin({ top: 10 })
        }
        .backgroundColor('#ffffffcc')
        .padding(20)
        .borderRadius(10)
      }
    }
    .width('100%')
    .height('100%')
  }
}