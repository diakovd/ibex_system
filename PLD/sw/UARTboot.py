import serial
ser = serial.Serial(port = 'COM3', baudrate=921600, parity=serial.PARITY_ODD)
if(ser.isOpen() == False):
    ser.open()

STPbyte = b'\x55'
ONbyte = b'\xAA'

#Reset system
for i in range(0,32):
    ser.write(STPbyte)

fd= open("program.hex","r")

#count number of byte
n = 0

line = fd.readline()
if line[0] == "@":
    for line in fd:
        ln = line
        for i in range(0, len(ln) - 1):
            if ln[i] != " ":
                n = n + 1;
n = n//2
n = f'{n:08x}'
numb = bytearray.fromhex(n)

fd.close()             # close port

fd= open("program.hex","r")

#Send start addr
StAddr = 0
line = fd.readline()
if line[0] == "@":
    StAddr = bytearray.fromhex(line[1:9])
    StAddr.reverse()
    ser.write(StAddr)

#send number of byte
numb.reverse()
ser.write(numb)
    
    
#send .hex
for line in fd:
    #print(line)
    i = 0
    while(i < len(line)-1) :
        dat = bytearray.fromhex(line[i:i + 8])
        i = i + 9
        dat.reverse()
        #print(dat.hex())
        ser.write(dat)

#Clear Reset of system
for i in range(0,32):
    ser.write(ONbyte)

fd.close()    
ser.close()         # close port
<<<<<<< HEAD
print("program.hex loaded")
=======
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
