--Codice .vhdl di: Campana Lorenzo (10605775, 907081), Cordioli Matteo (10611332, 913598)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
type S is (RESET, LOAD_FIRST_ADDR, COL_SETUP, PROD_CALC, READ_SETUP, FIND_MAX_MIN, WRITE_SETUP, READ_CURR_PIXEL, DIFF_CALC, TEMP_PIXEL_CALC, 
            NEW_PIXEL_CALC, WRITE_NEW_PIXEL, END_PROC);

signal cur_state, next_state : S;

signal col_load: std_logic;
signal col: std_logic_vector (7 downto 0);

                      
signal prod_load: std_logic;
signal prod: std_logic_vector (15 downto 0);                    --registro

signal max: std_logic_vector (7 downto 0);                      --registro
signal max_load: std_logic ;
signal min: std_logic_vector (7 downto 0);                      --registro
signal min_load: std_logic ;
signal shift: std_logic_vector (7 downto 0);                    --registro
signal shift_load: std_logic;

signal sel_addr: std_logic;
signal addr_load: std_logic ;
signal addr: std_logic_vector (15 downto 0);                    --registro
signal sel_o_addr: std_logic ;

signal delta_value: std_logic_vector (15 downto 0);

signal diff: std_logic_vector (15 downto 0); --(curr-min)       --registro
signal diff_load: std_logic ;
signal temp_pixel:  std_logic_vector (15 downto 0);             --registro
signal temp_pixel_load: std_logic ;

signal addr_mux: std_logic_vector (15 downto 0);


signal counter_min: std_logic_vector (7 downto 0);
signal counter_load: std_logic;
signal counter: std_logic_vector (7 downto 0);                  --registro


signal cambio_fase: std_logic ; 
signal devo_uscire: std_logic;
signal prod_end: std_logic;


