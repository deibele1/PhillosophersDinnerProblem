require './store'
require './sharer'

$min_sleep = 1
$max_sleep = 2
$spegetii = true

$threads = []

forks = [
  :fork_1,
  :fork_2,
  :fork_3,
  :fork_4,
  :fork_5,
  :fork_6,
  :fork_7,
  :fork_8,
  :fork_9,
]

philosophers = [
  :descartes,
  :leibniz,
  :pascal,
  :hume,
  :aristotle,
  :spinoza,
  :plato,
  :kant,
  :camus
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
    @mutex = Mutex.new
    @retired = false
    start
  end

  def name
    @name
  end

  def eat
    Store.synchronize(*@forks) do
      @mutex.synchronize do
        change_state(:eating)
        puts("  #{@name} used #{@forks[0].use} and #{@forks[1].use} to eat")
        sleep(rand($min_sleep..$max_sleep))
        puts("    #{@name} has finished eating")
        change_state(nil)
      end
    end
  end

  def think
    @mutex.synchronize do
      change_state(:thinking)
      puts("#{@name} is thinking, tremble!")
      sleep(rand($min_sleep..$max_sleep))
      change_state(nil)
    end
  end

  def change_state(new_state)
    @state = new_state
  end

  def act
    [true, false].sample ? eat : think
  end

  def retire
    @retired = true
    @thread&.join
  end

  private def start
    @thread ||= Thread.new { act until @retired }
  end
end

fork_resources = forks.map { |fork| Store.create(fork) { Fork.new(fork) } }

fork_sharers = []
philosophers.each_with_index do |name, index|
  fork_sharers << Philosopher.new(name, fork_resources[index], fork_resources[(index + 1) % fork_resources.length])
end

sleep 10

fork_sharers.each(&:retire)