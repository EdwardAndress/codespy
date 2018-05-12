class Mission
  attr_reader :targets, :duration

  def initialize(targets: target_hashes, spy_class: Spy, duration: nil)
    @targets    = targets
    @spy_class  = spy_class
    @duration   = duration
  end

  def report
    p 'mission reporting'
    data = targets.map do |target_hash|
      spy = @spy_class.new(target: target_hash, duration: duration)
      scores = spy.report.values.flatten
      [ target_hash[:id], mean(scores), median(scores), scores.length ]
    end

    data.prepend(header)
  end

  def header
    ['GitHub ID', 'Mean', 'Median', 'Repos']
  end

  def mean(values)
    result = values.sum / values.length.to_f
    sprintf('%.2f', result)
  end

  def median(values)
    if values.length % 2 == 1
      result = values.sort[values.length/2]
      sprintf('%.2f', result)
    else
      lower = values.sort[values.length/2 - 1].to_f
      upper = values.sort[values.length/2].to_f
      result = mean([lower, upper])
      sprintf('%.2f', result)
    end
  end
end
