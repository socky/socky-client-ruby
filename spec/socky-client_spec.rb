require 'spec_helper'

describe Socky do
  it "should have config in hash form" do
    Socky.config.should_not be_nil
    Socky.config.class.should eql(Hash)
  end

  it "should have host list taken from config" do
    Socky.hosts.should eql(Socky.config[:hosts])
  end

  context "#send" do
    before(:each) do
      Socky.stub!(:send_data)
    end
    it "should send broadcast with data" do
      Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test"})
      Socky.send("test")
    end
    context "should normalize options" do
      it "when nil given" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => ""})
        Socky.send(nil)
      end
      it "when string given" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test"})
        Socky.send("test")
      end
      it "when hash given" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test"})
        Socky.send({:data => "test"})
      end
      it "when hash without body given" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => ""})
        Socky.send({})
      end
    end
    context "should handle recipient conditions for" do
      it ":channel" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test", :c => "first" })
        Socky.send("test", :channel => "first")
      end
      it ":channels" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test", :c => ["first","second"] })
        Socky.send("test", :channels => ["first","second"])
      end
      it ":user" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test", :u => "first" })
        Socky.send("test", :user => "first")
      end
      it ":users" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test", :u => ["first","second"] })
        Socky.send("test", :users => ["first","second"])
      end
      it "combination" do
        Socky.should_receive(:send_data).with({
          :cmd => 'b',
          :d   => "test",
          :c   => "allowed_channel",
          :u   => "allowed_user"
        })
        Socky.send("test", :channels => "allowed_channel", :users => "allowed_user")
      end
    end
    context "should ignore nil value for" do
      it ":channels" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test"})
        Socky.send("test", :channels => nil)
      end
      it ":users" do
        Socky.should_receive(:send_data).with({:cmd => 'b', :d => "test"})
        Socky.send("test", :users => nil)
      end
    end
    context "should handle empty array for" do
      it ":users by not sending message" do
        Socky.should_not_receive(:send_data)
        Socky.send("test", :users => [])
      end
      it ":channels by not sending message" do
        Socky.should_not_receive(:send_data)
        Socky.send("test", :channels => [])
      end
    end
  end

  context "#show_connections" do
    before(:each) do
      Socky.stub!(:send_data)
    end
    it "should send query :show_connections" do
      Socky.should_receive(:send_data).with({:cmd => 'q', :d => :show_connections}, true)
      Socky.show_connections
    end
  end

end