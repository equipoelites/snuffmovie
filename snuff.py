#!/usr/bin/env python3

import os
import sys
import subprocess
import time
import getpass
import argparse
import colorama

# Initialize colorama for cross-platform color support
colorama.init()

# Define colors
RED = colorama.Fore.RED
GREEN = colorama.Fore.GREEN
YELLOW = colorama.Fore.YELLOW
BLUE = colorama.Fore.BLUE
MAGENTA = colorama.Fore.MAGENTA
CYAN = colorama.Fore.CYAN
RESET = colorama.Fore.RESET

# Function to clear the screen
def clear_screen():
    os.system("clear" if os.name == "posix" else "cls")

# Function to display the menu
def display_menu():
    clear_screen()
    print(f"{BLUE}SNUFF - Herramienta de ARP spoofing y SSL stripping{RESET}\n")
    print(f"{GREEN}1) Ejecutar el script con los parámetros dados")
    print(f"2) Ver las dependencias del script")
    print(f"3) Instalar las dependencias del script")
    print(f"4) Salir del script{RESET}\n")

# Function to get user input for the menu option
def get_menu_option():
    return input(f"{YELLOW}Introduce una opción [1-4]: {RESET}")

# Function to execute the script with given parameters
def execute_script(objetivo1, objetivo2, interfaz):
    # Your implementation of the arpspoofing, iptables_rules, sslstrip, and ettercap functions here
    # ...

# Function to display dependencies
def display_dependencies():
    clear_screen()
    with open("requirements.txt", "r") as file:
        print(f"{CYAN}{file.read()}{RESET}\n")
    input("Pulsa una tecla para volver al menú...")

# Function to install dependencies
def install_dependencies():
    clear_screen()
    respuesta = input(f"{MAGENTA}¿Estás seguro de que quieres instalar las dependencias del script? (s/n): {RESET}")
    if respuesta.lower() == "s":
        subprocess.run(["pip", "install", "-r", "requirements.txt"])
        print(f"{GREEN}Dependencias instaladas correctamente{RESET}\n")
    else:
        print(f"{RED}Instalación cancelada{RESET}\n")
    input("Pulsa una tecla para volver al menú...")

# Function to exit the script
def exit_script():
    clear_screen()
    print(f"{GREEN}Gracias por usar SNUFF. Hasta pronto.{RESET}")
    sys.exit(0)

def main():
    while True:
        display_menu()
        opcion = get_menu_option()

        if opcion == "1":
            objetivo1 = input(f"{YELLOW}Introduce la dirección IP del primer objetivo: {RESET}")
            objetivo2 = input(f"{YELLOW}Introduce la dirección IP del segundo objetivo: {RESET}")
            interfaz = input(f"{YELLOW}Introduce la interfaz de red a usar: {RESET}")
            execute_script(objetivo1, objetivo2, interfaz)

        elif opcion == "2":
            display_dependencies()

        elif opcion == "3":
            install_dependencies()

        elif opcion == "4":
            exit_script()

        else:
            print(f"{RED}Error: opción no válida{RESET}")
            time.sleep(2)

if __name__ == "__main__":
    main()
