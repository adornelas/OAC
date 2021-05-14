def procura_prox_inst(file):
    if "ch" not in locals(): ch = ""
    if "ultimo_ch" not in locals(): ultimo_ch = ""

    while True:
        penultimo_ch = ultimo_ch
        ultimo_ch = ch
        ch = file.read(1)
        if (penultimo_ch == " " and ultimo_ch == ":" and ch == " " or ch == ""):
            return file

def cria_drs(mode, filepath):
    DRSFile = "#------------------------------------------------------------\n#- Deeds (Digital Electronics Education and Design Suite)\n#- Rom Contents Saved on (4/25/2021, 9:53:50 PM)\n#-      by Deeds (Digital Circuit Simulator)(Deeds-DcS)\n#-      Ver. 2.40.330 (Jan 07, 2021)\n#- Copyright (c) 2002-2020 University of Genoa, Italy\n#-      Web Site:  https://www.digitalelectronicsdeeds.com\n#------------------------------------------------------------\n#R ROM1Kx16, id 0003\n#- Deeds Rom Source Format (*.drs)\n\n#A 0000h\n#H\n\n"

    with open(filepath, "r") as f:
        linecnt = 1
        line = ""
        while True:
            f = procura_prox_inst(f)
            if (mode.lower() == "l"):
                inst = f.read(4)
            else:
                pass
            inst = f.read(4)
            line += inst + " "
            if (len(line) == 40):
                DRSFile += line + "\n"
                del line
                linecnt += 1
                line = ""
            if (inst == ""):
                linecnt += 1
                DRSFile += line[:-2] + int((45 - len(line))/5)*" FFFF"
                for i in range(128-linecnt): DRSFile += "\nFFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF"
                break
    return DRSFile

import os 
dir_path = os.path.dirname(os.path.realpath(__file__)) + "\\"

print("Informe o nome completo do arquivo:")
filename = input()
#filename = "testbench_text.mif"


filepath = dir_path + filename
with open(filepath[:filepath.rfind("\\")] + "\\instL_" + filepath[filepath.rfind("\\") + 1 :filepath.rfind("_")] + ".drs", "w") as f:
        f.write(cria_drs("l", filepath))
with open(filepath[:filepath.rfind("\\")] + "\\instM_" + filepath[filepath.rfind("\\") + 1 :filepath.rfind("_")] + ".drs", "w") as f:
    f.write(cria_drs("m", filepath))

print("Script finalizado")
