

require_relative '../lib/weather_station'


RSpec.describe 'allow/receive and argument matching (WeatherStation examples)' do
  # 1. Basic stubbing
  it 'allows a method to be stubbed on a double' do
    station = double('WeatherStation')
    allow(station).to receive(:temperature).and_return(68.5)
    expect(station.temperature).to eq(68.5)
  end

  # 2. Stubbing with arguments
  it 'returns a value for specific arguments' do
    station = double('WeatherStation')
    allow(station).to receive(:humidity).and_return(nil)
    allow(station).to receive(:humidity).with('NYC').and_return(55)
    expect(station.humidity('NYC')).to eq(55)
    expect(station.humidity('LA')).to be_nil # not stubbed
  end

  # 3. Stubbing multiple argument sets
  it 'returns different values for different arguments' do
    station = double('WeatherStation')
    allow(station).to receive(:forecast).and_return(nil)
    allow(station).to receive(:forecast).with(:today).and_return('Sunny')
    allow(station).to receive(:forecast).with(:tomorrow).and_return('Rainy')
    expect(station.forecast(:today)).to eq('Sunny')
    expect(station.forecast(:tomorrow)).to eq('Rainy')
    expect(station.forecast(:friday)).to be_nil
  end

  # 4. Stubbing a sequence of return values
  it 'returns a sequence of values' do
    sensor = double('Sensor')
    allow(sensor).to receive(:read).and_return(10, 20, 30)
    expect(sensor.read).to eq(10)
    expect(sensor.read).to eq(20)
    expect(sensor.read).to eq(30)
    expect(sensor.read).to eq(30) # repeats last value
  end

  # 5. Argument matchers: any_args
  it 'matches any arguments' do
    logger = double('Logger')
    allow(logger).to receive(:log_event).with(any_args)
    logger.log_event('rain', { amount: 2 })
    logger.log_event('wind')
    expect(logger).to have_received(:log_event).twice
  end

  # 6. Argument matchers: anything
  it 'matches any value for a specific argument' do
    station = double('WeatherStation')
    allow(station).to receive(:report).and_return(nil)
    allow(station).to receive(:report).with(anything, 'high').and_return('Alert!')
    expect(station.report('temp', 'high')).to eq('Alert!')
    expect(station.report('humidity', 'high')).to eq('Alert!')
    expect(station.report('temp', 'low')).to be_nil
  end

  # 7. Argument matchers: hash_including
  it 'matches a hash including certain keys' do
    station = double('WeatherStation')
    allow(station).to receive(:log_event).and_return(nil)
    allow(station).to receive(:log_event).with(hash_including(:event)).and_return('Logged!')
    expect(station.log_event({ event: 'storm', severity: 'high' })).to eq('Logged!')
    expect(station.log_event({ severity: 'high' })).to be_nil
  end

  # 8. Argument matchers: array_including
  it 'matches an array including certain elements' do
    sensor = double('Sensor')
    allow(sensor).to receive(:calibrate).and_return(nil)
    allow(sensor).to receive(:calibrate).with(array_including('temp', 'humidity')).and_return('Calibrated')
    expect(sensor.calibrate(['temp', 'humidity', 'pressure'])).to eq('Calibrated')
    expect(sensor.calibrate(['pressure'])).to be_nil
  end

  # 9. Verifying method calls
  it 'verifies a method was called with specific arguments' do
    logger = double('Logger').as_null_object
    allow(logger).to receive(:log_event)
    logger.log_event('rain', { amount: 2 })
    expect(logger).to have_received(:log_event).with('rain', { amount: 2 })
  end

  # 10. Stubbing real objects
  it 'stubs a method on a real object' do
    station = WeatherStation.new
    allow(station).to receive(:temperature).and_return(99.9)
    expect(station.temperature('NYC')).to eq(99.9)
    # Students: try removing the stub and see what happens!
  end

  # 11. Combining argument matchers
  it 'combines argument matchers for flexible stubbing' do
    station = double('WeatherStation')
    allow(station).to receive(:report).and_return(nil)
    allow(station).to receive(:report).with(anything, hash_including(:level)).and_return('Matched')
    expect(station.report('wind', { level: 'high', speed: 20 })).to eq('Matched')
    expect(station.report('wind', { speed: 20 })).to be_nil
  end

  # 12. Practice prompt for students
  it 'lets students try their own stubs and matchers' do
    station = double('WeatherStation')
    allow(station).to receive(:temperature).and_return(nil)
    allow(station).to receive(:temperature).with(anything, 'high').and_return(78.0)
    expect(station.temperature('foo', 'high')).to eq(78.0)
    expect(station.temperature('foo')).to be_nil
  end

  # 13. Edge case: unstubbed method returns nil
  it 'returns the double itself for unstubbed methods on as_null_object doubles' do
    d = double('WeatherStation').as_null_object
    expect(d.unknown_method).to be d
  end

  # 14. Edge case: stubbing with multiple matchers
  it 'uses the most specific stub' do
    station = double('WeatherStation').as_null_object
    allow(station).to receive(:forecast).with(anything).and_return('B')
    allow(station).to receive(:forecast).with(:today).and_return('A')
    expect(station.forecast(:today)).to eq('A') # most specific
    expect(station.forecast(:friday)).to eq('B')
  end

  # 15. Students: Try stubbing WeatherStation#humidity or #forecast
  it 'lets students try stubbing humidity or forecast' do
    station = WeatherStation.new
    allow(station).to receive(:humidity).with(anything).and_return(70)
    allow(station).to receive(:forecast).with(:tomorrow).and_return('Sunny')
    expect(station.humidity(:nyc)).to eq(70)
    expect(station.forecast(:tomorrow)).to eq('Sunny')
  end
end
