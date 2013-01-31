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
	def initialize(x,y,direction,power=1)
    @x, @y = x, y
    @power = power
    @direction = direction
  end
end

TEXTURES = { 1 => [ '|', 'o' ], 2 => ['o-'], 3 => [ 'o', '|'], 4 => [ '-o'] }



class Tank
  attr_accessor :x, :y, :texture, :color, :power, :direction, :energy, :tank_number
  
  def initialize(x,y,direction=Direction::NORTH, energy=40, power=1)
    @x, @y = x, y
    @power, @energy = power, energy
    @@tank_number ||= 0
    @@tank_number += 1
    @tank_number = @@tank_number
    @direction = direction
    @color = Configuration::COLORS[@tank_number-1]
  end

  def char
    'o'
  end
  
  def fire
  
  end
  
  def pixels
    Set.new(self.texture.map.with_index{|r,ri|
      r.each_char.map.with_index{|c,ci| [@x+ci,@y+ri]}}.flatten(1))
  end
  
  def texture
    TEXTURES[self.direction]
  end
end

class TankGame
  attr_reader :width, :height
  def initialize(width, height)
    #@tanks = []
    #@tanks << Tank.new(0, 0, Direction::SOUTH)
    #@tanks << Tank.new(width-1, height-2, Direction::NORTH)
    #@tanks << Tank.new(0, height-2, Direction::NORTH)
    #@tanks << Tank.new(width-1, 0, Direction::SOUTH)
    #@tanks = @tanks[ 0, Configuration::PLAYERS ]
    @map = Map.new
    @map.load_map File.join(File.dirname(__FILE__), "l2.txt")
    @tanks = @map.types['Tank']
    @bullets = []
  end

  def exit_message
  end
  
  def tick
  end
  
  def objects
    @map.objects + @bullets
  end
  
  def each
  end
  
  def textbox_content
    "Player1: %s\t\tPlayer1: %s\t\tPlayer1: %s\t\tPlayer1: %s\t\t" % @tanks.map(&:energy)
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

  def move_up
    @tanks.first.y -= 1
    @tanks.first.direction = Direction::NORTH
  end
  def move_right
    @tanks.first.x += 1
    @tanks.first.direction = Direction::EAST
  end
  def move_down
    @tanks.first.y += 1
    @tanks.first.direction = Direction::SOUTH
  end
  def move_left
    @tanks.first.x -= 1
    @tanks.first.direction = Direction::WEST
  end
  def tank_fire
  end
	
	def sleep_time
    0.05
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


=begin

class Entity
  attr_accessor :x, :y, :texture, :color, :colors
  COLOR_MAP = {
    :white => Curses::COLOR_WHITE,
    :red => Curses::COLOR_RED,
    :blue => Curses::COLOR_BLUE,
    :green => Curses::COLOR_GREEN,
    :cyan => Curses::COLOR_CYAN,
    :magenta => Curses::COLOR_MAGENTA,
    :yellow => Curses::COLOR_YELLOW
  }
  SHORT_COLOR_MAP = Hash[COLOR_MAP.map{|k,v| [k.to_s[0],v]}]

  PATH = File.join(File.dirname(__FILE__), "data/")
  TEXTURE_EXT = ".txt"
  COLORS_EXT = ".col"

  def initialize(x,y,texture,color)
    @x, @y = x, y
    @texture = File.read(PATH + texture + TEXTURE_EXT).split("\n")
    if File.exist?(PATH + texture + COLORS_EXT)
      @colors = File.read(PATH + texture + COLORS_EXT).split("\n").
        map{|r| r.each_char.map{|c| SHORT_COLOR_MAP[c] || Curses::COLOR_WHITE } }
      @color = COLOR_MAP[color]
    else
      @color = COLOR_MAP[color]
    end
  end

  def pixels
    Set.new(self.texture.map.with_index{|r,ri|
      r.each_char.map.with_index{|c,ci| [@x+ci,@y+ri]}}.flatten(1))
  end
end

# This is just a demonstration of the texture feature.
# Nothing happens here.
class HouseGame
  attr_reader :width, :height

  def initialize(width, height)
    @entities = [
      Entity.new(30,10,"house",:cyan),
    ]
  end

  def wait?
    true
  end

  def objects
    @entities
  end

  def input_map
    {
      ?j => :move_left,
      ?l => :move_right,
      ?i => :move_up,
      ?k => :move_down,
      ?q => :exit,
    }
  end

  def move_left
    @entities.first.x -= 1
  end

  def move_right
    @entities.first.x += 1
  end

  def move_down
    @entities.first.y += 1
  end

  def move_up
    @entities.first.y -= 1
  end

  def exit
    Kernel.exit
  end

  def exit_message
    puts "Nothing bad happened."
  end

  def textbox_content
    "This is demonstration of texture feature. Use j,k,l,i to move the house. q to exit"
  end

  def sleep_time
    0.05
  end

  def tick
  end
end

Gaminator::Runner.new(HouseGame).run

=end
