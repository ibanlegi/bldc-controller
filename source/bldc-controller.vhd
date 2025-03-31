-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;



entity bldc_controller is
generic(
    MAX_CPT : integer --:= 20000 -- Fréquence_CLK (MHz) / cycle de phase du moteur (Hz) => 1/50
);
port(
    clk, en, rst : in std_logic;
    h : in std_logic_vector(2 downto 0);
    duty : in std_logic_vector(7 downto 0);
    U,V,W : out std_logic;
    Un, Vn, Wn : out std_logic
);

end bldc_controller;

architecture bldc_controller_arch of bldc_controller is
    signal counter : integer := 0;
    signal step    : integer := 0;
    signal cmd : integer := 0;
begin

    -- Calcul du rapport cyclique ajusté
    P_DUTY : process(clk)
        variable res : integer;
    begin
        if rising_edge(clk) then
            res := MAX_CPT - ((MAX_CPT * to_integer(unsigned(duty))) / 256);
            if res <= (MAX_CPT / 10) then  -- 10% de MAX_CPT
                cmd <= MAX_CPT / 10;
            elsif res >= (MAX_CPT * 9 / 10) then  -- 90% de MAX_CPT
                cmd <= MAX_CPT * 9 / 10;
            else
                cmd <= res;
            end if;
        end if;
    end process;
    
    process (clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            step    <= 0;
        elsif rising_edge(clk) then
            -- Incrémentation du compteur
            if counter < cmd then
                counter <= counter + 1;
            else
                counter <= 0;
                -- Avancer dans la séquence de commutation
                if step < 5 then
                    step <= step + 1;
                else
                    step <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Gestion des phases (séquence à 6 étapes)
    process (step)
    begin
        case step is
            when 0 => U <= '1'; Un <= '0'; V <= '0';  Vn <= '1'; W <= '0'; Wn <= '0';
            when 1 => U <= '1'; Un <= '0'; V <= '0';  Vn <= '0'; W <= '0'; Wn <= '1';
            when 2 => U <= '0'; Un <= '0'; V <= '1';  Vn <= '0'; W <= '0'; Wn <= '1';
            when 3 => U <= '0'; Un <= '1'; V <= '1';  Vn <= '0'; W <= '0'; Wn <= '0';
            when 4 => U <= '0'; Un <= '1'; V <= '0';  Vn <= '0'; W <= '1'; Wn <= '0';
            when 5 => U <= '0'; Un <= '0'; V <= '0';  Vn <= '1'; W <= '1'; Wn <= '0';
            when others => U <= '0'; Un <= '0'; V <= '0';  Vn <= '0'; W <= '0'; Wn <= '0';
        end case;
    end process;

end bldc_controller_arch;