GPIO_path = "/sys/class/gpio/"
BCM16 = 16
BCM17 = 17
BCM18 = 18
BCM19 = 19
BCM20 = 20
BCM26 = 26
BCM27 = 27

Light_left = BCM17
Light_center = BCM18
Light_right = BCM27

Motor_Left_Forward = BCM19
Motor_Left_Reverse = BCM26
Motor_Right_Forward = BCM16
Motor_Right_Reverse = BCM20

class LightTrackingCar
  def initialize
    open_gpios()

    @light_bcms = [Light_right, Light_center, Light_left]
    @motor_bcms = [Motor_Left_Forward, Motor_Left_Reverse, Motor_Right_Forward, Motor_Right_Reverse]
    set_GPIO_direction

    @index_Cds = [4,2,1]

  end

  def open_gpios()
    [BCM16,BCM17,BCM18,BCM19,BCM20,BCM26,BCM27].each do |gpio|
      open_gpio( gpio )
    end
  end

  def open_gpio( gpio_num )
    export_path = GPIO_path + "export"
    unexport_path = GPIO_path + "unexport"

    begin
      File.open( export_path, "w" ) do |fp|
        fp.write( gpio_num.to_s )
      end
      
    rescue Errno::EBUSY
      puts "EBUSY"
      File.open( unexport_path, "w" ) do |fp|
        fp.write( gpio_num.to_s )
      end
      retry
    
    rescue => e
      puts "Exception!!  #{e.message}"
    end
  end

  def set_GPIO_direction
    @light_bcms.each do |bcm|
      direction_path, value_path = set_path( bcm )

      File.open( direction_path, "w" ) do |fp|
        fp.write( "in" )
      end
    end

    @motor_bcms.each do |bcm|
      direction_path, value_path = set_path( bcm )

      File.open( direction_path, "w" ) do |fp|
        fp.write( "out" )
      end
    end
  end
 
  def status_Cds
    @light_bcms.inject(0) do |sum_light, light_bcm|
#      puts "sum : #{sum_light}, bcm : #{light_bcm}"
      if is_light_on?( light_bcm )
        value = 2 ** @light_bcms.index(light_bcm)
#        puts "***sum : #{sum_light}, bcm : #{light_bcm}, val : #{value}"
        sum_light + value
      else
        sum_light
      end
    end
  end

  def to_Cds_index( bcm )
    @index_Cds[@light_bcms.index(bcm)]
  end

  def set_path( bcm )
    base_path = GPIO_path + "gpio" + sprintf( "%d", bcm.to_s ) + "/"
    [base_path + "direction", base_path + "value"]
  end

  def is_light_on?( direction )
    direction_path, value_path = set_path( direction )
#    puts "dir : #{direction_path}, val : #{value_path}"

    result = 0
    File.open( value_path, "r" ) do |fp|
      result = fp.read.to_i
    end

#    puts "result #{result}"

    result == 1 ? true : false
  end

  def logic_table
    [ # bit assingment is as follows
      # left forward, left reverse, right forward, right reverse
      [0,0,0,0], # All lights are off
      [1,0,0,1], # immediately right
      [1,0,1,0], # forward
      [1,0,0,0], # simple left
      [0,1,1,0], # immediately left
      [0,0,0,0], # Stop
      [0,0,1,0], # simple right
      [0,0,0,0], # Stop
    ]
  end

  def main
    while 1
      puts "Logic Cds #{status_Cds} -> #{logic_table[status_Cds]}"
      logic_table[status_Cds].each_with_index do |bit, idx|
        motor_onoff(bit, idx)
      end
#      sleep(1)
    end
  end

  def motor_onoff( bit, idx )
    direction_path, value_path = set_path( @motor_bcms[idx] )

    File.open( value_path, "w" ) do |fp|
      fp.write( bit.to_s )
    end
  end
end

if $0 == __FILE__
  LightTrackingCar.new.main
end