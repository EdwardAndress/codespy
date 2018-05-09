require_relative './app_helper.rb'

class Spy

  attr_reader :target, :date_from, :date_to, :api_client

  def initialize(target: github_user, from: date, to: date, client: Octokit::Client)
    @target     = target
    @date_from  = Date.strptime(from, '%Y-%m-%d')
    @date_to    = Date.strptime(to, '%Y-%m-%d')
    @api_client = client.new(
      access_token: ENV['GITHUB_API_TOKEN'],
      per_page: 100
    )
  end

  def repos
    api_client.repos({user: target}, query: {type: 'owner'})
  end

  def ruby_repos
    repos.select { |repo| repo.language == 'Ruby' }
  end

  def ruby_repo_urls
    ruby_repos.map(&:ssh_url)
  end
end
