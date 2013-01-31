#!/usr/bin/ruby

require "bundler/setup"
require "gaminator"


class Configuration
  PLAYERS = 4
  COLORS = [ Curses::COLOR_RED, Curses::COLOR_BLUE, Curses::COLOR_GREEN, Curses::COLOR_CYAN ]
end
class Direction
  NORTH = 1
  EAST = 2
  NORTH = 3
  WEST = 4
end

class Bullet
	def initialize(x,y,power=1)
    @x, @y = x, y
    @power = power
  end
end

class Tank
  attr_accessor :x, :y, :texture, :color, :power, :direction, :energy
  
  def initialize(x,y,energy=40, power=1)
    @x, @y = x, y
    @power, @energy = power, energy
    @@tank_number ||= 0
    @@tank_number += 1
    @direction = @@tank_number % 4 + 1
    @texture = [ 'o', '|' ]
    @color = Configuration::COLORS[@@tank_number % 4 + 1]
  end
  
  def fire
  
  end
  
  def pixels
    Set.new(self.texture.map.with_index{|r,ri|
      r.each_char.map.with_index{|c,ci| [@x+ci,@y+ri]}}.flatten(1))
  end
end

class TankGame
  attr_reader :width, :height
  def initialize(width, height)
    @tanks = [ Tank.new(0, 0) ]
  end


  def exit_message
  end
  
  def tick
  end
  
  def objects
    @tanks
  end
  
  def each
  end
  
  def textbox_content
    'x' * 160
  end
  
  def wait?
  end
  
  def input_map
    {}
	end
	
	def sleep_time
	  1
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
