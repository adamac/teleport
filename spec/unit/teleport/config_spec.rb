require "spec_helper"

describe Teleport::Config do
  context "with a blank Telfile" do
    telfile("")

    let(:config) do
      Teleport::Config.new
    end
    it "defaults to the current username" do
      config.user.should == `whoami`.strip      
    end
    it "defaults to the first vm in RUBIES" do
      config.ruby.should == Teleport::Config::RUBIES.first
    end
  end

  context "with a simple Telfile" do
    telfile do
      <<EOF
user "somebody"
ruby "1.8.7"

role :master, :packages => %w(nginx)
role :slave, :packages => %w(memcached)
server "one", :role => :master, :packages => %w(strace)
server "two", :role => :slave, :packages => %w(telnet)
packages %w(atop)
apt "blah blah blah", :key => "123"

before_install do
  puts "before_install running"
end

after_install do
  puts "after_install running"
end
EOF
      end
    
    let(:config) do
      Teleport::Config.new
    end
    it "has the master role" do
      config.role(:master).name.should == :master
      config.role(:master).packages.should == %w(nginx)
    end
    it "has server one" do
      config.server("one").name.should == "one"
      config.server("one").packages.should == %w(strace)
    end
    it "has default packages" do
      config.packages.should == %w(atop)
    end
    it "has callbacks" do
      config.callbacks[:before_install].should_not == nil
      config.callbacks[:after_install].should_not == nil      
    end
    it "has an apt line" do
      config.apt.first.line.should == "blah blah blah"
      config.apt.first.options[:key].should == "123"      
    end
  end
end
