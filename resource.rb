require 'benchmark'
class Resource
  class AcquireException < Exception; end
  # safe_methods = [:send, :__send__, :public_send, :object_id]
  # safe_methods = []
  # (instance_methods - safe_methods).each do |method|
  #   eval("undef #{method}")
  # end

  def initialize(resource)
    @mutex = Mutex.new
    @registration = Mutex.new
    @heir = nil
    @resource = resource
    @registry = []
  end

  # changes the heir to the caller and builds a connector proc to wait on the current thread
  def resource_key
    heir = nil
    @registration.synchronize do
      heir = @heir
      @heir = Thread.current
    end
    Proc.new do
      heir&.join
      chown(Thread.current)
    end
  end

  private def owner
    @owner
  end

  private def chown(thread)
    @mutex.synchronize do
      @owner = thread
    end
  end

  private def method_missing(symbol, *args)
    return @resource.send(symbol, *args) if Thread.current == owner
    throw AcquireException.new("A thread must first acquire the resource before using it.")
  end
end
