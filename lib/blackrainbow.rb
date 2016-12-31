require "blackrainbow/version"

require 'digest'
require 'commander'

require 'blackgen'

module Blackrainbow
  # Your code goes here...

  class BlackrainbowApplication
    include Commander::Methods

    def run
      program :name, 'Blackrainbow'
      program :version, Blackrainbow::VERSION
      program :description, 'Rainbow table generator.'

      command :find do |c|
        c.syntax = 'blackgen full'
        c.description = 'Generate incremental word list'
        c.option '-m', '--min SIZE', Integer, 'Set min size'
        c.option '-M', '--max SIZE', Integer, 'Set max size'
        c.option '-c', '--charset CHARSET', String, 'Set max size'
        c.option '-i', '--input INPUT', String, 'the target hash'
        c.option '-a', '--algorithm ALGORITHM', String, 'The hash algorithm'
        c.action do |args, options|
          options.default \
  				     :min => 1,
               :max => 8,
               :charset => [('a'..'z'), ('A'..'Z'), ('!'..'?')].map { |i| i.to_a }.flatten,
               :algorithm => 'md5'

          if options.charset.kind_of?(String)
            options.charset = options.charset.split('')
          end

          generator = Blackgen::FullGenerator.new(options.charset, options.min, options.max)

          for i in generator.first..generator.last
            step = generator.step(i)
            hash = Digest::SHA256.hexdigest step
            print "#{step}\r"

            if hash == options.input
              puts step
              return
            end
          end
        end
      end

      command :generate do |c|
        c.syntax = 'blackgen full'
        c.description = 'Generate incremental word list'
        c.option '-m', '--min SIZE', Integer, 'Set min size'
        c.option '-M', '--max SIZE', Integer, 'Set max size'
        c.option '-c', '--charset CHARSET', String, 'Set max size'
        c.option '-o', '--output FILENAME', String, 'The output filename'
        c.option '-a', '--algorithm ALGORITHM', String, 'The hash algorithm'
        c.action do |args, options|
          options.default \
  				     :min => 1,
               :max => 8,
               :charset => [('a'..'z'), ('A'..'Z'), ('!'..'?')].map { |i| i.to_a }.flatten,
               :algorithm => 'md5',
               :output => 'rainbow.txt'

          generator = Blackgen::FullGenerator.new(options.charset, options.min, options.max)
          file = File.open(options.output, 'w')

          for i in generator.first..generator.last
            step = generator.step(i)
            file.puts "#{step}:#{Digest::MD5.hexdigest step}"
          end
          file.close
        end
      end

      command :test do |c|
        c.syntax = 'blackgen full'
        c.description = 'Generate incremental word list'
        c.action do |args, options|
          for i in 1..9999999
            print "#{i}\r"
          end
        end
      end

      run!
    end
  end

  BlackrainbowApplication.new.run if $0 == __FILE__
end
