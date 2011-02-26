#!/usr/bin/env ruby

# @author: Andrew Horsman [basicxman]
# @description: A very simple todo that syncs with Dropbox.  Ruby client.

class Todo

  def self.help
    puts "Todo Help"
    puts "todo list - List all current uncompleted items."
    puts "todo history - List all items."
    puts "todo history 30 - List the last thirty items."
    puts "todo add \"Take out trash.\" - Add an item to the todo list."
    puts "todo done \"trash\" - Finish an item."
    abort
  end

  def self.history(length = nil)

  end

  def self.add(thing)

  end

  def self.done(search)
  
  end

end

class Console

  def initialize
    application_controller 
  end

  def application_controller
    if ARGV.length == 1
      arg = ARGV[0]

      Todo::help    if arg == "help" or arg == "?"
      Tood::history if arg == "history" or arg == "h"
    else
      arg = ARGV[0]
      second = ARGV[1]

      Todo::history(second) if arg == "history" or arg == "h"
      Todo::add(second)     if arg == "add" or arg == "a"
      Todo::done(second)    if arg == "done" or arg == "d" or arg == "finish" or arg == "f" or arg == "-"
    end

    help
  end

end

todo_program_instance = Console.new
