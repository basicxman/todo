#!/usr/bin/env ruby

# @author: Andrew Horsman [basicxman]
# @description: A very simple todo that syncs with Dropbox.  Ruby client.

require 'dropbox'

class String
  
  def status_as_sym
    return case self
      when "$" then :complete
      when "^" then :incomplete
    end
  end

  def get_list_item
    return self.gsub(/[0-9]{10}\s+[\^\$]\s+/, "")
  end

end

class DropboxHelper

  def self.get_todo_list(settings)
    session = get_session
    session.download(settings["todo_path"])
  end


  def self.upload_todo_list(settings, todo_list)
    local_path = "todo_tmp_#{Time.now.to_i}.txt"
    File.open(local_path, "w") { |file| file.print todo_list }

    session = get_session
    session.upload(local_path, settings["todo_path"])
    
    if settings["remove_tmp_upload_files"]
      File.delete(local_path)
    end
  end

  def self.get_session(settings)
    opts = {
      :ssl => true,
      :authorizing_user => settings["username"],
      :authorizing_password => settings["password"]
    }
    session = Dropbox::Session.new(settings["dropbox_key"], settings["dropbox_secret"], opts)
    session.mode = :dropbox
    session.authorize!

    session
  end

end

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
    
    abort
  end

  def self.add(thing)

    abort
  end

  def self.done(search)
 
    abort
  end

  def self.parse_todo(limit = 200)
    todo = DropboxHelper::get_todo_list
    todo = todo.split("\n")
    todo = todo[0...limit] if limit > todo.length

    parsed_todo = []
    todo.each do |item|
      args = item.split(" ")
      temp = {
        :date => args[0],
        :status => args[1].status_as_sym
        :item => item.get_list_item
      }
      parsed_todo << temp
    end

    parsed_todo
  end

end

class Console

  def initialize
    get_configuration
    application_controller 
  end

  def get_configuration
    abort "Todo configuration file does not exist." unless File.exists? configuration_path 
    @settings = JSON.parse(File.read(configuration_path))
    abort if @settings.nil?
  end

  def configuration_path
    File.expand_path('~/.todo_config.json')
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
      Todo::add(second)     if arg == "add"     or arg == "a"
      Todo::done(second)    if arg == "done"    or arg == "d" or arg == "finish" or arg == "f" or arg == "-"
    end

    Todo::help
  end

end

todo_program_instance = Console.new
