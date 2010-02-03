#!/usr/bin/env ruby

# modifies the header file 

if ARGV[1] =~ /dev/
  extra_class = 'dev'
elsif ARGV[1] =~ /stag/
  extra_class = 'staging'
else
  extra_class = nil
end
class_spec = extra_class ? %[ class="#{extra_class}"] : ''
  
header_file = 'app/views/layouts/_header.html.erb'
header_view = File.read header_file
header_view.gsub! /\<div id="site_header".*?\>/, %[<div id="site_header"#{class_spec}>]
File.open(header_file, 'w') { |f| f.write header_view }
