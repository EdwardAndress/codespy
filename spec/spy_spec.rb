require_relative '../lib/spy.rb'

RSpec.describe Spy do

  let(:rb_repo) do
    double 'Resource(Ruby)',
    id: 1,
    name: 'ruby',
    language: 'Ruby',
    ssh_url: 'git@github.com:EdwardAndress/rb_repo.git',
    created_at: Time.new(2015, 01, 01)
  end

  let(:js_repo) do
    double 'Resource(JS1)',
    id: 2,
    name: 'js',
    language: 'Javascript',
    ssh_url: 'git@github.com:EdwardAndress/js_repo.git',
    created_at: Time.new(2015, 02, 01)
  end

  let(:rb_repo2) do
    double 'Resource(Ruby2)',
    id: 3,
    name: 'ruby2',
    language: 'Ruby',
    ssh_url: 'git@github.com:EdwardAndress/rb_repo2.git',
    created_at: Time.new(2015, 03, 20)
  end

  let(:all_repos)                { [rb_repo, js_repo, rb_repo2] }
  let(:date_filtered_ruby_repos) { [rb_repo]  }
  let(:all_ruby_repos)           { [rb_repo, rb_repo2] }
  let(:client_class)             { double 'Octokit::ClientClass', new: api_client}
  let(:api_client)               { double 'Octokit::Client', repos: all_repos}

  subject do
    described_class.new(
      target: {id: 'EdwardAndress', start_date: nil },
      client: client_class
    )
  end

  before(:each) do
    allow(Git).to receive(:clone).with(rb_repo.ssh_url, rb_repo.name)
    allow(Git).to receive(:clone).with(rb_repo2.ssh_url, rb_repo2.name)
  end

  describe '#all_repos' do
    it "delegates to the client, passing target and items per page args" do
      expect(subject.api_client).to receive(:repos)
        .with(user = 'EdwardAndress', query: { type: 'owner' })
      subject.all_repos
    end

    it "returns a list of all the user's repos" do
      expect(subject.all_repos).to eq all_repos
    end
  end

  describe '#ruby_repos' do
    context 'without date filtering' do
      it 'returns only ruby repos from the repos list' do
        expect(subject.ruby_repos).to eq all_ruby_repos
      end
    end

    context 'with filter dates' do
      subject do
        Spy.new(
          target: {id: "EdwardAndress", start_date: '2015-01-01'},
          duration: 60,
          client: client_class
        )
      end

      it 'returns repos created between the filter dates' do
        expect(subject.ruby_repos).to eq date_filtered_ruby_repos
      end
    end
  end

  describe '#clone_ruby_repos' do
    it 'delegates to Git' do
      MemFs.activate do
        expect(Git).to receive(:clone).with(rb_repo.ssh_url, rb_repo.name)
        expect(Git).to receive(:clone).with(rb_repo2.ssh_url, rb_repo2.name)
        subject.clone_ruby_repos
      end
    end

    it 'creates a new directory using the target name' do
      MemFs.activate do
        subject.clone_ruby_repos
        expect(Dir.exists?('./EdwardAndress')).to eq true
      end
    end
  end

  describe '#report' do

    before(:each) do
      allow(subject).to receive(:`).with("rm -rf \"./EdwardAndress\"")
    end

    it 'makes a system call to rubycritic for each listed repo' do
      expect(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby\"")
        .and_return("Some dummy text which contains Score: 95.01")
      expect(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby2\"")
        .and_return("Some dummy text which contains Score: 95.01")
      MemFs.activate do
        subject.report
      end
    end


    before do
      allow(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby\"")
        .and_return("Some dummy text which contains Score: 95.01")
      allow(subject).to receive(:`).with("rubycritic --no-browser -f console \"./EdwardAndress/ruby2\"")
        .and_return("Some dummy text which contains Score: 85.01")
    end

    it 'returns the scores as an array' do
      MemFs.activate do
        expect(subject.report).to eq({"EdwardAndress" => [95.01, 85.01]})
      end
    end
  end
end
