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
        
        -- SCENARIO 1 : Duty normal à 50%, sans signal Hall
        --------------------------------------------------
        duty <= "10000000";  -- 128 = 50%
        h <= '0';
        wait for 2 sec;
        
        -- SCENARIO 2 : Duty faible à 25%
        --------------------------------------------------
        duty <= "01000000";  -- 64 = 25%
        h <= '0';
        wait for 2 sec;
        
        -- SCENARIO 3 : Test avec signal Hall actif (simulateur d’un tour)
        --------------------------------------------------
        duty <= "11000000";  -- 192 = 75%
        for i in 0 to 4 loop  -- Simule 5 fronts montants Hall
            wait for 120 ms;
            h <= '1';         -- Détection front montant
            wait for 1 ms;
            h <= '0';         -- Retour à 0
        end loop;
        
        -- Fin de simulation
        --------------------------------------------------
        wait for 10 sec;
        assert false report "Fin de simulation (10s atteintes)" severity failure;
        wait;
    end process;

end sim;
