#!/bin/bash

# Fonction pour afficher l'utilisation du script
usage() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "  --help, -h                Afficher ce message d'aide aux commandes"
	echo "  --all, -a                 Exécuter toutes les commandes"
	echo "  --update, -u              Mettre à jour le système"
	echo "  --remove-orphans, -r      Supprimer les paquets orphelins"
	echo "  --clean-cache, -c         Nettoyer le cache des packages"
	echo "  --clean-home, -x          Nettoyer le cache du répertoire home"
	echo "  --rmlint, -t              Exécuter rmlint avec l'option -g à partir du répertoire home"
	echo "  --clean-journal, -j       Nettoyer le journal systemd"
	echo "  --clean-temp-files, -f    Nettoyer les fichiers temporaires"
	echo "  --check-disk-health, -d   Vérifier la santé du disque dur"
	exit 1
}

# Fonction pour nettoyer tous les éléments
exec_all() {
	echo "Exécution de toutes les commandes..."

	read -p "Appuyez sur Enter pour exécuter la mise à jour du système (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && sudo pacman -Syu
	read -p "Appuyez sur Enter pour exécuter la suppression des paquets orphelins (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && sudo pacman -Rns $(pacman -Qdtq)
	read -p "Appuyez sur Enter pour exécuter le nettoyage du cache des packages (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && ls /var/cache/pacman/pkg/ && sudo pacman -Scc
	read -p "Appuyez sur Enter pour exécuter le nettoyage du cache du répertoire home (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && du -shc $HOME/.cache/* && rm -rf $HOME/.cache/*
	read -p "Appuyez sur Enter pour exécuter rmlint avec l'option -g à partir du répertoire home (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && rmlint -g ~/
	read -p "Appuyez sur Enter pour exécuter le nettoyage du journal systemd (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && sudo journalctl --vacuum-size=100M
	read -p "Appuyez sur Enter pour exécuter le nettoyage des fichiers temporaires (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && sudo rm -rf /tmp/* && sudo rm -rf /var/tmp/*
	read -p "Appuyez sur Enter pour vérifier la santé du disque dur (ou n'importe quelle autre touche pour ignorer)..." response && [[ -z "$response" ]] && sudo smartctl -H /dev/sda

	echo "Toutes les commandes ont été exécutées."
}

# Analyse des options de ligne de commande
while [[ $# -gt 0 ]]; do
	case "$1" in
		--all|-a)
			exec_all
			exit 0
			;;
		--update|-u)
			echo "Mise à jour du système..."
			sudo pacman -Syu
			;;
		--remove-orphans|-r)
			echo "Suppression des paquets orphelins..."
			sudo pacman -Rns $(pacman -Qdtq)
			;;
		--clean-cache|-c)
			echo "Nettoyage du cache des packages..."
			ls /var/cache/pacman/pkg/
			sudo pacman -Scc
			;;
		--clean-home|-x)
			echo "Nettoyage du cache du répertoire home..."
			du -shc $HOME/.cache/*
			rm -rf $HOME/.cache/*
			;;
		--rmlint|-t)
			echo "Exécuter rmlint avec l'option -g à partir du répertoire home et générer un script..."
			rmlint -g ~/
			echo "Le script rmlint a été généré : rmlint_script.sh"
			echo "Vous pouvez l'exécuter manuellement selon vos besoins."
			;;
		--clean-journal|-j)
			echo "Nettoyage du journal systemd..."
			sudo journalctl --vacuum-size=100M
			;;
		--clean-temp-files|-f)
			echo "Nettoyage des fichiers temporaires..."
			sudo rm -rf /tmp/*
			sudo rm -rf /var/tmp/*
			;;
		--check-disk-health|-d)
			echo "Vérification de la santé du disque dur..."
			sudo smartctl -H /dev/sda
			;;
		--help|-h|*)
			usage
			;;
	esac
	shift
done
