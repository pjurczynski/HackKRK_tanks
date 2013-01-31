#!/usr/bin/ruby

require "bundler/setup"
require "gaminator"
require 'pry'


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
  attr_accessor :x, :y, :texture, :color, :direction, :power, :tank
	def initialize(x,y,direction,tank,power=1)
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
  attr_accessor :x, :y, :texture, :color, :power, :direction, :energy, :tank_number, :temperature
  
  def initialize(game, x,y,direction=Direction::NORTH, energy=40, power=1)
    @x, @y = x, y
    @game = game
    @power, @energy = power, energy
    @@tank_number ||= 0
    @@tank_number += 1
    @tank_number = @@tank_number
    @direction = direction
    @temperature = 5
    @color = Configuration::COLORS[@tank_number-1]
  end

  def char
    'o'
  end
  
  def fire
    if @temperature <= 0
      @game.add_bullet(x,y,direction, self)
      @temperature = 5
    end
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
    @temperature -= 1
    self.fire
  end
  
  def hit(bullet)
    self.energy -= bullet.power
    if self.energy <= 0
      self.destroy_tank
    end
  end
  
  def destroy_tank
    @game.tanks.delete(self)
  end
end


class TankGame
  attr_reader :width, :height, :board, :tanks
  def initialize(width, height)
    @width, @height = width, height
    @tanks = []
    tank_game= self


    @map = Map.new(self)
    @map.load_map File.join(File.dirname(__FILE__), "l2.txt")
    @tanks = @map.types['Tank']
    @tanks = []
    @tanks << Tank.new(self, 0, 0, Direction::SOUTH)
    @tanks << Tank.new(self, width-1, height-2, Direction::NORTH)
    @tanks << Tank.new(self, 0, height-2, Direction::NORTH)
    @tanks << Tank.new(self, width-1, 0, Direction::SOUTH)
    @tanks = @tanks[ 0, Configuration::PLAYERS ]

    @bullets = []
    @tick_counter = 0
  end

  def exit_message
  end
  
  def tick
    @tick_counter += 1
        @tanks.first.fire

    @tanks.each(&:move) if @tick_counter % 2 == 0
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
      if @board[bullet.x][bullet.y] && bullet.tank != @board[bullet.x][bullet.y]
        tank = @board[bullet.x][bullet.y]
        tank.hit(bullet)
        @bullets.delete(bullet)
      end
    end
  end
  def objects
    @map.objects + @bullets
  end
  
  def each
  end
  
  def textbox_content
    @tanks.map { |tank, inx| "Player#{inx}: #{tank.energy}" }.join("\t\t") 
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
	  0.05
	end
	
	def add_bullet(x,y,direction, tank)
	  b = Bullet.new(x,y,direction, tank)
	  @bullets << b
	end

  class Item < Struct.new(:x, :y)
    def blocking?
      false
    end
  end

  class Wall < Item
    def char
      '#'
    end

    def blocking?
      true
    end
  end

  class Map < Hash
    attr_accessor :types

    OBJECT_MAPPING = {
      '#' => Wall,
      "R" => Tank
    }

    def get(x, y)
      self[x][y] if self[x]
    end

    def set(x, y, value)
      self[x] = {} unless self[x]
      self[x][y] = value
    end

    def load_map(file)
      @objects = []
      @types = {}
      file = File.open(file)
      y = 0
      file.each_line do |line|
        x = 0
        line.chomp.each_char do |char|
          self.resolve_object(char, x, y)
          x += 1
        end
        y += 1
      end
    end

    def resolve_object(char, x, y)
      if klass = OBJECT_MAPPING[char]
        instance = klass.new(x, y)
        self.set(x, y, instance)
        @objects.push instance
        name = klass.name.split('::').last
        @types[name] ||= []
        @types[name].push(instance)
      end
    end

    def objects
      @objects
    end
  end
end



Gaminator::Runner.new(TankGame).run
