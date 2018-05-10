class Mission

  attr_reader :targets

  def initialize(targets: users, spy: Spy, from: date, to: date)
    @targets = targets
    @spy = spy
    @date_from  = from
    @date_to    = to
  end

  def report
    targets.map do |target|
      spy = @spy.new(target: target, from: @date_from, to: @date_to)
      spy.report
    end
  end
end
