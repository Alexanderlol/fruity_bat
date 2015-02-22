require 'gosu'
require 'defstruct'
require_relative 'vector'

GRAVITY = Vec[0, 600] # pixels/s^2
JUMP_VEL = Vec[0, -300] # pixel/s
OBSTACLE_SPEED = 200 # pixel/s
OBSTACLE_SPAWN_INTERVAL = 1.3 #seconds
OBSTACLE_GAP = 100 #pixels

GameState = DefStruct.new{{
  scroll_x: 0,
  player_pos: Vec[0,0],
  player_vel: Vec[0,0],
  obstacles: [], # array of Vec
  obstacle_countdown: OBSTACLE_SPAWN_INTERVAL,
}}

class GameWindow < Gosu::Window
  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new(self, 'images/background.png', false),
      foreground: Gosu::Image.new(self, 'images/foreground.png', true),
      player: Gosu::Image.new(self, 'images/fruity_1.png', false),
      obstacle: Gosu::Image.new(self, 'images/obstacle.png', false),
    }
    @state = GameState.new
  end

  def button_down(button)
    case button
    when Gosu::KbEscape then close
    when Gosu::KbSpace then @state.player_vel.set!(JUMP_VEL)
    end
  end

  def spawn_obstacle
    @state.obstacles << Vec[width, rand(50..320)]
  end

  def update
    dt = update_interval / 1000.0

    @state.scroll_x += dt*OBSTACLE_SPEED*0.5
    if @state.scroll_x > @images[:foreground].width
      @state.scroll_x = 0
    end

    @state.player_vel += dt*GRAVITY
    @state.player_pos += dt*@state.player_vel

    @state.obstacle_countdown -= dt
    if @state.obstacle_countdown <= 0
      spawn_obstacle
      @state.obstacle_countdown += OBSTACLE_SPAWN_INTERVAL
    end

    @state.obstacles.each do |obst|
      obst.x -= dt*OBSTACLE_SPEED
    end
  end

  def draw
    @images[:background].draw(0, 0, 0)
    @images[:foreground].draw(-@state.scroll_x, 0, 0)
    @images[:foreground].draw(-@state.scroll_x + @images[:foreground].width, 0, 0)

    @state.obstacles.each do |obst|
      img_y = @images[:obstacle].height 
      # top log
      @images[:obstacle].draw(obst.x, obst.y - img_y, 0)
      scale(1, -1) do
        # bottom log
        @images[:obstacle].draw(obst.x, -height - img_y + (height - obst.y - OBSTACLE_GAP), 0)
      end
    end

    @images[:player].draw(20, @state.player_pos.y, 0)
  end
end

window = GameWindow.new(320, 480, false)
window.show
