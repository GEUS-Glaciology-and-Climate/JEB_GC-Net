      PROGRAM goes0_filter
    
c ---------------------------------------------------------
c Program to filter too long and too short of lines in
c the transmitted data.
c ---------------------------------------------------------	
	IMPLICIT NONE

        integer n_aws
	parameter (n_aws=10)

      	integer stnums(n_aws),nvars(n_aws),thrsh(n_aws)
        integer i,st,nlines,flag,j,num,ccc,cccc,lothresh

        character*52 input,output
        character*34 garb
        character*150 all
	character*20 var1
	character*1 var2
	character*1 blank

 	data (stnums(i),i=1,n_aws)/1,2,6,8,9,10,11,16,17,18/
 	data (nvars(i),i=1,n_aws)/40,30,30,38,10,30,30,30,30,30/
 	data (thrsh(i),i=1,n_aws)/125,120,120,120,120,120,120,120,120,120/

	blank=' '

	print*,''
	print*,'PROGRAM PURPOSE:'
	print*,'  This program filter too long and too short of lines'
	print*,'from the transmitted data by monitoring the number of'
	print*,'bytes, this given in info strip of transmission.'
	print*,''
	print*,'Output is directed to /ice/tools/aws/temp/' 
	print*,''

	do j=1,n_aws

	ccc=0
	cccc=0
	lothresh=94

	st=stnums(j)
c 	st=6
	print*,st

c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
	  input='/ice/tools/aws/temp/01.2.dat'
	  output='/ice/tools/aws/temp/01.3.dat'  
	endif
c -------------------------------------------------------- Crawford Pt
	if(st.eq.2)then
	  input='/ice/tools/aws/temp/02.2.dat'
	  output='/ice/tools/aws/temp/02.3.dat'  
	endif
c -------------------------------------------------------- Summit
	if(st.eq.6)then
	  input='/ice/tools/aws/temp/06.2.dat'
	  output='/ice/tools/aws/temp/06.3.dat'  
	endif
c -------------------------------------------------------- DYE2
	if(st.eq.8)then
	  input='/ice/tools/aws/temp/08.2.dat'
	  output='/ice/tools/aws/temp/08.3.dat' 
	endif
c -------------------------------------------------------- JAR
	if(st.eq.9)then
	  input='/ice/tools/aws/temp/09.2.dat'
	  output='/ice/tools/aws/temp/09.3.dat'  
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
	  input='/ice/tools/aws/temp/10.2.dat'
	  output='/ice/tools/aws/temp/10.3.dat'  
	endif
c -------------------------------------------------------- South Dome
	if(st.eq.11)then
	  input='/ice/tools/aws/temp/11.2.dat'
	  output='/ice/tools/aws/temp/11.3.dat'  
	endif
c -------------------------------------------------------- KAR
	if(st.eq.16)then
	  input='/ice/tools/aws/temp/16.2.dat'
	  output='/ice/tools/aws/temp/16.3.dat'  
	endif
c -------------------------------------------------------- JAR 2
	if(st.eq.17)then
	  input='/ice/tools/aws/temp/17.2.dat'
	  output='/ice/tools/aws/temp/17.3.dat'  
	endif
c -------------------------------------------------------- KULU
	if(st.eq.18)then
	  input='/ice/tools/aws/temp/18.2.dat'
	  output='/ice/tools/aws/temp/18.3.dat'  
	endif
c --------------------------------------------------------

        OPEN (1,FILE=input)
        OPEN (2,FILE=output)
C       input data from tunu.out produced by argos.for 


        nlines=45000

	print*,'Begin processing.'

	do 10 i=1,nlines
	  flag=0

	  read(1,1,end=999) garb,num
1	  format(a34,i3)

c	  print*,garb
c	  print*,i,num

	if (num.gt.thrsh(j)) then
	  ccc=ccc+1
c	   print*,'Line Number',i,num,' Bytes, byte threshold =',thrsh(j)
	endif
	if(num.lt.lothresh) then
	   cccc=cccc+1
c	   print*,'Line Number',i,num,' Bytes, byte threshold =',lothresh
	endif

	  backspace(1)
	  read(1,112,end=999) var1,var2
112	  format(a19,a1)

	if ((num.lt.thrsh(j)).and.(num.gt.lothresh).and.(var2.ne.'?')) then

	  backspace(1)
	  read(1,12,end=999) all
12	    format(a150)
	    write(2,222) blank
222	    format(a1)
	    write (2,2) all
2	    format(A150)
	endif


10	continue  

999	continue

	close(1)
	close(2)

	print*,'number of lines processed =',i
	print*,'number of long lines filtered =',ccc
	print*,'number of short lines filtered =',cccc
	print*,'Done.'


	enddo

      END
