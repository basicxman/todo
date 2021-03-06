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

class Fixnum

  def to_date
    time = Time.at(self)
    "#{time.month}/#{time.day}/#{time.year}"
  end

  def to_time
    time = Time.at(self)
    "#{time.hour}:#{time.sec}"
  end

  def to_date_time
    self.to_date + " " + self.to_time
  end

end

class DropboxHelper

  def initialize(settings)
    @settings = settings
  end

  def get_local_todo_path
    File.expand_path(@settings["dropbox_path"] + @settings["todo_path"] + @settings["todo_name"])
  end

  def get_todo_list
    return get_todo_list_offline if File.exists? get_local_todo_path
    return get_todo_list_online
  end
  
  def upload_todo_list(todo_list = nil)
    if todo_list.nil?
      upload_todo_list_online unless File.exists? get_local_todo_path
    else
      return upload_todo_list_offline(todo_list) if File.exists? get_local_todo_path
      return upload_todo_list_online(todo_list)
    end
  end

  def get_todo_list_offline
    File.read(get_local_todo_path)
  end

  def get_todo_list_online
    session = get_session
    session.download(@settings["todo_path"])
  end

  def upload_todo_list_online(todo_list = nil)
    session = get_session

    if todo_list.nil?
      session.upload(get_local_todo_path, @settings["todo_path"])
    else
      local_path = "todo_tmp_#{Time.now.to_i}.txt"
      File.open(local_path, "w") { |file| file.print todo_list }

      session.upload(local_path, @settings["todo_path"])
    
      if @settings["remove_tmp_upload_files"]
        File.delete(local_path)
      end
    end
  end

  def upload_todo_list_offline(todo_list)
    File.open(get_local_todo_path, "w") { |file| file.print todo_list }
  end

  def get_session
    opts = {
      :ssl => true,
      :authorizing_user => @settings["username"],
      :authorizing_password => @settings["password"]
    }
    session = Dropbox::Session.new(@settings["dropbox_key"], @settings["dropbox_secret"], opts)
    session.mode = :dropbox
    session.authorize!

    session
  end

end

class Todo

  def initialize(settings)
    @dropbox  = DropboxHelper.new(settings)
  end

  def help
    puts "Todo Help"
    puts "todo list - List all current uncompleted items."
    puts "todo history - List all items."
    puts "todo history 30 - List the last thirty items."
    puts "todo add \"Take out trash.\" - Add an item to the todo list."
    puts "todo done \"trash\" - Finish an item."
    puts "todo sync - Manually upload local copy of todo list to Dropbox."
    abort
  end

  def sync
    puts "Uploading #{@dropbox.get_local_todo_path} to Dropbox."
    @dropbox.upload_todo_list_online
    abort
  end

  def history(length = nil)
    items = (length.nil?) ? parse_todo : parse_todo(length)

    items.each_with_index do |item, list_number|
      date   = item[:date].to_i.to_date_time
      status = item[:status].to_s.capitalize
      item   = item[:item]

      puts "#{list_number}. #{date} - #{status} - #{item}"
    end

    abort
  end

  def add(thing)
    todo_list = @dropbox.get_todo_list
    new_item = "#{Time.now.to_i} ^ #{thing}\n"
    todo_list = new_item + todo_list
    
    @dropbox.upload_todo_list(todo_list)
    abort
  end

  def done(search)
 
    abort
  end

  def parse_todo(limit = 200)
    todo = @dropbox.get_todo_list
    todo = todo.split("\n")
    todo = todo[0...limit] if limit > todo.length

    parsed_todo = []
    todo.each do |item|
      args = item.split(" ")
      temp = {
        :date => args[0],
        :status => args[1].status_as_sym,
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
    todo = Todo.new(@settings)
    if ARGV.length == 1
      arg = ARGV[0]

      todo.help    if arg == "help"    or arg == "?"
      todo.history if arg == "history" or arg == "h"
      todo.sync    if arg == "sync"    or arg == "s"
    else
      arg = ARGV[0]
      second = ARGV[1]

      todo.history(second) if arg == "history" or arg == "h"
      todo.add(second)     if arg == "add"     or arg == "a"
      todo.done(second)    if arg == "done"    or arg == "d" or arg == "finish" or arg == "f" or arg == "-"
    end

    todo::help
  end

end

todo_program_instance = Console.new
