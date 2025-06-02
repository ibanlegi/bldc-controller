# Dossier contenant les fichiers VHDL
VHDL_DIR = src

# Dossier de destination
SIM_DIR = sim

# Définition des fichiers VHDL par défaut
VHDL_FILES = $(VHDL_DIR)/bldc-controller.vhd $(VHDL_DIR)/test_bldc-controller.vhd

# Commandes avec ghdl
ANALYZE_CMD = ghdl -a
ELABORATION_CMD = ghdl -e
REALIZE_CMD = ghdl -r
REALIZE_CMD_2 = --vcd=$(SIM_DIR)/bldc_controller_tb.vcd

# Commande pour gtkwave
GTKWAVE_CMD = gtkwave

# Nom de l'entité de test
TEST_ENTITY = bldc_controller_tb

# Cible par défaut (lorsqu'on fait `make` sans arguments)
all: a e r

# Cible pour l'analyse de tous les fichiers VHDL par défaut
a:
	@echo "> Analysis of the files bldc-controller.vhd test_bldc-controller.vhd"
	@$(ANALYZE_CMD) $(VHDL_FILES)
	@echo "Analysis OK"
	@echo " "

# Cible pour l'élaboration de l'entité spécifiée
e:
	@echo "> Elaboration of the test entity bldc_controller_tb"
	@$(ELABORATION_CMD) $(TEST_ENTITY)
	@echo "Entity bldc_controller_tb generated"
	@echo " "

# Cible pour la simulation de l'entité et génération du fichier VCD
r:
	@echo "> Simulation of the entity bldc_controller_tb"
	@echo "After this step, to view the simulation, run the following command: make run"
	@echo "10 sec."
	@echo " "
	@$(REALIZE_CMD) $(TEST_ENTITY) $(REALIZE_CMD_2)

# Cible pour exécuter gtkwave sur un fichier VCD
run:
	@$(GTKWAVE_CMD) $(SIM_DIR)/bldc_controller_tb.vcd

# Nettoyer les fichiers générés par ghdl (si nécessaire)
clean-all:
	@$(MAKE) clean-cf
	@$(MAKE) clean-vcd
	@rm -f $(SIM_DIR)/$(TEST_ENTITY)

clean-cf:
	@rm -f *.cf

clean-vcd:
	@rm -f $(SIM_DIR)/*.vcd

# Permet d'afficher l'aide pour l'utilisation du Makefile
help:
	@echo "Usage:"
	@echo "  make                                    # Use all the commands"
	@echo "  make a           						 # Analysis of the files bldc-controller.vhd test_bldc-controller.vhd "
	@echo "  make e 					             # Elaboration of the test entity bldc_controller_tb"
	@echo "  make r 								 # Simulation of the entity bldc_controller_tb"
	@echo "  make run f=nom.vcd                      # Execute gtkwave with the file bldc_controller_tb.vcd"
	@echo "  make clean-all                          # Delete all the generated files"
	@echo "  make clean-cf                           # Delete the .cf files"
	@echo "  make clean-vcd                          # Delete the .vcd files"
