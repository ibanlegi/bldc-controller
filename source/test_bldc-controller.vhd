-- Définition des librairies
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

-- Définition de l'entité du testbench
entity bldc_controller_tb is
end bldc_controller_tb;

-- Architecture du testbench
architecture sim of bldc_controller_tb is

    -- Déclarations des signaux
    signal clk             : std_logic := '0';
    signal en              : std_logic := '1';
    signal rst             : std_logic := '0';
    signal h               : std_logic := '0';  -- Capteur Hall (signal d'entrée)
    signal duty            : std_logic_vector(7 downto 0) := (others => '0');
    signal U               : std_logic;
    signal V               : std_logic;
    signal W               : std_logic;
    signal Un              : std_logic;
    signal Vn              : std_logic;
    signal Wn              : std_logic;

begin
    -- Instantiation du contrôleur BLDC
    uut: entity work.bldc_controller
        generic map (
            FREQ_CLK     => 1000000,  -- Fréquence_CLK (1 MHz)
            MOTOR_CYCLE  => 50         -- Cycle de phase du moteur (50 Hz)
        )
        port map (
            clk     => clk,
            en      => en,
            rst     => rst,
            h       => h,   -- Capteur Hall en entrée
            duty    => duty,
            U       => U,
            V       => V,
            W       => W,
            Un      => Un,
            Vn      => Vn,
            Wn      => Wn
        );

    -- Générateur de clock à 1 MHz
    clk_process : process
    begin
        clk <= not clk after 500 ns;  -- Changement après 500 ns pour une période totale de 1 µs
        wait for 500 ns;              -- Attendre 500 ns avant de refaire l'inversion
    end process;


    -- Stimuli pour tester le contrôleur
    stim_proc: process
    begin
        -- Initialisation
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        
        -- Test avec des valeurs de duty et h
        duty <= "01000000";  -- 50% de cycle
--        h <= '0';            -- Pas de détection de Hall (pas de tour complet)
--        wait for 100 ns;
        
--        duty <= "11000000";  -- 75% de cycle
--        h <= '1';            -- Détection de Hall (1 tour complet simulé)
--        wait for 100 ns;
        
--        duty <= "10000000";  -- 62.5% de cycle
--        h <= '0';            -- Pas de détection de Hall
--        wait for 100 ns;
        
--        duty <= "00000000";  -- 0% de cycle
--        h <= '0';            -- Pas de détection de Hall
        wait for 2500 ms;
        
        duty <= "11111111";  -- 100% de cycle
--        h <= '1';            -- Détection de Hall
--        wait for 100 ns;
        
--        duty <= "01111111";  -- 50% de cycle
--        h <= '0';            -- Pas de détection de Hall
--        wait for 100 ns;
        
        -- Simulation de plusieurs tours (chaque tour = 6 steps = 6 * période moteur)
        for i in 0 to 4 loop  -- 5 cycles moteurs complets
            wait for 120 ms; -- durée approximative d'un tour à 50Hz (1 cycle = 20ms, donc 6 steps = 120ms)
            h <= '1';        -- déclenchement du capteur Hall (détection d'un tour)
            wait for 10 ms;
            h <= '0';        -- retour à l'état normal
        end loop;
        -- Fin de simulation
        wait;
    end process;

end sim;
