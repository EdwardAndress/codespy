class Mission
  attr_reader :targets

  def initialize(targets: users, spy: Spy, from: nil, to: nil)
    @targets = targets
    @spy = spy
    @date_from  = from
    @date_to    = to
  end

  def report
    header = ['GitHub ID', 'Mean', 'Median', 'Repos']
    data = targets.map do |target|
      spy = @spy.new(target: target, from: @date_from, to: @date_to)
      scores = spy.report.values.flatten

      [ target, mean(scores), median(scores), scores.length ]
    end

    data.prepend(header)
  end

  def mean(values)
    result = values.sum / values.length.to_f
    return sprintf('%.2f', result)
  end

  def median(values)
    if values.length % 2 == 1
      result = values.sort[values.length/2]
      return sprintf('%.2f', result)
    else
      lower = values.sort[values.length/2 - 1].to_f
      upper = values.sort[values.length/2].to_f
      result = mean([lower, upper])
      return sprintf('%.2f', result)
    end
  end
end
