require_relative '../lib/mission.rb'

RSpec.describe Mission do

  let(:spyclass) { double 'Spy', new: spy }
  let(:spy)      { double 'spy', report: {"EdwardAndress" => [95.01, 100.00]} }
  subject do
    described_class.new(
      targets:['EdwardAndress', 'AndressEdward'],
      from: '2015-01-01',
      to: '2016-01-01',
      spy: spyclass
    )
  end

  describe '#targets' do
    it 'returns the list of targets' do
      expect(subject.targets).to eq ['EdwardAndress', 'AndressEdward']
    end
  end

  describe '#report' do
    it 'iterates through targets and creates a spy for each one' do
      expect(spyclass).to receive(:new).exactly(2).times
      subject.report
    end

    it 'returns compiled report' do
      expect(subject.report).to eq [["EdwardAndress", 95.01, 100.00],["EdwardAndress", 95.01, 100.00]]
    end
  end
end
