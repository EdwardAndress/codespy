class Mission
  attr_reader :targets, :duration

  def self.create_from_csv(file: csv_file, spy_class: Spy, duration: nil)
    target_hashes = format_targets(file)
    self.new(targets: target_hashes, spy_class: spy_class, duration: duration)
  end

  def self.format_targets(file)
    csv = CSV.read(file).delete_if {|row| row == ["githubId", "timeToHire", "startDate"]}
    csv.map {|row| {id: row[0], start_date: row[2]}}
  end

  def initialize(targets: target_hashes, spy_class: Spy, duration: nil)
    @targets    = targets
    @spy_class  = spy_class
    @duration   = duration
  end

  def report
    data = targets.map do |target_hash|
      begin
      spy = @spy_class.new(target: target_hash, duration: duration)
      scores = spy.report.values.flatten
      [ target_hash[:id], mean(scores), median(scores), scores.length ]
      rescue => e
        p "Error: #{e} for #{target_hash[:id]} – continuing to next target"
      end
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
