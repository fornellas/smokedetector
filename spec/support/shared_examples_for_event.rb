shared_examples 'any event' do
  it 'has common attributes' do
    expect(event.raw).to be_kind_of String
    expect(event.type).to be_kind_of Event::Type
  end

  context '#time' do
    xit 'should extract time from raw event' do

    end
  end

  context '#field_names' do
    xit 'should return all field names' do

    end
  end

  context '#[]' do
    xit 'should extract fields' do

    end
  end
end
