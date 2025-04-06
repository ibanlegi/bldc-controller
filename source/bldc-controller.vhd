-- Définition des librairies
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity bldc_controller is
generic(
    FREQ_CLK : integer; -- Fréquence_CLK (MHz) : ex = 1 000 000
    MOTOR_CYCLE : integer -- Cycle de phase du moteur (Hz) : ex = 50
);
port(
    clk, en, rst : in std_logic;
    h : in std_logic;  -- Capteur Hall en entrée
    duty : in std_logic_vector(7 downto 0);
    U,V,W : out std_logic;
    Un, Vn, Wn : out std_logic
);

end bldc_controller;

architecture bldc_controller_arch of bldc_controller is
    constant MAX_CPT : integer := FREQ_CLK / MOTOR_CYCLE;   -- Calcul de la valeur max du compteur
    signal counter : integer := 0;                          -- Compteur interne pour le timing des phases montantes et descendantes
    signal step    : integer := 0;                          -- Etape de la séqeunce de commande (Pour la machine à état)
    signal cmd : integer := 0;                              -- Etape lors d'une rampe d'une phase
    signal cmdPrecedent : integer := 0;                     -- Précédente étape lors d'une rampe d'une phase
    signal rampUp : integer := 0;                           -- Valeur max d'une rampe lors de la phase de montée
    signal rampDown : integer := 0;                         -- Valeur max d'une rampe lors de la phase de descente
    signal rapport : integer := 0;                          -- Rapport entre la montée et la descente
    signal stepRamp : integer := 0;                         -- Etape de la rampe
    signal delta : integer := 0;                            -- Valeur de l'oscillation autour de la commande
    signal sens  : integer := 1;                            -- Sens de l'oscillation (+1 ou -1)
    
    signal h_detect : std_logic := '0';

begin

    process (clk, rst, h)
    variable res : integer;
    begin
        if rst = '1' then -- Initialisation des signaux
            counter <= 0;
            step <= 1;
            cmd <= 0;
            cmdPrecedent <= 0;
            rampUp <= 0;
            rampDown <= 0;
            rapport <= 0;
            stepRamp <= 0;
            delta <= 0;
            sens <= 1;
        elsif rising_edge(h) then  -- ou juste: if h = '1' then (selon ton besoin)
                if not (step = 1 or step = 6) then
                    h_detect <= '1'; -- A supprimer
                    counter <= 0;
                    step <= 1;
                    cmd <= 0;
                    cmdPrecedent <= 0;
                    rampUp <= 0;
                    rampDown <= 0;
                    rapport <= 0;
                    stepRamp <= 0;
                    delta <= 0;
                    sens <= 1;
                end if;
        elsif rising_edge(clk) then
            h_detect <= '0'; -- A supprimer
            -- Calcul de la valeur de base (res) en fonction du duty
            res := MAX_CPT - ((MAX_CPT * to_integer(unsigned(duty))) / 256);
            if res <= (MAX_CPT / 10) then
                res := MAX_CPT / 10;
            elsif res >= (MAX_CPT * 9 / 10) then
                res := MAX_CPT * 9 / 10;
            end if;
    
            -- Oscillation autour de res
            if counter mod 500 = 0 then  -- Fréquence de l'ondulation
                if sens = 1 then
                    delta <= delta + 1;
                    if delta >= (MAX_CPT / 20) then -- Amplitude de l'ondulation à 5%
                        sens <= -1;
                    end if;
                else
                    delta <= delta - 1;
                    if delta <= -(MAX_CPT / 20) then
                        sens <= 1;
                    end if;
                end if;
            end if;
    
            cmd <= res + delta;
    
            -- Initialisation ou ajustement des rampes
            if cmdPrecedent = 0 then -- Cas initial : On part de MAX_CPT
                rampUp <= MAX_CPT;
                rapport <= MAX_CPT - cmd;
                stepRamp <= rapport / 40;
                rampDown <= 0;
            elsif cmd > cmdPrecedent then -- Cas d'augmentation de la vitesse : On part du cmd précédent
                rampUp <= cmdPrecedent;
                rapport <= cmd - cmdPrecedent;
                stepRamp <= rapport / 40;
                rampDown <= 0;
            elsif cmd < cmdPrecedent then -- Cas de diminution de la vitesse : On part du cmd précédent
                rampDown <= cmdPrecedent;
                rapport <= cmdPrecedent - cmd;
                stepRamp <= rapport / 40;
                rampUp <= 0;
            end if;
    
            cmdPrecedent <= cmd;
    
            -- Gestion du compteur
            if rapport /= 0 then
                if rampDown = 0 then  -- Rampe montante : Augmentation progressive de la vitesse
                    if counter < rampUp then -- On augmente le compteur
                        counter <= counter + 1;
                    else -- On bascule d'une phase
                        counter <= 0;
                        if rampUp - stepRamp >= cmd then
                            rampUp <= rampUp - stepRamp;
                        end if;
                        -- Avancer dans la séquence des phases
                        if step < 6 then 
                            step <= step + 1;
                        else
                            step <= 1;
                        end if;
                    end if;
                elsif rampUp = 0 then  -- Rampe descendante : Diminution progressive de la vitesse
                    if counter < rampDown then -- On augmente le compteur
                        counter <= counter + 1;
                    else -- On bascule d'une phase
                        counter <= 0;
                        if rampDown + stepRamp <= cmd then
                            rampDown <= rampDown + stepRamp;
                        end if;
                        -- Avancer dans la séquence des phases
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

    -- Machine à état pour la gestion des sorties U, V, W
    process (step)
    begin
        case step is
            when 1 => U <= '1'; Un <= '0'; V <= '0'; Vn <= '1'; W <= '0'; Wn <= '0';
            when 2 => U <= '1'; Un <= '0'; V <= '0'; Vn <= '0'; W <= '0'; Wn <= '1';
            when 3 => U <= '0'; Un <= '0'; V <= '1'; Vn <= '0'; W <= '0'; Wn <= '1';
            when 4 => U <= '0'; Un <= '1'; V <= '1'; Vn <= '0'; W <= '0'; Wn <= '0';
            when 5 => U <= '0'; Un <= '1'; V <= '0'; Vn <= '0'; W <= '1'; Wn <= '0';
            when 6 => U <= '0'; Un <= '0'; V <= '0'; Vn <= '1'; W <= '1'; Wn <= '0';
            when others => U <= '0'; Un <= '0'; V <= '0'; Vn <= '0'; W <= '0'; Wn <= '0';
        end case;
    end process;
    
--    process(h)
--    begin
--        if rising_edge(h) then  -- ou juste: if h = '1' then (selon ton besoin)
--            if not (step = 1 or step = 6) then
--                counter <= 0;
--                step <= 1;
--                cmd <= 0;
--                cmdPrecedent <= 0;
--                rampUp <= 0;
--                rampDown <= 0;
--                rapport <= 0;
--                stepRamp <= 0;
--                delta <= 0;
--                sens <= 1;
--            end if;
--        end if;
--    end process;


end bldc_controller_arch;
