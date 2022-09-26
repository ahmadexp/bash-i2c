#!/bin/bash

# code written by Ahmad Byagowi for demonstration purposes of the BMP280 chip over the i2c bus

BMP280_I2CBUS=3
BMP280_DEVADDR=0x77

BMP280_TEMP_XLSB=0xFC
BMP280_TEMP_LSB=0xFB
BMP280_TEMP_MSB=0xFA
BMP280_PRESS_XLSB=0xF9
BMP280_PRESS_LSB=0xF8
BMP280_PRESS_MSB=0xF7
BMP280_CONFIG=0xF5
BMP280_CTRL_MEAS=0xF4

BMP280_DIG_T1_ADDR=0x88
BMP280_DIG_T2_ADDR=0x8A
BMP280_DIG_T3_ADDR=0x8C

BMP280_DIG_P1_ADDR=0x8E
BMP280_DIG_P2_ADDR=0x90
BMP280_DIG_P3_ADDR=0x92
BMP280_DIG_P4_ADDR=0x94
BMP280_DIG_P5_ADDR=0x96
BMP280_DIG_P6_ADDR=0x98
BMP280_DIG_P7_ADDR=0x9A
BMP280_DIG_P8_ADDR=0x9C
BMP280_DIG_P9_ADDR=0x9E

#initialize BMP280 to perform normal
i2cset -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_CONFIG 0xFF
i2cset -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_CTRL_MEAS 0xFF

readWord(){
echo $(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $(($1+0)) w)))
}

function temperature(){
	local adc_T_msb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_MSB)))
	local adc_T_lsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_LSB)))
	local adc_T_xlsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_XLSB)))
	local dig_T1=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T1_ADDR w)))
	local dig_T2=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T2_ADDR w)))
	if [ "$dig_T2" -gt "32767" ]; then
                dig_T2=$(("$dig_T2-65536"))
        fi
	local dig_T3=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T3_ADDR w)))
	if [ "$dig_T3" -gt "32767" ]; then
                dig_T3=$(("$dig_T3-65536"))
        fi
	local adc_T=$(($(($(($(($adc_T_msb<<16))|$(($adc_T_lsb<<8))))|$adc_T_xlsb))>>4))
	local var1=$(($(($(($(($(($adc_T>>3))-$(($dig_T1<<1))))*$dig_T2))))>>11))
        local var2=$(($(($(($(($(($(($adc_T>>4))-$(($dig_T1))))*$(($(($adc_T >> 4))-$(($dig_T1)))))) >>12))*$(($dig_T3))))>>14))
	local t_fine=$(($var1+$var2))
	local Temp_val=$(($(($(($t_fine*5))+128))>>8))
	printf "Temperature = %.2f C\n" $(echo $Temp_val / 100 | bc -l)
}

function pressure(){
	local adc_T_msb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_MSB)))
        local adc_T_lsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_LSB)))
        local adc_T_xlsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_TEMP_XLSB)))
        local dig_T1=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T1_ADDR w)))
	local dig_T2=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T2_ADDR w)))
        if [ "$dig_T2" -gt "32767" ]; then
                dig_T2=$(("$dig_T2-65536"))
        fi
	local dig_T3=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_T3_ADDR w)))
	if [ "$dig_T2" -gt "32767" ]; then
                dig_T2=$(("$dig_T2-65536"))
        fi
	local adc_T=$(($(($(($adc_T_msb<<16))|$(($adc_T_lsb<<8))|$adc_T_xlsb))>>4))
        #local var1=$(($(($(($(($adc_T>>3))-$(($dig_T1<<1))))*$dig_T2))>>11))
	local var1=$(($(($(($(($(($adc_T>>3))-$(($dig_T1<<1))))*$dig_T2))))>>11)) 
        #local var2=$(($(($(($(($(($(($adc_T>>4))-$dig_T1))*$(($(($adc_T>>4))-$dig_T1))))>>12))*$dig_T3))>>14))
	local var2=$(($(($(($(($(($(($adc_T>>4))-$(($dig_T1))))*$(($(($adc_T >> 4))-$(($dig_T1)))))) >>12))*$(($dig_T3))))>>14))

        local t_fine=$(($var1+$var2))

        local adc_P_msb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_PRESS_MSB)))
        local adc_P_lsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_PRESS_LSB)))
        local adc_P_xlsb=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_PRESS_XLSB)))
        local dig_P1=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P1_ADDR w)))
	local dig_P2=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P2_ADDR w)))
        if [ "$dig_P2" -gt "32767" ]; then
                dig_P2=$(("$dig_P2-65536"))
        fi
	local dig_P3=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P3_ADDR w)))
	if [ "$dig_P3" -gt "32767" ]; then
                dig_P3=$(("$dig_P3-65536"))
        fi
	local dig_P4=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P4_ADDR w)))
        if [ "$dig_P4" -gt "32767" ]; then
                dig_P4=$(("$dig_P4-65536"))
        fi
	local dig_P5=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P5_ADDR w)))
        if [ "$dig_P5" -gt "32767" ]; then
                dig_P5=$(("$dig_P5-65536"))
        fi
	local dig_P6=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P6_ADDR w)))
	if [ "$dig_P6" -gt "32767" ]; then
                dig_P6=$(("$dig_P6-65536"))
        fi
	local dig_P7=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P7_ADDR w)))
        if [ "$dig_P7" -gt "32767" ]; then
                dig_P7=$(("$dig_P7-65536"))
        fi
	local dig_P8=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P8_ADDR w)))
        if [ "$dig_P8" -gt "32767" ]; then
                dig_P8=$(("$dig_P8-65536"))
        fi
	local dig_P9=$(($(i2cget -y $BMP280_I2CBUS $BMP280_DEVADDR $BMP280_DIG_P9_ADDR w)))
	if [ "$dig_P9" -gt "32767" ]; then
                dig_P9=$(("$dig_P9-65536"))
        fi
	local adc_P=$(($(($(($adc_P_msb<<16))|$(($adc_P_lsb<<8))|$adc_P_xlsb))>>4))
	local var1=$(($t_fine - 128000))
	local var2=$(($var1*$var1*$dig_P6))
	local var2=$(($var2+$(($(($var1*$dig_P5))<<17))))
	local var2=$(($var2+$(($(($dig_P4))<<35))))
	local var1=$(($(($(($var1*$var1*$dig_P3))>>8))+$(($(($var1*$dig_P2))<<12))))
	local var1=$(($(($(($((1<<47))+$var1))))*$(($dig_P1))>>33))
	local p=$((1048576 - $adc_P))
	local p=$(($(($(($(($p<<31))-$var2))*3125))/$var1))
	local var1=$(($(($(($dig_P9))*$(($p>>13))*$(($p>>13))))>>25))
	local var2=$(($(($dig_P8*$p))>>19))
	local p=$(($(($(($p+$var1+$var2))>>8))+$(($(($dig_P7))<<4))))

        printf "Pressure = %.3f Pa\n" $(echo $p / 256 | bc -l)
}

temperature
pressure
