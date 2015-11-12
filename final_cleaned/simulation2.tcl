isim force add {/usb_adc/clk_ext} 1 -radix bin -value 0 -radix bin -time 8333 ps -repeat 16666 ps 
isim force add {/usb_adc/sigin_n} 0 -radix bin 
isim force add {/usb_adc/sigin_p} 11111111 -radix bin 
isim force add {/usb_adc/reset_ext} 1 -radix bin 
isim force add {/usb_adc/rxf_l} 1 -radix bin 
isim force add {/usb_adc/txe_l} 1 -radix bin 
run 500 ns
isim force add {/usb_adc/reset_ext} 0 -radix bin 
run 500 ns
isim force add {/usb_adc/rxf_l} 0 -radix bin 
run 500 ns
isim force add {/usb_adc/rxf_l} 1 -radix bin
run 500 ns 
isim force add {/usb_adc/txe_l} 0 -radix bin 
run 2000 ns
isim force add {/usb_adc/txe_l} 1 -radix bin 
run 1000 ns
isim force add {/usb_adc/txe_l} 0 -radix bin 
run 2000 ns