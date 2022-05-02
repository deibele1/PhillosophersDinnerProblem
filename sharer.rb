# Thread wrapper to ensure resource synchronization. All exclusive resources must be registered at creation

require './store'

class Sharer < Thread
  def initialize(*resources, &block)
    super() do
      Store.synchronize(*resources, &block)
    end
  end
end