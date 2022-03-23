      PROGRAM goes1_comma_counter
    
c ---------------------------------------------------------
c Program to count commas form each line then write that many
c data values out.
c J. Box, March, August 1999
c ---------------------------------------------------------	
	IMPLICIT NONE

        integer n_aws
	parameter (n_aws=10)

      	integer stnums(n_aws),nvars(n_aws)
        integer i,st,flag,kk,ii,count,iii,archivemode

        character*52 input,output
	character*1 invar(256)
	character*1 blank

	real var(38),today

	character*1 test

 	data (stnums(i),i=1,n_aws)/1,2,6,8,9,10,11,16,17,18/
 	data (nvars(i),i=1,n_aws)/40,30,30,38,10,30,30,30,30,30/

	print*,''
	print*,'PROGRAM PURPOSE:'
	print*,'  This program reads the number of commas'
	print*,'to know how many variables to read.'
	print*,'It writes out a fixed number of data points.'
	print*,''
	print*,'Output is directed to /ice/tools/aws/temp/' 
	print*,''

	archivemode=0

	print*,'Archive mode (AM) is set to ',archivemode
	print*,'AM = 0 = output only most recent 6 days'
	print*,'AM = 1 = output all input data'
	print*,''

	open(4,file='/ice/tools/aws/temp/todays_julian_date.dat')
	read(4,*) today
	close (4)

	do iii=1,n_aws
c	do iii=2,2

	st=stnums(iii)
	print*,'Begin counting commas for AWS ',st

c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
	  input='/ice/tools/aws/temp/01.4.dat'
	  output='/ice/tools/aws/temp/01.5.dat'  
	endif
c -------------------------------------------------------- Crawford Pt
	if(st.eq.2)then
	  input='/ice/tools/aws/temp/02.4.dat'
	  output='/ice/tools/aws/temp/02.5.dat'  
	endif
c -------------------------------------------------------- Summit
	if(st.eq.6)then
	  input='/ice/tools/aws/temp/06.4.dat'
	  output='/ice/tools/aws/temp/06.5.dat'  
	endif
c -------------------------------------------------------- DYE2
	if(st.eq.8)then
	  input='/ice/tools/aws/temp/08.4.dat'
	  output='/ice/tools/aws/temp/08.5.dat' 
	endif
c -------------------------------------------------------- JAR
	if(st.eq.9)then
	  input='/ice/tools/aws/temp/09.4.dat'
	  output='/ice/tools/aws/temp/09.5.dat'  
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
	  input='/ice/tools/aws/temp/10.4.dat'
	  output='/ice/tools/aws/temp/10.5.dat'  
	endif
c -------------------------------------------------------- South Dome
	if(st.eq.11)then
	  input='/ice/tools/aws/temp/11.4.dat'
	  output='/ice/tools/aws/temp/11.5.dat'  
	endif
c -------------------------------------------------------- KAR
	if(st.eq.16)then
	  input='/ice/tools/aws/temp/16.4.dat'
	  output='/ice/tools/aws/temp/16.5.dat'  
	endif
c -------------------------------------------------------- JAR 2
	if(st.eq.17)then
	  input='/ice/tools/aws/temp/17.4.dat'
	  output='/ice/tools/aws/temp/17.5.dat'  
	endif
c -------------------------------------------------------- KULU
	if(st.eq.18)then
	  input='/ice/tools/aws/temp/18.4.dat'
	  output='/ice/tools/aws/temp/18.5.dat'  
	endif
c --------------------------------------------------------

        OPEN (1,FILE=input)
        OPEN (2,FILE=output)

	do 10 i=1,45000
	  flag=0
	  if (i .eq. 1) read(1,1) blank

	  read(1,1,end=999) test
1	  format(a1)
	  read(1,1,end=999) test

	  read(1,11,end=999) (invar(kk),kk=1,256)
11	  format(256a1)

	  count=0

	  do ii=1,256
	    if (invar(ii) .eq. ',') count=count+1
	  enddo

c	  if (count+1 .ne. nvars(iii)) print*,i,count

	  backspace(unit=1)

	  do ii=1,38 
	    var(ii)=999.
	  enddo

	  read(1,*,end=999) (var(kk),kk=1,count+1)

c	  print*,var(1),var(2),var(count+1)

	  do ii=3,nvars(iii)
	    if(abs(var(ii)) .gt. 999.) var(ii)=999. 
  	  enddo

	  if(abs(var(1)) .gt. 366.) var(1)=999. 

	  if(var(1) .lt. 1.) var(1)=999. 

	  if(abs(var(2)) .gt. 2300.) var(1)=999. 

	  if (archivemode .eq. 0) then
	    if ((var(1).lt.today+0.5).and.(var(1).gt.today-6.)) then
	      write (2,2) (var(kk),kk=1,38)
2	      format(38f10.3)
	    endif
	  endif

	  if (archivemode .eq. 1) then
	    if (var(1) .lt. today+0.5) then
	      write (2,3) (var(kk),kk=1,38)
3	      format(38f10.3)
	    endif
	  endif

10	continue  

999	continue
 
	close(1)
	close(2)

	print*,'Done processing ',i,' lines'
	print*,''


	enddo

      END
