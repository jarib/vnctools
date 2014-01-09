require File.expand_path("../../spec_helper", __FILE__)

module VncTools
  describe ServerPool do
    let(:server) { double(Server, :start => nil, :stop => nil, :dead? => false) }
    let(:fake_server_class) { double(:new => server)}
    let(:pool)  { ServerPool.new(3, fake_server_class) }

    it "creates 3 instances of the given display class" do
      fake_server_class.should_receive(:new).exactly(3).times

      pool = ServerPool.new(3, fake_server_class)
      pool.size.should == 3
    end

    it "can fetch a server from the pool" do
      pool.get.should == server
      pool.size.should == 2
    end

    it "can release a server" do
      obj = pool.get
      pool.size.should == 2

      pool.release obj
    end

    it 'replaces a dead server from the pool' do
      server.stub(:dead? => true)
      fake_server_class.should_receive(:new).exactly(3).times
      pool # create pool to trigger the above

      replacement_server = double(Server, :dead? => false)
      fake_server_class.should_receive(:new).once.and_return(replacement_server)
      replacement_server.should_receive(:start)

      pool.get.should == replacement_server
    end

    it "can stop the pool" do
      pool.stub(:running => [server])
      server.should_receive(:stop)

      pool.stop
    end

    it "raises a TooManyDisplaysError if the pool is over capacity" do
      lambda { pool.release "foo" }.should raise_error(ServerPool::TooManyDisplaysError)
    end

    it "raises a OutOfDisplaysError if the pool is empty" do
      3.times { pool.get }
      lambda { pool.get }.should raise_error(ServerPool::OutOfDisplaysError)
    end

    it "notifies observers" do
      observer = double(Observable)

      observer.should_receive(:update).with :on_display_starting, server
      observer.should_receive(:update).with :on_display_fetched , server
      observer.should_receive(:update).with :on_display_released, server
      observer.should_receive(:update).with :on_display_stopping , server

      pool.add_observer observer

      pool.release pool.get
      pool.stop
    end

  end # ServerPool
end # VncTools
