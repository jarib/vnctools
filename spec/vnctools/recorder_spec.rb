require File.expand_path("../../spec_helper", __FILE__)

module VncTools
  describe Recorder do
    context "given a display string" do
      let(:process)  { double(ChildProcess, :crashed? => false, :start => nil, :stop => nil, :io => double("io").as_null_object) }
      let(:recorder) { Recorder.new ":1", "out.mp4"  }

      it "knows its display" do
        recorder.display.should == ":1"
      end

      it "knows its output" do
        recorder.output.should == "out.mp4"
      end

      it "starts and stops recording on the given display" do
        ChildProcess.should_receive(:build).with(
          "ffmpeg",
          "-an",               # no audio,
          "-f", "x11grab",     # force format
          "-y",                # overwrite output files
          "-r", "5",           # frame rate
          "-s", "1024x768",    # size
          "-i", ":1.0+0,0",    # display :1
          "-vcodec", "mpeg4",  # default encoding
          "-sameq", "out.mp4"  # output
        ).and_return process

        process.should_receive(:start)
        recorder.start

        process.should_receive(:stop)
        recorder.stop
      end

      it "raises an error if the process crashed" do
        ChildProcess.stub :build => double(:start => nil, :crashed? => true)

        lambda { recorder.start }.should raise_error
      end
    end
  end # Recorder
end # VncTools
