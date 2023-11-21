library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pepsi is
    port (
          clk, clk_placa: std_logic;
          reset: in bit;
          req: in bit;
          coin: in bit_vector(2 downto 0);

          current: out unsigned(4 downto 0) := (others => '0');
          pepsi_cola: out bit := '0';
          exchange: out bit := '0';
          state_out: out bit := '0'
          );

end pepsi;

architecture behaviour of pepsi is
    type states is (money, no_money);
    signal state: states;
    signal current_money: unsigned(4 downto 0) := (others => '0');

    signal fixed_clock: std_logic;

    component Debouncing_Button_VHDL is
        port(
            button: in std_logic;
            clk: in std_logic;
            debounced_button: out std_logic
        );
    end component;

    function value ( coin_in : in bit_vector(2 downto 0))
        return unsigned is
        variable value_out : unsigned(4 downto 0) := (others => '0');
    begin
        case coin_in is
            when "001" => value_out := value_out + 2;
            when "010" => value_out := value_out + 5;
            when "011" => value_out := value_out + 10;
            when "100" => value_out := value_out + 20;
            when others => value_out := value_out;
        end case;
        return value_out;

        
    end function value;

begin
    instance_debouncer: Debouncing_Button_VHDL
        port map (
            button => clk, clk => clk_placa,
            debounced_button => fixed_clock
        );

    process (fixed_clock)
    begin
        if (reset = '1') then
            state <= no_money;
            pepsi_cola <= '0';
            exchange <= '0';
            state_out <= '0';
            current <= "00000";
            current_money <= "00000";

        elsif (fixed_clock'event) and (fixed_clock = '1') then
            case state is

                when no_money =>
                    state_out <= '0';
                    pepsi_cola <= '0';
                    exchange <= '0';

                    if (coin /= "000") then
                        state <= money;
                        state_out <= '1';
                        current <= current_money + value(coin);
                        current_money <= current_money + value(coin);

                    end if;

                when money =>
                    current <= current_money + value(coin);
                    current_money <= current_money + value(coin);
                    state_out <= '1';
                    
                    if (current_money + value(coin) = 20 and req = '1') then
                        state <= no_money;
                        state_out <= '0';
                        pepsi_cola <= '1';
                        current <= "00000";
                        current_money <= "00000";
                    end if;
                    
                    
                    if (current_money + value(coin) > 20) then
                        state <= no_money;
                        state_out <= '0';
                        exchange <= '1';
                        current <= "00000";
                        current_money <= "00000";
                    end if;
            end case;
        end if;
    end process;
end behaviour;