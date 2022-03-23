      Program Argos
c       Converts ARGOS binary data to Campbell measurements
c       Sondy 5-30-95, Boulder 7-3-95
c       Revised Sept 1, 1995
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c       Revisions (version 2.0): Mike Crowl
c       Date: 08/25/1997
c       Notes: the program has been modified to no longer produce
c       output to named files such as narvik, dye, etc.  Since these
c       names can lead to inaccuracies and mis-conceptions about
c       where the stations are actually located.  Also, we are now
c       moving transmitters around, so transmitters cannot be
c       associated with a location or even just one station.
c
c       Modifications as follows:  Program now writes data to a file
c       specified by the user.
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c       Revisions (version 3.0): Jason Box
c	change user supplied input at prompt with user-supplied
c	input inside program, see in1='' and out1=''
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c       Revised in Sondy 6-8-98	Koni Steffen
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c	Modified to batch process all stations
c	Boulder 8-21-98		Jason Box
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c	Modified to process GITS and NASA-U
c	Boulder 7-06-99		Jason Box
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
        Real in(20),binval(20),val(20),nval(20)
        Real out(16)
        integer id,sta,da(7)
	Character*100 in1, out1,out2,out3,out4,out5,out6
        Character*1 num(65)

c ---------------------------------------------------------	
	in1='/ice/tools/aws/temp/argos.inx'
	out2='/ice/tools/aws/temp/05.argx'
c ---------------------------------------------------------
	open(1,file=in1)
	open(3,file=out2)

   15   do 25 ii=1,1000000

c   read first character of id: 0(1463)
        read(1,1001,end=5000) (num(kk),kk=1,65)
        if(num(1).eq.'0'.and. num(2).eq.'1') then
        backspace(1)
        read(1,*) id,sta 
        
c   search for empty transmission (jd time black)     
        read(1,1001,end=5000) (num(kk),kk=1,65)  
        if(num(65).eq.' ') goto 15
        backspace(1)        
        goto 30
        
        else
        if(num(7).eq.'1'.and.num(8).eq.'9') then
        if(num(65).eq.' ') goto 15
        backspace(1)
        goto 30
        else
        endif
        goto 15
        endif
 1001   format(65a)

   30   read(1,1002,end=5000) (da(m),m=1,7),(val(n),n=1,4)
        read(1,1003,end=5000) (val(n),n=5,8)
        read(1,1003,end=5000) (val(n),n=9,12)
        read(1,1003,end=5000) (val(n),n=13,16)

 1002   format(6x,i4,6(1x,i2),3(f11.0,2x),f11.0)
 1003   format(28x,3(f11.0,2x),f11.0)

c   data transmission of 16 data points
        do 50 i=1,16

        binval(i)=val(i)
        Do 100 k=1,16
        In(k)=0.
        if(val(i).ge.(2**(16-k))) then
        In(k)=1.
        val(i)=binval(i) - (2**(16-k))
        binval(i)=val(i)
        else
        endif
  100   continue

        nval(i)=0
        Do 200 k=4,16
        if(in(k).eq.1) then
        nval(i)=nval(i) + (2**(16-k))
        endif
  200   continue                     
  
        if(In(1).eq.1) nval(i)=nval(i)*(-1)
        if(In(2).eq.0.and.In(3).eq.0) out(i)=nval(i)
        if(In(2).eq.0.and.In(3).eq.1) out(i)=nval(i)/10
        if(In(2).eq.1.and.In(3).eq.0) out(i)=nval(i)/100
        if(In(2).eq.1.and.In(3).eq.1) out(i)=nval(i)/1000
  
   50   continue
 
c ----------------------------------------- Humboldt
	if(sta.eq.24741)then
	   write(3,2001) (da(m),m=1,7),sta,(out(n),n=1,16)
	endif
c ----------------------------------------- TUNU-N


 2001   format(i4,1x,6(i2,1x),I7,f8.0,f8.0,14(f10.3))
        
   25   continue    
   
 5000   continue  


        end
