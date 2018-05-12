require_relative '../lib/mission.rb'

RSpec.describe Mission do

  let(:spyclass) { double 'SpyClass', new: spy }
  let(:spy)      { double 'Spy', report: {"EdwardAndress" => [40.00, 70.00, 90.00, 100.00]} }
  subject do
    described_class.new(
      targets:[
        {id: 'EdwardAndress', start_date: '2015-01-31'},
        {id: 'AndressEdward', start_date: '2015-01-31'}
      ],
      duration: 60,
      spy_class: spyclass
    )
  end

  describe '#report' do
    it 'iterates through targets and creates a spy for each one' do
      expect(spyclass).to receive(:new).with(target: {id: 'EdwardAndress', start_date: '2015-01-31'}, duration: 60)
      expect(spyclass).to receive(:new).with(target: {id: 'AndressEdward', start_date: '2015-01-31'}, duration: 60)
      subject.report
    end

    it 'returns compiled report' do
      expect(subject.report).to eq [
        ['GitHub ID', 'Mean', 'Median', 'Repos' ],
        ["EdwardAndress", sprintf('%.2f', 75), sprintf('%.2f', 80), 4],
        ["AndressEdward", sprintf('%.2f', 75), sprintf('%.2f', 80), 4]
      ]
    end
  end

  describe '#mean' do
    it 'calculates the arithmentic mean' do
      expect(subject.mean([4,6,8])).to eq sprintf('%.2f', 6)
    end
  end

  describe '#median' do
    context 'with an odd number of values' do
      it 'caculates the arithmentic median' do
        expect(subject.median([1,2,3,4,5])).to eq sprintf('%.2f', 3)
      end
    end
    context 'with an even number of values' do
      it 'caculates the arithmentic median' do
        expect(subject.median([1,2,3,4,5,6])).to eq sprintf('%.2f', 3.5)
      end
    end
  end
end
