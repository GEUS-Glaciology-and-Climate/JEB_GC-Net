      Program goes3_gdf

	implicit none
c ---------------------------------------------------------
c     Program to read the variable
c ---------------------------------------------------------
	integer n_aws
	parameter (n_aws=10)
      real swin,swref,NET,Tc(12),
     *  RH1,RH2,U(2),DIR(2),BAR,sd1,sd2,TCS5001,TCS5002,
     * tca(2),m(10),bat,jt,garb

      integer i,k,year,st,stnums(n_aws),iii

      character*2 stnum
 	data (stnums(i),i=1,n_aws)/1,2,6,8,9,10,11,16,17,18/

	print*,''
	print*,'PROGRAM PURPOSE:'
	print*,'  This program reformats the data into the GDF, i.e.'
	print*,'the Greenland Data Format. See data reference document.'
	print*,''
	print*,'Output is directed to /ice/tools/aws/temp/' 
	print*,''

	do 789 iii=1,n_aws

	st=stnums(iii)

c	print*,'Input station number (1, 2, 6, 8, 9, 10, 11)'
c	read(*,*),st

c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/01.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/01.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines01.dat')
	  stnum='01'
	  year=1999
	endif
c -------------------------------------------------------- Crawford Pt
	if(st.eq.2)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/02.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/02.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines02.dat')
	  stnum='02'
	  year=1999
	endif
c -------------------------------------------------------- Summit
	if(st.eq.6)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/06.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/06.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines06.dat')
	  stnum='06'
	  year=1999
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/08.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/08.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines08.dat')
	  stnum='08'
	  year=1999
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/09.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/09.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines09.dat')
	  stnum='09'
	  year=1999
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/10.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/10.7.dat')  
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines10.dat')
	  stnum='10'
	  year=1999
	endif
c -------------------------------------------------------- SDOME
	if(st.eq.11)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/11.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/11.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines11.dat')
	  stnum='11'
	  year=1999
	endif
c -------------------------------------------------------- KAR
	if(st.eq.16)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/16.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/16.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines16.dat')
	  stnum='16'
	  year=1999
	endif
c -------------------------------------------------------- JAR2
	if(st.eq.17)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/17.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/17.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines17.dat')
	  stnum='17'
	  year=1999
	endif
c -------------------------------------------------------- KULU
	if(st.eq.18)then
          OPEN (UNIT=1,FILE='/ice/tools/aws/temp/18.6.dat')
          OPEN (UNIT=10,FILE='/ice/tools/aws/temp/18.7.dat')
          OPEN (UNIT=11,FILE='/ice/tools/aws/temp/nlines18.dat')
	  stnum='18'
	  year=1999
	endif
c --------------------------------------------------------

	TCS5001=999.
	TCS5002=999.
	bat=999.

	print*,'Begin processing ',st

c --------------------------------------------------------- begin loop
        DO 8000 I=1,50000

	  do k=1,12
	    tc(k)=999.
	  enddo

 	  do k=1,2
	    tca(k)=999.
	    dir(k)=999.
	    U(k)=999.
	  enddo

 	  do k=1,10
	    m(k)=999.
	  enddo
c -------------------------------------------------------- Swiss Camp
	if(st.eq.1)then
          READ(1,*,end=999) jt,swin,swref,NET,garb,
     *    garb,garb,garb,garb,
     *    TCa(1),TCa(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
     *    sd2,tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),garb,garb,garb,
     *    garb,bat,garb
	endif
c -------------------------------------------------------- Crawford Pt.
	if(st.eq.2)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- GISP 2
	if(st.eq.6)then
c          READ(1,*,end=999) jt,swin,swref,NET,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    tca(1),tca(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd2,sd1,
c     *    m(1),m(2)
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- DYE-2
	if(st.eq.8)then
          READ(1,*,end=999) jt,swin,swref,NET,
     *    Tca(1),tca(2),
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    m(5),m(6),TCS5001,TCS5002,bat,
     *    m(1),m(2),m(3),m(4),m(7),m(8),m(9),garb
	endif
c -------------------------------------------------------- Jar
	if(st.eq.9)then
c	  if((jt.lt.146.75).and.(year.eq.1999))then
c            READ(1,*,end=999) jt,swin,swref,NET,
c     *      tca(1),tca(2),TCS5001,TCS5002,
c     *      RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,
c     *      tc(6),tc(7),tc(8),tc(9),tc(10),m(1),m(2),
c     *      m(4),m(3),garb
c	  endif
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- Saddle
	if(st.eq.10)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- South Dome
c 	if(st.eq.11)then
c         READ(1,*,end=999) jt,swin,swref,NET,
c     *    tc(1),tc(2),tc(3),tc(4),tc(5),
c     *    tc(6),tc(7),tc(8),tc(9),tc(10),
c     *    Tca(1),tca(2),TCS5001,TCS5002,
c     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
c     *    m(1),m(2),m(3)
c	endif
	if(st.eq.11)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- KAR
	if(st.eq.16)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- JAR2
	if(st.eq.17)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif
c -------------------------------------------------------- KULU
	if(st.eq.18)then
         READ(1,*,end=999) jt,swin,swref,NET,
     *    tc(1),tc(2),tc(3),tc(4),tc(5),
     *    tc(6),tc(7),tc(8),tc(9),tc(10),
     *    Tca(1),tca(2),TCS5001,TCS5002,
     *    RH1,RH2,U(1),u(2),dir(1),dir(2),BAR,sd1,sd2,
     *    m(6),bat,
     *    garb,garb,garb,garb,garb,garb,garb,garb,garb
	endif

c ---------------------------------------------------------- Write output
         WRITE (10,10) stnum,year,jt,swin,swref,NET,
     *  TCa(1),TCa(2),
     *  TCS5001,TCS5002,RH1,RH2,U(1),U(2),dir(1),dir(2),BAR,sd1,sd2,
     *  tc(1),tc(2),tc(3),tc(4),tc(5),
     *  tc(6),tc(7),tc(8),tc(9),tc(10),
     *  bat,m(1),m(2),m(3),m(4),m(5),m(6),m(7),m(8),m(9),m(10)

10       FORMAT (a2,1x,i4,1x,f10.4,38F10.3)

8000  CONTINUE

999   print*,'Done processing.',i-1,' lines.' 
	print*,''


	write(11,11) i-1
11	format(i5)

	close(1)
	close(10)
	close(11)

789	continue

      END
