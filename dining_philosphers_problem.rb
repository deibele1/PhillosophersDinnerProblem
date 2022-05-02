require './store'
require './sharer'

$sleep_time = 3

$threads = []

forks = [
  :fork_1,
  :fork_2,
  :fork_3,
  :fork_4,
  :fork_5,
  # :fork_6,
  # :fork_7,
  # :fork_8,
  # :fork_9,
]

philosophers = [
  :descartes,
  :leibniz,
  :pascal,
  :hume,
  :aristotle,
  # :spinoza,
  # :plato,
  # :kant,
  # :camus
]

class Fork
  def initialize(name)
    @name = name
  end

  def use
    @name
  end
end

class Philosopher
  def initialize(name, *forks)
    @name = name
    @forks = forks
  end

  def name
    @name
  end

  def eat
    sharer = Sharer.new(*@forks) do
      puts("#{@name} used #{@forks[0].use} and #{@forks[1].use} to eat")
      sleep($sleep_time)
      puts("  #{@name} has finished eating")
    end
    sharer.name = ("#{@name} eating")
    sharer
  end
end

fork_resources = forks.map { |fork| Store.create(fork) { Fork.new(fork) } }

fork_sharers = []
philosophers.each_with_index do |name, index|
  fork_sharers << Philosopher.new(name, fork_resources[index], fork_resources[(index + 1) % fork_resources.length])
end


10.times do
  eater = fork_sharers.sample
  $threads << eater.eat
end
$threads.each(&:join)