require File.expand_path("../../spec_helper", __FILE__)

module VncTools
  describe Server do
    context "managing new displays" do
      let(:server) { Server.new }
      before { server.stub :last_status => double(:success? => true) }

      it "starts a new server" do
        server.should_receive(:`).with("tightvncserver 2>&1").and_return("desktop is #{Socket.gethostname}:1")
        server.start
        server.display.should == ":1"
      end

      it "stops the server" do
        server.should_receive(:`).with("tightvncserver -kill :5 2>&1")
        server.stub :display => ":5"
        server.stop
      end

      it "forcefully stops the server" do
        server.should_receive(:`).with("tightvncserver -kill :5 2>&1")
        server.stub :last_status => double(:success? => false)
        server.stub :display => ":5"

        mock_pathname = double('Pathname:5.pid', :exist? => true)
        Pathname.should_receive(:new).with("#{ENV['HOME']}/.vnc/#{Socket.gethostname}:5.pid").and_return(mock_pathname)
        mock_pathname.should_receive(:read).and_return 123123
        mock_pathname.should_receive(:delete)
        Process.should_receive(:kill).with(9, 123123)

        server.stop(true)
      end

      it "raises Server::Error if the server could not be started" do
        server.should_receive(:`).and_return("oops")
        server.stub :last_status => double(:success? => false)

        lambda { server.start }.should raise_error(Server::Error, /oops/)
      end

      it "raises Server::Error if the display number could not be parsed" do
        server.should_receive(:`).and_return("oops")

        lambda { server.start }.should raise_error(Server::Error, /could not find display/)
      end

      it "can be overriden to provide custom launch arguments" do
        server_class = Class.new(Server) {
          def launch_arguments() %w[-geometry 1280x1024] end
        }

        server = server_class.new
        server.stub :last_status => double(:success? => true)

        server.should_receive(:`).with("tightvncserver -geometry 1280x1024 2>&1").and_return("desktop is #{Socket.gethostname}:1")
        server.start
      end
    end

    context "controlling an existing display" do
      let(:server) { Server.new ":5" }
      before { server.stub :last_status => double(:success? => true) }

      it "starts the server on the given display" do
        server.should_receive(:`).with("tightvncserver :5 2>&1").and_return("desktop is #{Socket.gethostname}:5")
        server.start
        server.display.should == ":5"
      end
    end

    it "returns an instance for all existing displays" do
      Dir.stub(:[]).and_return [".vnc/qa1:1.pid", ".vnc/qa1:2.pid", ".vnc/qa1:3.pid"]

      all = Server.all
      all.size.should == 3
      all.map { |e| e.display }.should == [":1", ":2", ":3"]
    end

  end # Server
end # VncTools
