#!/usr/bin/env python



#-------------------------------------------------------------------------------

#

# splitbands.py

# extracts bandstructure from EIGENVAL file, requires fermi energy as input

# written on Apr 30th, 2013 

#

#-------------------------------------------------------------------------------



# This function reads in EIGENVAL and picks useful lines.

# The first nlskip lines and blank lines are omitted.

def GetFileContent(NLHead):

    Infile = open("EIGENVAL","r")

    FileContent = Infile.readlines()

    Infile.close()

    NumOfLines = len(FileContent)

    FileHead = FileContent[0:NLHead]

    FileBody = []

    for i in range(NLHead,NumOfLines):

        # The blank lines are omitted

        if FileContent[i] != " \n":

            FileBody.append(FileContent[i])

    return FileHead,FileBody



# This function generates the k-path, which is used as the x-axis when

# plotting bandstructure.

def GetKPath(FileBody):

    # Picks k points in FileContent

    KPoints = []

    for line in FileBody:

        # We use the length of line to determing which lines

        # contain coordinates of k points

        if len(line.split()) == 4:

            KPoints.append(line.split())

    # Calculate KPath

    KLen = []

    KLeni = 0.0

    k0 = KPoints[0]

    for ki in KPoints:

        dkx = float(ki[0]) - float(k0[0])

        dky = float(ki[1]) - float(k0[1])

        dkz = float(ki[2]) - float(k0[2])

        dk  = math.sqrt(math.pow(dkx,2.0)+math.pow(dky,2.0)+math.pow(dkz,2.0))

        KLeni = KLeni + dk

        KLen.append(KLeni)

        k0  = ki

    # Logging k points to file, which may be used when determing

    # the position of special points

    Outfile = open("KPATH","w")

    NKPoints = len(KPoints)

    for i in range(0,NKPoints):

        Outfile.write("%14.8f%14.8f%14.8f" % (float(KPoints[i][0]),float(KPoints[i][1]),float(KPoints[i][2])))

        Outfile.write("%14.8f\n" % KLen[i])

    Outfile.close()

    return KLen



# The main function

def main(argv = None):

    # Prompt the user for fermi energy

    Efermi = input("Please input the fermi energy in eV:")

    # By default the head of EIGENVAL has 7 lines. This works for EIGENVAL produced by vasp 5.3.3

    # Change it if any error occurs.

    NLHead = 7

    # Extract useful lines from EIGENVAL

    FileHead,FileBody = GetFileContent(NLHead)

    # Determine number of bands

    NBands = int((FileHead[5].split())[2])

    # Determine k path

    KLen = GetKPath(FileBody)

    # Ready to output

    Outfile = open("BNDSTR","w")

    # Loop over k points

    NKPoints = len(KLen)

    for i in range(0,NKPoints):

        Outfile.write("%14.8f" % KLen[i])

        # Each repeat unit of FileContent consists of NBands + 1 line,

        # one for coordinate of k point and others for band energies

        jmin = 1 + i * (NBands+1)

        jmax = jmin + NBands

        # Loop over energies

        for j in range(jmin,jmax):

            Currline = FileBody[j].split()

            Ei = float(Currline[1]) - Efermi

            Outfile.write("%14.6f" % Ei)

        # After finished logging energies for one k point, move to next line

        Outfile.write("\n")

    Outfile.close()

    return 0



if __name__ == "__main__":

   import sys

   import math

   sys.exit(main())
