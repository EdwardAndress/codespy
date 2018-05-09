require_relative '../lib/spy.rb'

RSpec.describe Spy do

  let(:rb_repo) do
    double 'Resource',
    id: 1,
    name: 'ruby',
    language: 'Ruby',
    ssh_url: 'git@github.com:EdwardAndress/rb_repo.git'
  end

  let(:js_repo) do
    double 'Resource',
    id: 2,
    name: 'js',
    language: 'Javascript',
    ssh_url: 'git@github.com:EdwardAndress/js_repo.git'
  end

  let(:mock_response) { [rb_repo, js_repo] }
  let(:ruby_repos)    { [rb_repo] }
  let(:client_class)  { double 'Octokit::ClientClass', new: api_client}
  let(:api_client)    { double 'Octokit::Client', repos: mock_response}

  subject do
    described_class.new(
      target: 'EdwardAndress',
      from: '2015-01-01',
      to: '2016-01-01',
      client: client_class
    )
  end

  describe '#target' do
    it 'returns the github ID of the chosen target' do
      expect(subject.target).to eq 'EdwardAndress'
    end
  end

  describe '#date_from' do
    it 'returns a Date object corresponding to the start of a period of interest' do
      expect(subject.date_from).to eq Date.strptime('2015-01-01', '%Y-%m-%d')
    end
  end

  describe '#date_to' do
    it 'returns a Date object corresponding to the end of a period of interest' do
      expect(subject.date_to).to eq Date.strptime('2016-01-01', '%Y-%m-%d')
    end
  end

  describe '#api_client' do
    it 'returns an instance of the client class' do
      expect(subject.api_client).to eq(api_client)
    end
  end

  describe '#repos' do
    it "delegates to the client, passing target and items per page args" do
      expect(subject.api_client).to receive(:repos)
        .with({user: 'EdwardAndress'}, query: { type: 'owner' })
      subject.repos
    end

    it "returns a list of the user's repos" do
      expect(subject.repos).to eq mock_response
    end
  end

  describe '#ruby repos' do
    it 'returns only ruby repos from the repos list' do
      expect(subject.ruby_repos).to eq ruby_repos
    end
  end

  describe '#ruby_repo_names_and_urls' do
    it 'returns the names and urls of repos to clone' do
      expect(subject.ruby_repo_names_and_urls)
        .to eq [{:name=>"ruby", :ssh_url=>"git@github.com:EdwardAndress/rb_repo.git"}]
    end
  end

  describe '#clone_ruby_repos' do
    it 'delegates to Git' do
      MemFs.activate do
        expect(Git).to receive(:clone).with(rb_repo.ssh_url, rb_repo.name)
        subject.clone_ruby_repos
      end
    end

    it 'creates a new directory using the target name' do
      MemFs.activate do
        allow(Git).to receive(:clone).with(rb_repo.ssh_url, rb_repo.name)
        subject.clone_ruby_repos
        expect(Dir.exists?('./EdwardAndress')).to eq true
      end
    end
  end

  describe '#analyse_ruby_repos' do
    it 'makes a system call to rubycritic fo each listed repo' do
      expect(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby\"")
        .and_return("Some dummy text which contains Score: 95.01")
      subject.analyse_ruby_repos
    end

    it 'returns the scores as an array' do
      allow(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby\"")
        .and_return("Some dummy text which contains Score: 95.01")
      expect(subject.analyse_ruby_repos).to eq([95.01])
    end
  end
end
