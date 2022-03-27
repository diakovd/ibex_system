fr=open("./Hello/Output/Release/Exe/Hello.hex", "r")
fw= open("program.mif","w")
print (fr)
print (fw)

Record_type = "00"
lineWR = ""
count = 0
revers = ""

fw.write("WIDTH=32;\n")

#count number of byte
n = 0
for line in fr:
    if line[0] == ":":
        if line[7:9] == "00": #data line
            n = n + int(line[1:3], 16)
n = n//4 + 32 #add adreess shift on 32 word

fr.close()             # close port

fw.write("DEPTH="+ str(n) + ";\n")
fw.write("ADDRESS_RADIX=HEX;\n")
fw.write("DATA_RADIX=HEX;\n")
fw.write("CONTENT BEGIN\n")
index = 0
#for i in range(0,32): #add adreess shift on 32 word
#    fw.write(format(index, 'x') + " : " + "00000000;\n")
#    index = index + 1

fr=open("./Hello/Output/Release/Exe/Hello.hex", "r")
for line in fr:
    print(line)
    if line[0] == ":":
        if line[7:9] == "00": #data line
            n = int(line[1:3], 16)//4
            for i in range(0,n):
                dat = line[9+(2*i*n):9+(2*i*n)+8]
                dat = dat[6:8] + dat[4:6] + dat[2:4] + dat[0:2]
                fw.write(format(index, 'x') + " : " + dat + ";\n")
                print(str(index) + " : " + dat + ";\n")
                index = index + 1
fw.write("END;\n")
fw.close()             # close port
