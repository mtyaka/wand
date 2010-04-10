require 'helper'

module WandTestHelpers
  def mime_types_gem_types
    {
      'AVGARDD.svg'    => 'image/svg+xml',
      'compressed.zip' => 'application/zip',
      'favicon.ico'    => 'image/vnd.microsoft.icon',
      'index.html'     => 'text/html',
      'jquery.js'      => 'application/javascript',
      'ol_tiny.jpg'    => 'image/jpeg',
      'ol_tiny.png'    => 'image/png',
      'styles.css'     => 'text/css'
    }
  end

  def unix_file_command_types
    {
      'example.m4r'    => 'audio/mp4',
      'AVGARDD.eot'    => 'application/octet-stream',
      'AVGARDD.ttf'    => 'application/octet-stream',
      'AVGARDD.woff'   => 'application/octet-stream'
    }
  end
end

class TestWand < Test::Unit::TestCase
  extend WandTestHelpers

  FILE_EXECUTABLE = Wand.executable

  context "Wand" do
    if !FILE_EXECUTABLE
      warn 'The "file" command was not found. Skipping tests that assume "file" command is present.'
    else
      context "when the file executable exists" do
        setup do
          Wand.executable = FILE_EXECUTABLE
        end

        should "detect executable" do
          assert_equal '/usr/bin/file', Wand.executable
        end

        mime_types_gem_types.each_pair do |name, type|
          should "use mime type gem if it returns type #{name}" do
            assert_equal type, Wand.wave(FilePath.join(name).expand_path.to_s)
          end
        end

        unix_file_command_types.each_pair do |name, type|
          should "fall back to unix file command when mime type returns nothing for #{name}" do
            assert_equal type, Wand.wave(FilePath.join(name).expand_path.to_s)
          end
        end

        should "return nil when mime type and file fail" do
          assert_nil Wand.wave('AVGARDD.eot')
        end

        should "allow setting the executable" do
          Wand.executable = '/usr/local/bin/file'
          assert_equal '/usr/local/bin/file', Wand.executable
        end

        should "strip newlines and such" do
          Wand.expects(:execute_file_cmd).returns("image/jpeg\n")
          assert_equal "image/jpeg", Wand.wave(FilePath.join(name).expand_path.to_s)
        end
      end
    end

    context "when the file executable doesn't exist" do
      setup do
        Wand.executable = nil
      end

      mime_types_gem_types.each_pair do |name, type|
        should "use mime type gem if it returns type #{name}" do
          assert_equal type, Wand.wave(FilePath.join(name).expand_path.to_s)
        end
      end

      unix_file_command_types.each_pair do |name, type|
        should "returns nil when mime type returns nothing for #{name}" do
          assert_nil Wand.wave(FilePath.join(name).expand_path.to_s)
        end
      end
    end
  end
end