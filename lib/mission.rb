class Mission
  attr_reader :targets

  def initialize(targets: users, spy: Spy, start: nil, duration: nil)
    @targets    = targets
    @spy        = spy
    @start_date = Time.strptime(start, "%Y-%m-%d")
    @duration   = duration
  end

  def report
    header = ['GitHub ID', 'Mean', 'Median', 'Repos']
    data = targets.map do |target|
      end_date = @start_date.nil? ? nil : @start_date + @duration.days
      spy = @spy.new(target: target, from: @start_date, to: end_date)
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
