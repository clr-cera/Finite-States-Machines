entity elevator is
    port (clk, reset : in bit;
          req: in bit;
          desired_floor: in natural;
          movement: out bit_vector (1 downto 0));

end elevator;

architecture behaviour of elevator is
    type states is (not_moving, rising, descending);
    signal state: states;
    signal current_floor: natural;
    signal objective_floor: natural;

begin
    process (clk)
    begin
        if (reset = '1') then
            state <= not_moving;
            current_floor <= 0;
            objective_floor <= 0;

        elsif (clk'event) and (clk = '1') then
            case state is

                when not_moving =>
                    movement <= "00";
                    if (req = '1' and desired_floor /= current_floor) then
                        objective_floor <= desired_floor;
                        if (desired_floor > current_floor) then
                            state <= rising;
                        else
                            state <= descending;
                        end if;
                    end if;

                when rising =>
                    movement <= "01";
                    current_floor <= current_floor + 1;
                    if (objective_floor = current_floor) then
                        state <= not_moving;
                    end if;

                when descending =>
                    movement <= "10";
                    current_floor <= current_floor - 1;
                    if (objective_floor = current_floor) then
                        state <= not_moving;
                    end if;
            
            end case;
        end if;
    end process;
end behaviour;