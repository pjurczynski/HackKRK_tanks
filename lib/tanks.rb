require "bundler/setup"                                                                                                                                      
require "gaminator"
require 'pry'

class Tanks
  class Item < Struct.new(:x, :y)
    def blocking?
      false
    end
  end

  class Brick < Item
    def char
      '@'
    end
    
    def blocking?
      true
    end
    
    def color
      Curses::COLOR_RED
    end   
  end

  class Wall < Item
    def char
      '#'
    end

    def blocking?
      true
    end
       
    def color
      Curses::COLOR_GREEN
    end
  end

  class Water < Item
    def char
      'w'  
    end
    
    def blocking?
      true
    end
  end

  class Tank < Item
    def char
      'o'
    end
    def color
      Curses::COLOR_BLUE
    end
  end

  def initialize(width, height)
    @ticks = 100
    @width = width
    @height = height
    @score = 0
    @map = Map.new
    @map.load_map File.join(File.dirname(__FILE__), "../level2.txt")
    puts @map.types.keys
    reset_speed
  end
  def wait?
    false
  end

  def tick
    check_end
  end

  def check_end
  end
  def input_map
    {
      ?a => :move_left,
      ?w => :move_top,
      ?s => :move_down,
      ?d => :move_right
    }
  end

  def reset_speed
    @speed = 0
  end

  def sleep_time
    0.05
  end

  def textbox_content
    ""
  end

  def exit_message
    @status
  end

  def objects
    @map.objects
  end

  class Map < Hash
    attr_accessor :types

    OBJECT_MAPPING = {
      '#' => Wall,
      "R" => Tank,
      "w" => Water,
      "@" => Brick
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

Gaminator::Runner.new(Tanks).run
