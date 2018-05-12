require_relative './app_helper.rb'

class Spy
  attr_reader :target, :start_date, :duration, :api_client

  def initialize(target: target_hash, duration: nil, client: Octokit::Client)
    @target     = target[:id]
    @start_date = format_time(target[:start_date]) if target[:start_date]
    @duration   = duration
    @api_client = client.new(
      access_token: ENV['GITHUB_API_TOKEN'],
      per_page: 100
    )
  end

  def all_repos
    api_client.repos(user= target, query: {type: 'owner'})
  end

  def ruby_repos
    repos = date_filter_on? ? date_filtered_repos : all_repos
    repos.select { |repo| repo.language == 'Ruby' }
  end

  def clone_ruby_repos
    Dir.mkdir("./#{target}")
    Dir.chdir("./#{target}")
    ruby_repos.each { |repo| Git.clone(repo.ssh_url, repo.name) }
    Dir.chdir('..')
  end

  def report
    clone_ruby_repos
    # warning about ruby syntax for the analyser
    scores = ruby_repos.map do |repo|
      analysis = `rubycritic --no-browser -f console "./#{target}/#{repo.name}"`
      analysis[/Score: (\d*.\d*)/, 1].to_f
    end
    remove_repos
    { target => scores }
  end


  private

  def remove_repos
    `rm -rf "./#{target}"`
  end

  def format_time(date_string)
    Time.strptime(date_string, "%Y-%m-%d")
  end

  def date_filter_on?
    !start_date.nil? && !duration.nil?
  end

  def date_filtered_repos
    all_repos.select! do |repo|
      repo.created_at >= start_date && repo.created_at < start_date + duration.days
    end
  end
end
