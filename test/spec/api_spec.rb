require 'spec_helper'
require 'airborne'

TAKI_SHA256 = '6af68e72676d57cc508f77d59b5423be04e7fb03a4bb3f75b1bf32401c4bb8cc'
HOST = 'localhost:49999'

describe 'easy example' do
  before :all do
    put "#{HOST}/add/#{TAKI_SHA256}/taki/2"
    put "#{HOST}/add/#{TAKI_SHA256}/taki/3"
  end

  def get_json(rooting)
    JSON.parse(get("#{HOST}#{rooting}").body)
  end

  def get_image(rooting)
    get("#{HOST}#{rooting}").body
  end

  it 'respones to /symbols' do
    res = get_json('/symbols')
    expect(res.size).to eq 1
    expect(res[0]['symbol']).to eql 'taki'
    expect(res[0]['point']).to eq 5
  end

  it 'responses to /symbols/:sha256' do
    res = get_json("/symbols/#{TAKI_SHA256}")
    expect(res.size).to eq 1
    expect(res[0]['symbol']).to eql 'taki'
    expect(res[0]['point']).to eq 5
  end

  it 'responses to /sha256s/:symbol' do
    res = get_json('/sha256s/taki')
    expect(res.size).to eq 1
    expect(res[0]['sha256']).to eql TAKI_SHA256
    expect(res[0]['point']).to eq 5
  end

  it 'responses to /thumbnail/:sha256' do
    res = get_image("/thumbnail/#{TAKI_SHA256}")
    expected = File.read(
      "./.metaimg/thumbnails/#{TAKI_SHA256}.jpg", :encoding => Encoding::BINARY
    )
    expect(res).to eql expected
  end

  it 'responses to /raw/:sha256' do
    res = get_image("/raw/#{TAKI_SHA256}")
    expected = File.read(
      "./images/taki.jpg", :encoding => Encoding::BINARY
    )
    expect(res).to eql expected
  end

  it 'responses to /dirs/**' do
    res = get_json('/dirs/')
    expect(res.size).to eq 1
    expect(res[0]['name']).to eql 'subdir'
  end

  it 'responses to /imgs/**' do
    res = get_json('/imgs/')
    expect(res.size).to eq 1
    expect(res[0]['sha256']).to eql TAKI_SHA256
  end
end
