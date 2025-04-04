LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bldc_controller_tb IS
END bldc_controller_tb;

ARCHITECTURE testbench OF bldc_controller_tb IS
    
    -- Déclaration des signaux de test
    SIGNAL clk_tb    : std_logic := '0';
    SIGNAL en_tb     : std_logic := '1';
    SIGNAL rst_tb    : std_logic := '0';
    SIGNAL h_tb      : std_logic_vector(2 downto 0) := "000";
    SIGNAL duty_tb   : std_logic_vector(7 downto 0) := "11111111"; -- 50% de duty cycle
    SIGNAL U_tb, V_tb, W_tb : std_logic;
    SIGNAL Un_tb, Vn_tb, Wn_tb : std_logic;
    
    -- Période d'horloge
    CONSTANT clk_period : time := 1000 ns; -- 1 MHz

    -- Composant à tester
--    COMPONENT bldc_controller
--        GENERIC ( MAX_CPT : 20000 );
--        PORT (
--            clk  : IN  std_logic;
--            en   : IN  std_logic;
--            rst  : IN  std_logic;
--            h    : IN  std_logic_vector(2 downto 0);
--            duty : IN  std_logic_vector(7 downto 0);
--            U, V, W : OUT std_logic;
--            Un, Vn, Wn : OUT std_logic
--        );
--    END COMPONENT;

BEGIN
    
    -- Instanciation du contrôleur BLDC
    uut: entity work.bldc_controller
    GENERIC MAP ( 
        FREQ_CLK => 1E6,
        MOTOR_CYCLE => 50
    ) -- Valeur fictive pour la simulation
    PORT MAP (
        clk  => clk_tb,
        en   => en_tb,
        rst  => rst_tb,
        h    => h_tb,
        duty => duty_tb,
        U    => U_tb,
        V    => V_tb,
        W    => W_tb,
        Un   => Un_tb,
        Vn   => Vn_tb,
        Wn   => Wn_tb
    );
    
    -- Processus de génération d'horloge
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk_tb <= '0';
            WAIT FOR clk_period / 2;
            clk_tb <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;
    
    -- Processus de stimulation
    stim_proc: PROCESS
    BEGIN
        -- Reset au début
        rst_tb <= '1';
        WAIT FOR clk_period;
        rst_tb <= '0';
        
        -- Modification du duty cycle pour tester différentes valeurs
--        WAIT FOR 100 ns;
--        duty_tb <= "11000000"; -- 75%
--        WAIT FOR 100 ns;
--        duty_tb <= "01000000"; -- 25%
    
        WAIT FOR 500000000 ns;
       
        duty_tb <= "00001111"; -- 25%
        
        -- Fin de simulation
        --WAIT FOR 50000 ns;
        REPORT "Simulation terminée";
        WAIT;
    END PROCESS;
    
END testbench;