begin

    --CONTROL UNIT
    
    --funzione di start e passo al prox stato
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= RESET;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    --funzione stato prossimo
    process(cur_state, i_start, cambio_fase, i_rst, devo_uscire, prod_end)
    begin
        next_state <= cur_state;   
        case cur_state is
            when RESET =>
                if i_start = '1' then
                    next_state <= LOAD_FIRST_ADDR;            
                end if;           
             when LOAD_FIRST_ADDR=>
                next_state <= COL_SETUP;
             when COL_SETUP=>
                next_state <= PROD_CALC;
             when PROD_CALC=>
                 if (prod_end = '1') then
                    next_state <= READ_SETUP;
                 end if;
                 if (devo_uscire = '1') then
                    next_state <= END_PROC;
                 end if;                            
             when READ_SETUP=>                           
                 next_state <= FIND_MAX_MIN;   
             when FIND_MAX_MIN=>
                if cambio_fase = '1' then
                    next_state <= WRITE_SETUP;
                end if;
             when WRITE_SETUP=>
                next_state <= READ_CURR_PIXEL;
             when READ_CURR_PIXEL=>
                next_state<=DIFF_CALC;
             when DIFF_CALC=>
                next_state<=TEMP_PIXEL_CALC;
             when TEMP_PIXEL_CALC=>
                next_state<=NEW_PIXEL_CALC;
             when NEW_PIXEL_CALC=>
                next_state <= WRITE_NEW_PIXEL;
             when WRITE_NEW_PIXEL => 
                if cambio_fase = '1' then
                    next_state <= END_PROC;
                else
                    next_state <= READ_CURR_PIXEL;
                end if;
             when END_PROC=>
                 if (i_start = '0') then
                    next_state<=RESET;
                 end if;           
        end case;           
        if (i_rst = '1') then
            next_state <= RESET;
        end if;
            
    end process;
    
    --funzione di setup dei segnali per il nostro modulo
    process(cur_state)
    begin
        
       
       --Reading Unit
        min_load<='0';
        max_load<='0';
        col_load<='0';
        prod_load<='0';
        counter_load <= '0';
        
        
        --Address Unit
        addr_load <= '0';
        sel_addr <= '0';
        sel_o_addr <= '0';
       
        
        --Writing Unit   
        diff_load <= '0';
        temp_pixel_load <= '0';
        shift_load<='0';
        
        --Output
        o_en<='0';
        o_done<='0';
        o_we<='0';
      
        case cur_state is  
            when RESET =>
               --reset già fatto, perchè valori di default
            when LOAD_FIRST_ADDR =>
                addr_load<='1';
                o_en <= '1';
            when COL_SETUP =>
                o_en<='1';
                col_load<='1';
                addr_load<='1';
            when PROD_CALC=> 
                --o_en<='1';
                prod_load <= '1';
                counter_load <= '1';       
            when READ_SETUP=> 
                o_en<='1';
                addr_load <= '1';
            when FIND_MAX_MIN=> 
                addr_load<='1';
                min_load<='1';
                max_load<='1';
                o_en<='1';                           
            when WRITE_SETUP=> 
                o_en<='0';
                sel_addr <= '1';
                addr_load <= '1';
                shift_load <= '1';
           when READ_CURR_PIXEL=> 
                o_en <= '1';
           when DIFF_CALC=> 
                o_en<='1';
                diff_load <= '1';
           when TEMP_PIXEL_CALC=> 
                o_en<='1';
                temp_pixel_load <= '1';
           when NEW_PIXEL_CALC=> 
                o_en<='1';
           when WRITE_NEW_PIXEL=> 
                o_en<='1';
                o_we <= '1';
                sel_o_addr <= '1';
                addr_load <= '1';
           when END_PROC=>
                o_done <= '1';
        end case;     
    end process;
    
    
    
    --cambio fase quando per usare meno cicli possibili nel nostro algoritmo
    cambio_fase<='1' when (
    (sel_o_addr = '0' and addr = prod +"0000000000000010"   and prod > "0000000000000000")
     or (sel_o_addr = '1' and addr = prod +"0000000000000001")) 
     else '0';
   
   
   --READING UNIT
   --gestione salvataggio in registro col
   process(i_clk, i_rst)
    begin
        if(i_rst = '1' or cur_state = END_PROC) then
            col <= "00000000";
        elsif i_clk'event and i_clk = '1' and col_load = '1' then
            col<=i_data;
        end if;
    end process;
   
   --gestione counter
   process(i_clk, i_rst)
    begin
        if(i_rst = '1' or cur_state = END_PROC) then
            counter <= "00000000";
        elsif i_clk'event and i_clk = '1' and counter_load = '1' then
            counter <= counter + 1;
        end if;
    end process;
    
    --minimo tra colonna e riga
    counter_min <= col when (col < i_data) else i_data;
    --scatta quando prodotto al prossimo ciclo è pronto
    prod_end <= '1' when (counter = counter_min - 1) else '0';
    
    
   --gestione prodotto
   process(i_clk, i_rst)
   begin
        if(i_rst = '1' or cur_state = END_PROC) then
            prod <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' and prod_load = '1' then
            if (col >= i_data) then
                prod  <= prod + col;
            elsif (col < i_data) then
                prod <= prod + i_data;
            end if;
        end if;
    end process;
    
    --controllo che riga e colonna non siano uguali a zero
    devo_uscire<='1' when (i_data="00000000" or col="00000000") else '0'; 
    
   -- gestione max
   process(i_clk, i_rst)
    begin
        if(i_rst = '1' or cur_state = END_PROC) then
            max <= "00000000";
        elsif i_clk'event and i_clk = '1' and max_load = '1' then
            if (i_data > max )then
                max <= i_data;
            end if; 
        end if;
    end process;
        
   --gestione min
   process(i_clk, i_rst)
    begin
        if(i_rst = '1' or cur_state = END_PROC) then
            min <= "11111111";
        elsif i_clk'event and i_clk = '1' and min_load = '1' then
            if (i_data < min )then
                min <= i_data;
            end if;      
        end if;
    end process;
    
    --END READING UNIT
    
    
    --WRITING UNIT
     
    --calcolo delta value e dello shift su esso
    delta_value<= ("00000000" & max) - ("00000000" & min)+"0000000000000001";
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1' or cur_state = END_PROC) then
            shift <= "00000000";
        elsif i_clk'event and i_clk = '1' and shift_load = '1' then
             if delta_value="0000000100000000" then   --256      
                shift<= "00000000";
             elsif delta_value(7)='1' then         
                shift<= "00000001";
             elsif delta_value(6)='1' then
                shift<= "00000010";
             elsif delta_value(5)='1' then
                shift<= "00000011";
             elsif delta_value(4)='1' then
                shift<= "00000100";
             elsif delta_value(3)='1' then
                shift<= "00000101";
             elsif delta_value(2)='1' then
                shift<= "00000110";
             elsif delta_value(1)='1' then
                shift<= "00000111";
             elsif delta_value(0)='1' then
                shift<= "00001000";
             end if;          
        end if;
    end process;
    
  --calcolo diff = (curr_pixel - min)
  process(i_clk, i_rst)
   begin
        if(i_rst = '1' or cur_state = END_PROC) then
            diff <= "0000000000000000";     
        elsif i_clk'event and i_clk = '1' and diff_load = '1' then
            diff <= ("00000000" & i_data)-("00000000" & min);
        end if;
   end process;
   
   --calcolo temp come da specifica
   process(i_clk, i_rst)
   begin
        if(i_rst = '1' or cur_state = END_PROC) then
            temp_pixel <= "0000000000000000";          
        elsif i_clk'event and i_clk = '1' and temp_pixel_load = '1' then
            if shift="00000000" then
                --non devo fare nulla temp rimane cio che già
                temp_pixel <= diff; 
             elsif shift="00000001" then
                temp_pixel <= diff(14 downto 0) & "0";                
             elsif shift="00000010" then
                temp_pixel <= diff(13 downto 0) & "00";                
             elsif shift="00000011" then
                temp_pixel <= diff(12 downto 0) & "000";                
             elsif shift="00000100" then
                temp_pixel <= diff(11 downto 0) & "0000";                
             elsif shift="00000101" then
                temp_pixel <= diff(10 downto 0) & "00000";               
             elsif shift="00000110" then
                temp_pixel <= diff(9 downto 0) & "000000";               
             elsif shift="00000111" then
                temp_pixel <= diff(8 downto 0) & "0000000";            
             elsif shift="00001000" then
                temp_pixel <= diff(7 downto 0) & "00000000";
             end if;      
        end if;
   end process;
  
  --assegno a o_data il new_pixel = min(255, temp_pixel)
  o_data <= "11111111" when (temp_pixel > "0000000011111111") else temp_pixel(7 downto 0);
  
  --END WRITING UNIT
 

               
   --ADDRESS UNIT
   with sel_addr  select
            addr_mux <=
                    addr + "0000000000000001" when '0',
                    "0000000000000010" when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
   process(i_clk, i_rst)
   begin
        if(i_rst = '1' or cur_state = END_PROC) then
            addr <= "0000000000000000";          
        elsif i_clk'event and i_clk = '1' then
            if addr_load='1' then
                addr<=addr_mux;
            end if;           
        end if;
   end process;
   
    with sel_o_addr  select
            o_address <=
                    addr when '0',
                    addr + prod when '1',
                    "XXXXXXXXXXXXXXXX" when others;
   
  --END ADDRESS UNIT   
    
     
     
end Behavioral;
