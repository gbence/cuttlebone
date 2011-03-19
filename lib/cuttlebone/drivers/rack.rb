class Cuttlebone::Drivers::Rack < Cuttlebone::Drivers::Base
  def initialize env={}
    super(env['cuttlebone.stack_objects'])
  end
end
