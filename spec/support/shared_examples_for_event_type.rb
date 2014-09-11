shared_examples 'any event type' do

  it 'has common attributes' do
    expect(type.time_prefix).to be_kind_of Regexp
    expect(type.time_format).to be_kind_of String
    expect(type.fields).to be_kind_of Regexp
  end

end
