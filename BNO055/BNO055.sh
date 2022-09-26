#!/bin/bash

# code written by Ahmad Byagowi for demonstration purposes of the BNO055 chip over the i2c bus

BNO055_I2CBUS=4
BNO055_DEVADDR=0x28
BNO055_OPR_MODE=0x3D

BNO055_LIA_DATA_X=0x28
BNO055_GRV_DATA_X=0x2E
BNO055_QUA_DATA_W=0x20
BNO055_EUL_DATA_H=0x1A
BNO055_GYR_DATA_X=0x14
BNO055_MAG_DATA_X=0x0E
BNO055_ACC_DATA_X=0x08
BNO055_TEMPERATURE=0x34

#initialize BNO055 to perform FAST NDOF
i2cset -y $BNO055_I2CBUS $BNO055_DEVADDR $BNO055_OPR_MODE 0x1C

read1(){
TMP1=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+0)) w)))
}

read3(){
TMP1=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+0)) w)))
TMP2=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+2)) w)))
TMP3=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+4)) w)))
}

readsigned3(){
TMP1=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+0)) w)))
if [ "$TMP1" -gt "32767" ]; then
TMP1=$(("$TMP1-65536"))
fi
TMP2=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+2)) w)))
if [ "$TMP2" -gt "32767" ]; then
TMP2=$(("$TMP2-65536"))
fi
TMP3=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $(($1+4)) w)))
if [ "$TMP3" -gt "32767" ]; then
TMP3=$(("$TMP3-65536"))
fi
}

euler(){
readsigned3 BNO055_EUL_DATA_H
printf "Euler Angles in degrees\n"
printf "Head = %.3f degrees\n" $(echo $TMP1 / 16 | bc -l)
printf "Roll = %.3f degrees\n" $(echo $TMP2 / 16 | bc -l)
printf "Pitch = %.3f degrees\n" $(echo $TMP3 / 16 | bc -l)
}

quaternion(){
TMP1=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR 0x20 w)))
TMP2=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR 0x22 w)))
TMP3=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR 0x24 w)))
TMP4=$(($(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR 0x26 w)))
printf "Quaternions\n"
printf "W = %.10f\n" $(echo $TMP1 / 16384 | bc -l)
printf "X = %.10f\n" $(echo $TMP2 / 16384 | bc -l)
printf "Y = %.10f\n" $(echo $TMP3 / 16384 | bc -l)
printf "Z = %.10f\n" $(echo $TMP4 / 16384 | bc -l)
}

linear(){
readsigned3 BNO055_LIA_DATA_X
printf "Linear Acceleration in m/s^2\n"
printf "X = %.3f m/s^2\n" $(echo $TMP1 / 100 | bc -l)
printf "Y = %.3f m/s^2\n" $(echo $TMP2 / 100 | bc -l)
printf "Z = %.3f m/s^2\n" $(echo $TMP3 / 100 | bc -l)
}

gravity(){
readsigned3 BNO055_GRV_DATA_X
printf "Gravity Vector in m/s^2\n"
printf "X = %.3f m/s^2\n" $(echo $TMP1 / 100 | bc -l)
printf "Y = %.3f m/s^2\n" $(echo $TMP2 / 100 | bc -l)
printf "Z = %.3f m/s^2\n" $(echo $TMP3 / 100 | bc -l)
}

BNO055_TEMPERATURE(){
TMP1=$(i2cget -y $BNO055_I2CBUS $BNO055_DEVADDR $BNO055_TEMPERATURE)
printf "BNO055_TEMPERATURE in C\n"
printf "X = %d C\n" $(echo $TMP1)
}

accelerometer(){
readsigned3 BNO055_ACC_DATA_X
printf "Acceleration in m/s^2\n"
printf "X = %.3f m/s^2\n" $(echo $TMP1 /100 | bc -l)
printf "Y = %.3f m/s^2\n" $(echo $TMP2 /100 | bc -l)
printf "Z = %.3f m/s^2\n" $(echo $TMP3 /100 | bc -l)
}

magnetometer(){
readsigned3 BNO055_MAG_DATA_X
printf "Magnetometer in uT\n"
printf "X = %.3f uT\n" $(echo $TMP1 / 16 | bc -l)
printf "Y = %.3f uT\n" $(echo $TMP2 / 16 | bc -l)
printf "Z = %.3f uT\n" $(echo $TMP3 / 16 | bc -l)
}

gyroscope(){
readsigned3 BNO055_GYR_DATA_X
printf "Gyroscpe in D/s\n"
printf "X = %.3f D/s\n" $(echo $TMP1 / 16 | bc -l)
printf "Y = %.3f D/s\n" $(echo $TMP2 / 16 | bc -l)
printf "Z = %.3f D/s\n" $(echo $TMP3 / 16 | bc -l)
}

sensors(){
BNO055_TEMPERATURE
echo ""
accelerometer
echo ""
gyroscope
echo ""
magnetometer
}

all(){
euler
echo ""
linear 
echo ""
gravity
echo ""
quaternion
echo ""
sensors
}


all
