      Program goes2_sort
	implicit none
c ---------------------------------------------------------
c     Program to sort GOES data created by goes1.f
c It outputs a file which must be converted to common format.
c V 1.0 Jason Box 01/05/1997
c V 2.0 Jason Box 02/02/1999
c Lat edit Jason Box August 1999
c ---------------------------------------------------------
	integer n_aws,nvars
	parameter (n_aws=10)
	parameter (nvars=38)

	real var(38,45000),a(38)

      integer i,JD,hrmn,n,nlines,k,j,l,kk,st,
     *  ii,stnums(n_aws),iii

      character*2 stnum 
      character*52 input,output

 	data (stnums(i),i=1,n_aws)/1,2,6,8,9,10,11,16,17,18/


	print*,''
	print*,'PROGRAM PURPOSE:'
	print*,'  This program sorts the data by julian decimal time and'
	print*,'outputs a file which must be converted to common format'
	print*,''
	print*,'Output is directed to /ice/tools/aws/temp/' 
	print*,''

	print*,''

	do 789 iii=1,n_aws

	st=stnums(iii)

 	print*,''
	print*,'Begin Processing AWS number ',st
c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
	  input='/ice/tools/aws/temp/01.5.dat'
	  output='/ice/tools/aws/temp/01.6.dat'  
	  stnum='01'
	endif
c -------------------------------------------------------- Crawford Pt
	if(st.eq.2)then
	  input='/ice/tools/aws/temp/02.5.dat'
	  output='/ice/tools/aws/temp/02.6.dat'  
	  stnum='02'
	endif
c -------------------------------------------------------- Summit
	if(st.eq.6)then
	  input='/ice/tools/aws/temp/06.5.dat'
	  output='/ice/tools/aws/temp/06.6.dat'  
	  stnum='06'
	endif
c -------------------------------------------------------- DYE2
	if(st.eq.8)then
	  input='/ice/tools/aws/temp/08.5.dat'
	  output='/ice/tools/aws/temp/08.6.dat'   
	  stnum='08'
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
	  input='/ice/tools/aws/temp/09.5.dat'
	  output='/ice/tools/aws/temp/09.6.dat'  
	  stnum='09'
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
	  input='/ice/tools/aws/temp/10.5.dat'
	  output='/ice/tools/aws/temp/10.6.dat'  
	  stnum='10'
	endif
c -------------------------------------------------------- South Dome
	if(st.eq.11)then
	  input='/ice/tools/aws/temp/11.5.dat'
	  output='/ice/tools/aws/temp/11.6.dat'  
	  stnum='11'
	endif
c -------------------------------------------------------- KAR
	if(st.eq.16)then
	  input='/ice/tools/aws/temp/16.5.dat'
	  output='/ice/tools/aws/temp/16.6.dat'  
	  stnum='16'
	endif
c -------------------------------------------------------- JAR2
	if(st.eq.17)then
	  input='/ice/tools/aws/temp/17.5.dat'
	  output='/ice/tools/aws/temp/17.6.dat'  
	  stnum='17'
	endif
c -------------------------------------------------------- KULU
	if(st.eq.18)then
	  input='/ice/tools/aws/temp/18.5.dat'
	  output='/ice/tools/aws/temp/18.6.dat'  
	  stnum='18'
	endif
c --------------------------------------------------------
      OPEN (1,FILE=input)
      OPEN (2,FILE=output)
C     input data from tunu.out produced by argos.for 

      n=0
	ii=1

      nlines=45000
	print*,'  Begin reading.'

	do 10 i=1,nlines
	  read(1,*,end=999) jd,hrmn,(var(k,i),k=2,37)
	  var(1,i)=(jd*1.)+((hrmn*1.)/2400.)
	  n=n+1
10	continue  
999	continue

	print*,'  N lines : ',n

c ---------------------------------------------------------- Sort
c	sort the data with increasing jd_h

	print*,'  Begin sorting.'

	kk=0

      do 50 j=kk,n
        do 60 l=1,nvars
          a(l)=var(l,j)
60      continue

        do 61 i=j-1,1,-1
          if(var(1,i).le.a(1)) goto 62
          do 63 l=1,nvars
          var(l,i+1)=var(l,i)
63	  continue       

61	continue

        i=0

62	  do 65 l=1,nvars
	    var(l,i+1)=a(l)
65	  continue       

	  kk=kk+1
50	continue
	print*,'  End sorting.'

c --------------------------------------------------------- End Sort
99	continue

	print*,'  Begin writting to file.'
	print*,'  Nlines : ',n
	print*,'  N Variables : ',nvars

	do i=1,n
      if(var(1,i).ne.var(1,i+1)) then
      if((var(1,i).gt.0).and.(var(1,i).lt.367.))then
          write(2,2030) (var(k,i),k=1,38)
2030	  format(f10.4,1x,37f10.3)
	endif
      endif
	enddo

	close(1)
	close(2)

789	continue


      END
