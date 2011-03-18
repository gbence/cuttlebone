#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/cuttlebone', __FILE__)

##
# MODEL

class Task
  @@id = 0
  attr_accessor :id, :title
  def initialize options={}
    @id    = (@@id+=1)
    @title = options.delete(:title)
  end
end

##
# CUTTLEBONE DESCRIPTIONS

context Array do
  #def find_task_by_id(id_s)
  #  id = id_s.to_i
  #  detect { |t| t.id == id }
  #end

  prompt()    { "tasks(#{size})" }

  command(?l) { each { |t| output('(%03d) %50s' % [t.id, t.title]) } }
  command(?n) { send(:<<, t = Task.new); add t }
  command /^([0-9]+)$/ do |id_s|
    #t = find_task_by_id(id_s)
    id = id_s.to_i
    t  = detect { |t| t.id == id }
    add(t) if t
  end
  command /^d ([0-9]+)$/ do |id_s|
    #t = find_task_by_id(id_s)
    id = id_s.to_i
    t  = detect { |t| t.id == id }
    delete(t)
  end
  command(?q) { drop }
end

context Task do
  prompt()    { ('%03d' % [id]) + (' ' + (title.size<=20 ? title : "#{title[0..18]}…") rescue '') }

  command(?q) { drop }
  command /^(.+)$/ do |text|
    send(:title=, text)
  end
end

at_exit do
  Cuttlebone.run([Task.new(:title => 'x'), Task.new(:title => 'y')])
end
