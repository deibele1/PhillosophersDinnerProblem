# Thread wrapper to ensure resource synchronization. All exclusive resources must be registered at creation

require './resource_warden'

class Guard < Thread
  def initialize(*resources, &block)
    super() do
      ResourceWarden.synchronize(*resources, &block)
    end
  end
end