# Exclusive resource class that allows requests for multiple resources and guarantees a lock on all resources will be granted
# as soon as all prior threads terminate.
# A mutex ensure that the current thread will be registered for a list of resources
# Given every thread eventually completes
# Since only one thread at a time can register for resources
# And the first thread will be immediately granted all resources it requests
# The first thread will complete and all dependent threads will wake.
# A threads will run in order of registration as long as soon as the last prior thread on any required resource is finished.
# Auto joining in this way ensures no resource starvation, no deadlocks, no live-locks and true concurrency.
# For the sake of simplicity threads are assumed to need exclusive access to a resource till they finish
# Threads should be kept small that are using this model
# Only one lock is granted at any given time.
# This model can solve a generalized dining philosophers problem with any resource exclusion structure.

require('./resource')

class Store
  @store = Hash.new
  @mutex = Mutex.new
  @registration = Mutex.new

  def self.synchronize(*resources, &block)
    keys = nil
    @registration.synchronize { keys = resources.map(&:joiner) }
    keys.each(&:call)
    block.call
  end

  def self.[](name)
    @store[name]
  end

  def self.create(name)
    @mutex.synchronize { @store[name] = Resource.new(yield) }
  end
end
