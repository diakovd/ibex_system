#memory data line bit width 
mem_dat_bw = 32 # 64 option

fr=open("../Segger_pr/Output/Release/Exe/Dhry.hex", "r")
fw= open("program.coe","w")
print (fr)
print (fw)

Record_type = "00"
lineWR = ""
lineST = ""
count = 0
revers = ""
fw.write("memory_initialization_radix=16; \n")
fw.write("memory_initialization_vector=")
#line = fr.readline()
#print line

#for i in range(0,32):
#    fw.write("00000000 ")

for line in fr:
    print (line)
    lineWR = ""
    if int(line[8:9]) == 0:
        
        n = 2*int(line[1:3],16)
        count = 9 + n
        print("count =",count)
        
        if n % 8 != 0:
            count = 9 + n + (8 - (n % 8))
            line = line[:-3]
            for i in range(n % 8,8):
                line = line + "0" 
            print(line) 

        if mem_dat_bw == 64:
            for i in range(9,count,8):
                lineWR = lineWR + line[i+6] + line[i+7] + line[i+4] + line[i+5] + line[i+2] + line[i+3] + line[i] + line[i+1] + " "
                print (lineWR)
            lineST = lineST + lineWR


        if mem_dat_bw == 32:
            for i in range(9,count,8):
                lineWR = lineWR + line[i+6] + line[i+7] + line[i+4] + line[i+5] + line[i+2] + line[i+3] + line[i] + line[i+1] + " "
                print (lineWR)
            fw.write(lineWR)

if mem_dat_bw == 64:
    #convert from 32-bit word to 64-bit word
    lineST = lineST.replace(' ', '')        
    odd = len(lineST) % 16     
    
    
    lineWR = ''
    if(odd > 0): lineST = lineST + "00000000"  
    count = int(len(lineST) / 16) 
    print(count)
    
    for i in range(count):
        lineWR = lineWR + lineST[(i*16)+8:(i*16)+16] + lineST[(i*16):(i*16)+8] + " "
    
    print(lineWR)
    fw.write(lineWR)     

  
fw.close()
fr.close()
print(fr)
print(fw)
