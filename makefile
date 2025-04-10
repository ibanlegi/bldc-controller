# Dossier contenant les fichiers VHDL
VHDL_DIR = sources

# Définition des fichiers VHDL par défaut
VHDL_FILES = $(VHDL_DIR)/bldc-controller.vhd $(VHDL_DIR)/test_bldc-controller.vhd

# Commandes avec ghdl
ANALYZE_CMD = ghdl -a
ELABORATION_CMD = ghdl -e
REALIZE_CMD = ghdl -r
REALIZE_CMD_2 = --vcd=

# Commande pour gtkwave
GTKWAVE_CMD = gtkwave

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
	@$(ELABORATION_CMD) bldc_controller_tb
	@echo "Entity bldc_controller_tb generated"
	@echo " "

# Cible pour la simulation de l'entité et génération du fichier VCD
r:
	@echo "> Simulation of the entity bldc_controller_tb"
	@echo "After this step, to view the simulation, run the following command: make run"
	@echo " "
	@$(REALIZE_CMD) bldc_controller_tb $(REALIZE_CMD_2)bldc_controller_tb.vcd

# Cible pour exécuter gtkwave sur un fichier VCD
run:
	@$(GTKWAVE_CMD) bldc_controller_tb.vcd

# Nettoyer les fichiers générés par ghdl (si nécessaire)
clean-all:
	@$(MAKE) clean-cf
	@$(MAKE) clean-vcd

clean-cf:
	@rm -f *.cf

clean-vcd:
	@rm -f *.vcd

# Permet d'afficher l'aide pour l'utilisation du Makefile
help:
	@echo "Usage:"
	@echo "  make                                    # Analyser tous les fichiers VHDL par défaut"
	@echo "  make a-file f=mon_fichier.vhd           # Analyser un fichier spécifique"
	@echo "  make e entite=nom_de_l_entite           # Élaboration d'une entité"
	@echo "  make r entite=nom_de_l_entite f=nom.vcd # Simulation et génération de fichier VCD"
	@echo "  make run f=nom.vcd                      # Lance gtkwave sur un fichier .vcd"
	@echo "  make clean-all                          # Supprimer tous les fichiers générés"
	@echo "  make clean-cf                           # Supprimer les fichiers .cf"
	@echo "  make clean-vcd                          # Supprimer les fichiers .vcd"
