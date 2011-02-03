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
        "-sameq", output            # output
      )

      @process.io.inherit! if $DEBUG
      @process.start

      if @process.crashed?
        raise Error, "ffmpeg failed, run with $DEBUG = true for full output"
      end
    end

    def stop
      @process && @process.stop
    end
  end
end
