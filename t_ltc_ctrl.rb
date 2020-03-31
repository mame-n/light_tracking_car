require "test/unit"
require "./ltc_ctrl.rb"

class TC < Test::Unit::TestCase
  def setup
  end

  def test_set_path
    o = LightTrackingCar.new
    assert_equal( ["/sys/class/gpio/gpio23/direction", "/sys/class/gpio/gpio23/value"], o.set_path( 23 ))
    assert_equal( ["/sys/class/gpio/gpio4/direction", "/sys/class/gpio/gpio4/value"], o.set_path( 4 ))
  end

  def test_is_light_on
    o = LightTrackingCar.new
    assert_equal( nil, o.is_light_on?( 18 ))
  end

  def test_open_gpios
    o = LightTrackingCar.new
    assert_equal( false, o.open_gpios )
  end

  def test_to_Cds_index
    o = LightTrackingCar.new
    assert_equal( 2, o.to_Cds_index( 17 ))
    assert_equal( 4, o.to_Cds_index( 18 ))
    assert_equal( 1, o.to_Cds_index( 27 ))
  end

  def test_status_Cds
    o = LightTrackingCar.new
    assert_equal( 0, o.status_Cds )
  end

  def test_motor_onoff
    o = LightTrackingCar.new
    assert_equal( nil, o.motor_onoff(0, 3) )
  end

  def test_main
    o = LightTrackingCar.new
    assert_equal( nil, o.main )
  end
end
