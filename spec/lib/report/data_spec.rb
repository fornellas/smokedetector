require 'report/data'

RSpec.describe Report::Data do
  context '#==' do

    let(:a) do
      Report::Data.new(
        matrix: [
          ['url', '200', '400','500'],
          ['/a',  3, 1, 3],
          ['/b',  2, 2, 3],
          ['/c',  2, 0, 2],
          ],
        type: :field,
        size: nil,
        )
    end

    it 'asserts equalty' do
      b = Report::Data.new(
        matrix: [
          ['url', '200', '400','500'],
          ['/a',  3, 1, 3],
          ['/b',  2, 2, 3],
          ['/c',  2, 0, 2],
          ],
        type: :field,
        size: nil,
        )
      expect(a).to eq(b)
    end

  end
end