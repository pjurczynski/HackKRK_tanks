#!/usr/bin/ruby

require "bundler/setup"
require "gaminator"


class Configuration
  PLAYERS = 4
  COLORS = [ Curses::COLOR_RED, Curses::COLOR_YELLOW, Curses::COLOR_GREEN, Curses::COLOR_CYAN ]
end
class Direction
  NORTH = 1
  EAST = 2
  SOUTH = 3
  WEST = 4
end

class Bullet
  attr_accessor :x, :y, :texture, :color, :direction, :power
	def initialize(x,y,direction,power=1)
    @x, @y = x, y
    @power = power
    @direction = direction
    @color = Curses::COLOR_RED
    @texture = [ '*' ]
  end
  
  def move
    case @direction
      when Direction::NORTH
        @y -= 1
      when Direction::EAST
        @x += 1
      when Direction::SOUTH
        @y += 1
      when Direction::WEST
        @x -= 1
    end
  end
end

TEXTURES = { 1 => [ '|', 'o' ], 2 => ['o-'], 3 => [ 'o', '|'], 4 => [ '-o'] }



class Tank
  attr_accessor :x, :y, :texture, :color, :power, :direction, :energy, :tank_number
  
  def initialize(game, x,y,direction=Direction::NORTH, energy=40, power=1)
    @x, @y = x, y
    @game = game
    @power, @energy = power, energy
    @@tank_number ||= 0
    @@tank_number += 1
    @tank_number = @@tank_number
    @direction = direction
    @color = Configuration::COLORS[@tank_number-1]
  end
  
  def fire
    @game.add_bullet(x,y,direction)
  end
  
  def pixels
    Set.new(self.texture.map.with_index{|r,ri|
      r.each_char.map.with_index{|c,ci| [@x+ci,@y+ri]}}.flatten(1))
  end
  
  def texture
    TEXTURES[self.direction]
  end
  
  def move
    case @direction
      when Direction::NORTH
        @y -= 1
      when Direction::EAST
        @x += 1
      when Direction::SOUTH
        @y += 1
      when Direction::WEST
        @x -= 1
    end
  end
end

class TankGame
  attr_reader :width, :height, :board
  def initialize(width, height)
    @width, @height = width, height
    @tanks = []
    @tanks << Tank.new(self, 0, 0, Direction::SOUTH)
    @tanks << Tank.new(self, width-1, height-2, Direction::NORTH)
    @tanks << Tank.new(self, 0, height-2, Direction::NORTH)
    @tanks << Tank.new(self, width-1, 0, Direction::SOUTH)
    @tanks = @tanks[ 0, Configuration::PLAYERS ]
    @bullets = []
    
    @bullets << Bullet.new(0, 10, Direction::SOUTH)
  end


  def exit_message
  end
  
  def tick
    @tanks.each(&:move)
    @bullets.each(&:move)
    check_collision
  end
  
  def check_collision
    @board = []
    @width.times do |w|
      @board << Array.new(@height, nil)
    end
    @tanks.each { |tank|
      @board[tank.x][tank.y] = tank
    }
    @bullets.each do |bullet|
      if tank = @board[bullet.x][bullet.y]
        tank.energy -= bullet.power
        @bullets.delete(bullet)
      end
    end
    
  end
  def objects
    @tanks + @bullets
  end
  
  def each
  end
  
  def textbox_content
    "Player1: %s\t\tPlayer2: %s\t\tPlayer3: %s\t\tPlayer4: %s\t\t" % @tanks.map(&:energy)
  end
  
  def wait?
    false
  end
  
  def input_map
    {
      ?w => :move_up,
      ?d => :move_right,
      ?s => :move_down,
      ?a => :move_left,
      ?e => :tank_fire,
      ?q => :exit
    }
	end

  def move_up(number)
    @tanks[number].y -= 1
    @tanks[number].direction = Direction::NORTH
  end
  def move_right(number)
    @tanks[number].x += 1
    @tanks[number].direction = Direction::EAST
  end
  def move_down(number)
    @tanks[number].y += 1
    @tanks[number].direction = Direction::SOUTH
  end
  def move_left(number)
    @tanks[number].x -= 1
    @tanks[number].direction = Direction::WEST
  end
  def tank_fire
  end
	
	def sleep_time
	  0.1
	end
	
	def add_bullet(x,y,direction)
	  b = Bullet.new(x,y,direction)
	  @bullets << b
	end
end


Gaminator::Runner.new(TankGame).run
