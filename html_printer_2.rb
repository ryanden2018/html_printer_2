#!/usr/bin/env ruby

def escape(str)
  str.gsub("<","&lt;").gsub(">","&gt;")
end

def is_opening_tag(str)
  !!str.match(/\A<[^\/<>]*>\z/)
end

def is_closing_tag(str)
  !!str.match(/\A<\s*\/[^<>]*>\z/)
end

def is_tag(str)
  !!str.match(/\A<[^<>]*>\z/)
end

def closing_tag_exists(str,tokens)
  tag_name = str.gsub(/[<>\(\)\s]/," ").strip.split(" ")[0]
  tokens.any? do |token|
    !!token.match(/\A<\s*\/\s*#{tag_name}\s*>\z/)
  end
end

def process_html(tokens,fout)
  tab = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"

  num_indent = 0

  tokens.each do |token|
    if is_tag(token)
      if is_opening_tag(token) && closing_tag_exists(token,tokens)
        fout.write(tab*num_indent + escape(token) + "<br>")
        num_indent += 1
      elsif is_closing_tag(token)
        if num_indent > 0
          num_indent -= 1
        end
        fout.write(tab*num_indent + escape(token) + "<br>")
      else
        fout.write(tab*num_indent + escape(token) + "<br>")
      end
    else
      fout.write(tab*num_indent + token + "<br>")
    end
  end
end


if !ARGV[0] || !ARGV[1]
  puts "Usage: ruby html_printer.rb infile outfile"
  exit
end

# read input file from arglist
fin = File.new(ARGV[0],"r")
contents = nil
if fin
  contents = fin.read
  fin.close
else
  puts "I/O error: file #{ARGV[0]} could not be read"
  exit
end

# split file into tokens ("<html>", "<head>", textual blocks, ...)
tokens = contents.scan(/<[^>]*>|[^<>]+/).map { |token| token.strip }


# open output file for writing
fout = File.new(ARGV[1],"w")

if fout

  fout.write("<html>\n")
  fout.write("<head>\n")
  fout.write("<title>HTML Output</title>\n")
  fout.write("<style type='text/css'>\nbody {font-family:courier,courier new,serif;}</style>")
  fout.write("</head>\n")
  fout.write("<body>\n")

  process_html(tokens,fout)

  fout.write("</tt>\n")
  fout.write("</body>\n")
  fout.write("</html>\n")

  fout.close
else
  puts "I/O error: file #{ARGV[1]} could not be opened for writing"
  exit
end