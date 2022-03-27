fr=open("../Segger_pr/Output/Release/Exe/Dhry.hex", "r")
fw= open("program.hex","w")
print (fr)
print (fw)

Record_type = "00"
lineWR = ""
count = 0
revers = ""

#line = fr.readline()
fw.write("@00000000\n")
#print line
for line in fr:
    #print line
    lineWR = ""
    if int(line[8:9]) == 0:

        n = 2 * int(line[1:3], 16)
        count = 9 + n
        #print("count =", count)

        if n % 8 != 0:
            count = 9 + n + (8 - (n % 8))
            line = line[:-3]
            for i in range(n % 8, 8):
                line = line + "0"
            #print(line)

        #print(count)
        for i in range(9,count,8):
            #print(line[i:(i+2)])
            revers = ""
            #print(line[(i+6):(i+8)]) 
            #print(line[(i+4):(i+6)]) 
            revers = line[(i+6):(i+8)] + line[(i+4):(i+6)] + line[(i+2):(i+4)] + line[(i):(i+2)]
            lineWR = lineWR + revers + " "
        print(lineWR)
        lineWR = lineWR + "\n"   
        fw.write(lineWR)
fw.close()
fr.close()
print(fr)
print(fw)
