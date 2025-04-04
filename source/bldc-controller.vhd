-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;



entity bldc_controller is
generic(
    FREQ_CLK : integer; -- Fréquence_CLK (MHz) : ex = 1 000 000
    MOTOR_CYCLE : integer -- Cycle de phase du moteur (Hz) : ex = 50
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
    constant MAX_CPT : integer := FREQ_CLK / MOTOR_CYCLE;
    signal counter : integer := 0;
    signal step    : integer := 0;
    signal cmd : integer := 0;
    signal rampUp : integer := 0;
    signal rampDown : integer := 0;
    signal cmdPrecedent : integer := 0; -- cmd avant le changement du nouveau cmd
    signal rapport : integer := 0; -- c'est la ramp, on regarde si la rampe va monter ou descendre, donc soit accélérée soit diminuée
    signal stepRamp : integer := 0; -- c'est le step, soit il réduit rampUp, soit il augmente rampDown
begin

    -- Calcul du rapport cyclique ajusté
    
    process (clk, rst, duty)
        variable res : integer;
    begin
        if rst = '1' then
            counter <= 0;
            step    <= 1;
        elsif rising_edge(clk) then
            res := MAX_CPT - ((MAX_CPT * to_integer(unsigned(duty))) / 256);
            if res <= (MAX_CPT / 10) then  -- 10% de MAX_CPT
                res := MAX_CPT / 10;
            elsif res >= (MAX_CPT * 9 / 10) then  -- 90% de MAX_CPT
                res := MAX_CPT * 9 / 10;
            end if;
            
            cmd <= res;

            if cmdPrecedent=0 then    -- cas initial: On part de MAX_CPT
                rampUp <= MAX_CPT;
                rapport <= MAX_CPT - res;
                stepRamp <= rapport/40;
                rampDown <= 0;
            elsif cmd > res then    -- cas augmentation de vitesse : On part du cmd (précédent)
                rampUp <= cmd;
                rapport <= cmd - res;
                stepRamp <= rapport/40;
                rampDown <= 0;
            elsif cmd < res then    -- cas diminution de vitesse : On part du cmd Prescédent
                rampDown <= cmd;
                rapport <= res - cmd;
                stepRamp <= rapport/40;
                rampUp <= 0;
            end if;
            
            cmdPrecedent <= cmd;
            
            -- Incrémentation du compteur
            if rapport /= 0 then
                if RampDown = 0 then  -- augmentation de la vitesse progressive
                    if counter < rampUp then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        if rampUp-stepRamp >= cmd then
                            rampUp <= rampUp - stepRamp;     
    --                    else
    --                        rampUp <= cmd;
                        -- Avancer dans la séquence de commutation
                        end if;
                        if step < 6 then
                            step <= step + 1;
                        else
                            step <= 1;
                        end if;
                     end if;
                elsif rampUp = 0 then   -- diminution de la vitesse progressive
                    if counter < rampDown then
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        if rampDown + stepRamp <= cmd then
                            rampDown <= rampDown + stepRamp;
    --                    else
    --                        rampDown <= cmd;
                        end if;
                        -- Avancer dans la séquence de commutation
                        if step < 6 then
                            step <= step + 1;
                        else
                            step <= 1;
                        end if;
                     end if;
                 end if;
           
            end if;
        end if;
    end process;

    -- Gestion des phases (séquence à 6 étapes)
    process (step)
    begin
        case step is
            when 1 => U <= '1'; Un <= '0'; V <= '0';  Vn <= '1'; W <= '0'; Wn <= '0';
            when 2 => U <= '1'; Un <= '0'; V <= '0';  Vn <= '0'; W <= '0'; Wn <= '1';
            when 3 => U <= '0'; Un <= '0'; V <= '1';  Vn <= '0'; W <= '0'; Wn <= '1';
            when 4 => U <= '0'; Un <= '1'; V <= '1';  Vn <= '0'; W <= '0'; Wn <= '0';
            when 5 => U <= '0'; Un <= '1'; V <= '0';  Vn <= '0'; W <= '1'; Wn <= '0';
            when 6 => U <= '0'; Un <= '0'; V <= '0';  Vn <= '1'; W <= '1'; Wn <= '0';
            when others => U <= '0'; Un <= '0'; V <= '0';  Vn <= '0'; W <= '0'; Wn <= '0';
        end case;
    end process;

end bldc_controller_arch;