# echo 23 > /sys/class/gpio/export
# echo 23 > /sys/class/gpio/unexport

gpio_path = "/sys/class/gpio/"
export_path = gpio_path + "export"
unexport_path = gpio_path + "unexport"

begin
  File.open( export_path, "w" ) do |fp|
    fp.write("23")
  end
  
rescue Errno::EBUSY
  puts "EBUSY"
  File.open( unexport_path, "w" ) do |fp|
    fp.write( "23" )
  end
  retry

rescue => e
  puts "Exception!!  #{e.message}"
end

direction_path = gpio_path + "gpio23/direction"
value_path = gpio_path + "gpio23/value"

File.open( direction_path, "w" ) do |fp|
  fp.write( "out" )
end

File.open( value_path, "w" ) do |fp|
  fp.write( "1" )
end

File.open( unexport_path, "w" ) do |fp|
  fp.write( "23" )
end

