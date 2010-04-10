require 'mime/types'

module Wand
  Version = '0.2.1'
  
  def self.wave(path)
    type = MIME::Types.type_for(path)[0].to_s
    type = execute_file_cmd(path).split(';')[0].strip if (type.nil? || type == '') && executable
    type = nil if type =~ /cannot\sopen/ || type == ''
    type
  end

  def self.executable
    return @executable if defined?(@executable)
    @executable = system('which file') ? `which file`.chomp : nil
  end

  def self.executable=(path)
    @executable = path
  end

  def self.execute_file_cmd(path)
    `#{executable} --mime --brief #{path}`
  end
end