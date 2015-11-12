isim force add {/bandwidth_counter/clk_ext} 1 -radix bin -value 0 -radix bin -time 8333 ps -repeat 16666 ps 
isim force add {/bandwidth_counter/sigin_n} 0 -radix bin 
isim force add {/bandwidth_counter/sigin_p} 11111111 -radix bin 
isim force add {/bandwidth_counter/reset_ext} 1 -radix bin 
isim force add {/bandwidth_counter/rxf_l} 1 -radix bin 
isim force add {/bandwidth_counter/txe_l} 1 -radix bin 
run 10 us
isim force add {/bandwidth_counter/reset_ext} 0 -radix bin 
run 10 us
isim force add {/bandwidth_counter/rxf_l} 0 -radix bin 
run 10 us
isim force add {/bandwidth_counter/txe_l} 0 -radix bin 
run 50 us
