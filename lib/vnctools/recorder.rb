module VncTools
  class Recorder

    attr_reader :display, :output

    def initialize(display, output, opts = {})
      @display = display
      @output  = output
      @options = opts
    end

    def start
      @process = ChildProcess.build(
        "ffmpeg",
        "-an",                                      # no audio,
        "-f", "x11grab",                            # force format
        "-y",                                       # overwrite output files
        "-r", @options[:frame_rate] || "5",         # frame rate
        "-s", @options[:frame_size] || "1024x768",  # frame size
        "-i", "#{display}.0+0,0",                   # display :1
        "-vcodec", @options[:codec] || "mpeg4",     # video codec
        "-sameq", output                            # output
      )

      if $DEBUG
        @process.io.inherit!
      else
        @process.io.stdout = @process.io.stderr = File.open("/dev/null", "w")
      end

      @process.start

      # TODO: this may be too quick to actually catch the failure
      if @process.crashed?
        raise Error, "ffmpeg failed, run with $DEBUG = true for full output"
      end
    end

    def stop
      @process && @process.stop
    end
  end
end
