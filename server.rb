#!/usr/bin/env ruby

require 'rubygems'
require 'sqlite3'
require 'webrick'

db = SQLite3::Database.new("sample.db")

s = WEBrick::HTTPServer.new(
  :Port => 8000,
  :DocumentRoot => File.join(Dir::pwd, "public_html")
)

s.mount_proc("/db") { |req, res|
  grade = req.query['grade']
  if grade
    sql = "SELECT * FROM students WHERE grade = #{grade}"
  else
    sql = "SELECT * FROM students"
  end
  File.open("sample.header.html") do |file|
    res.body += file.read
  end
  res.body += sql
  db.execute(sql) do |row|
    res.body += "<tr>"
    res.body += "<td>#{row[0]}</td>"
    res.body += "<td>#{row[1]}</td>"
    res.body += "<td>#{row[2]}</td>"
    res.body += "<td>#{row[3]}</td>"
    res.body += "<td>#{row[4]}</td>"
    res.body += "</tr>"
  end
  File.open("sample.footer.html") do |file|
    res.body += file.read
  end
}

Signal.trap("INT") { s.shutdown; db.close }
s.start
