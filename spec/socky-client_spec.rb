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
      Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test"})
      Socky.send("test")
    end
    context "should normalize options" do
      it "when nil given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => ""})
        Socky.send(nil)
      end
      it "when string given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test"})
        Socky.send("test")
      end
      it "when hash given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test"})
        Socky.send({:data => "test"})
      end
      it "when hash without body given" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => ""})
        Socky.send({})
      end
    end
    context "should handle recipient conditions for" do
      it ":client" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test", :clients => "first" })
        Socky.send("test", :client => "first")
      end
      it ":clients" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test", :clients => ["first","second"] })
        Socky.send("test", :clients => ["first","second"])
      end
      it ":channel" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test", :channels => "first" })
        Socky.send("test", :channel => "first")
      end
      it ":channels" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test", :channels => ["first","second"] })
        Socky.send("test", :channels => ["first","second"])
      end
      it "combination" do
        Socky.should_receive(:send_data).with({
          :command => :broadcast,
          :data => "test",
          :clients => "allowed_user",
          :channels => "allowed_channel"
        })
        Socky.send("test", :clients => "allowed_user", :channels => "allowed_channel")
      end
    end
    context "should ignore nil value for" do
      it ":clients" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test"})
        Socky.send("test", :clients => nil)
      end
      it ":channels" do
        Socky.should_receive(:send_data).with({:command => :broadcast, :data => "test"})
        Socky.send("test", :channels => nil)
      end
    end
    context "should handle empty array for" do
      it ":clients by not sending message" do
        Socky.should_not_receive(:send_data)
        Socky.send("test", :clients => [])
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
      Socky.should_receive(:send_data).with({:command => :query, :data => :show_connections}, true)
      Socky.show_connections
    end
  end

end