require_relative './app_helper.rb'

class Spy
  attr_reader :target, :date_from, :date_to, :api_client

  def initialize(target: github_user, from: nil, to: nil, client: Octokit::Client)
    @target     = target
    @date_from  = from
    @date_to    = to
    @api_client = client.new(
      access_token: ENV['GITHUB_API_TOKEN'],
      per_page: 100
    )
  end

  def repos
    repos = api_client.repos({user: target}, query: {type: 'owner'})
    if filter_dates_given?
      filter_by_date(repos)
    else
      repos
    end
  end

  def filter_dates_given?
    !date_from.nil? && !date_to.nil?
  end

  def filter_by_date(repos)
    repos.select! do |repo|
      repo.created_at >= date_from && repo.created_at < date_to
    end
  end

  def ruby_repos
    repos.select { |repo| repo.language == 'Ruby' }
  end

  def ruby_repo_names_and_urls
    ruby_repos.map{ |repo| { name: repo.name, ssh_url: repo.ssh_url } }
  end

  def clone_ruby_repos
    Dir.mkdir("./#{target}")
    Dir.chdir("./#{target}")
    ruby_repo_names_and_urls.each { |repo| Git.clone(repo[:ssh_url], repo[:name]) }
    Dir.chdir('..')
  end

  def report
    clone_ruby_repos
    # warning about ruby syntax for the analyser
    scores = ruby_repo_names_and_urls.map do |hash|
      analysis = `rubycritic --no-browser -f console "./#{target}/#{hash[:name]}"`
      analysis[/Score: (\d*.\d*)/, 1].to_f
    end
    remove_repos
    { target => scores }
  end

  def remove_repos
    `rm -rf "./#{target}"`
  end
end
